// Import the necessary libraries
import 'dart:async';                // Asynchronous functions such as await and Future
import 'dart:math';                 // Math functions such as sqrt and pow
import 'dart:typed_data';           // Typed data structures such as ByteData and Uint8List for handling binary data
import 'package:mutex/mutex.dart';  // Mutex for attempting the handling of concurrent access to shared resources

import 'package:flutter/material.dart';                         // Material design widgets such as Scaffold, Stack, Column, Row, Slider, IconButton, Icon, AlertDialog, etc.
import 'package:flutter/services.dart';                         // Services such as SystemChrome for setting the preferred orientation
import 'package:flutter_colorpicker/flutter_colorpicker.dart';  // Color picker widget
import 'package:flutter_blue_plus/flutter_blue_plus.dart';      // FlutterBluePlus for Bluetooth Low Energy (BLE) communication
import 'package:provider/provider.dart';                        // Provider for managing the state of the app

import 'components/alarm_animations_list.dart';  // AlarmAnimationsList widget for displaying the list of animations
import 'components/celestial.dart';              // CelestialBody widget for displaying the sun element
import 'components/next_alarm.dart';             // NextAlarm widget for displaying the next alarm time
import 'components/gradient_background.dart';    // GradientBackground widget for displaying the background gradient
import 'components/midground.dart';              // Midground widget for displaying the topmost background element

// Main function to run the flutter app
void main() {
  // Ensure that the app always runs in portrait mode by setting the preferred orientation after initializing the widgets
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(
            // Use the ChangeNotifierProvider to provide the LampState to the entire app defined in the LEDZeppelinApp widget
            ChangeNotifierProvider(
              create: (context) => LampState(),
              child: const LEDZeppelinApp(),
            ),
          ));
}

// LampState class to manage the state of the lamp
class LampState extends ChangeNotifier {
  // Initialize the state variables with default values ('_' denotes private variables and '?' denotes nullable variables)
  bool _isOn = true;
  double _brightness = 0.5;
  Color _color = Colors.white;
  int _selectedAnimation = 1;
  DateTime? _nextAlarm;
  BluetoothDevice? _connectedDevice;
  bool? _isConnected;

  // Initialize the Bluetooth Low Energy (BLE) characteristics with null values 
  BluetoothCharacteristic? _isOnCharacteristic;
  BluetoothCharacteristic? _brightnessCharacteristic;
  BluetoothCharacteristic? _colorCharacteristic;
  BluetoothCharacteristic? _selectedAnimationCharacteristic;
  BluetoothCharacteristic? _nextAlarmCharacteristic;

  // Initialize the UUIDs for the Bluetooth characteristics (reduntant for now, due to how the switch statement below is implemented)
  final Guid _isOnUuid = Guid('dfc1a400-3523-4626-bd77-3469dbed8b74');
  final Guid _brightnessUuid = Guid('05f52bf8-4823-42c6-8647-dc89b76ad4e4');
  final Guid _colorUuid = Guid('b2516e35-6917-43b7-8cad-c7065a9e0033');
  final Guid _selectedAnimationUuid = Guid('0d72cbb7-742f-4030-b4ec-3aefb8c1eb1a');
  final Guid _nextAlarmUuid = Guid('2b3e71d1-4c3e-418e-942b-67f28951c2d3');

  // Mutexes for handling concurrent access to shared resources
  final Mutex _brightnessMutex = Mutex();
  final Mutex _colorMutex = Mutex();

  // Constructor to initialize the state of the lamp, which starts immediately scanning for the LED Zeppelin device over BLE
  LampState() {
    startScanning();
  }

  // Monitor the device BLE connection and start scanning if the device is disconnected
  void monitorDeviceConnection() {
    if (_connectedDevice != null && !_connectedDevice!.isConnected) {
      startScanning();
    }
  }

  // Start scanning for the LED Zeppelin device for 30 seconds or until the device is found and connected to
  void startScanning() {
    notifyListeners();
    // print("scanning");
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == 'LED Zeppelin') {
          FlutterBluePlus.stopScan();
          _connectToDevice(r.device);
          break;
        }
      }
    });
  }

  // Connect to the LED Zeppelin device and discover the BLE services and characteristics it offers
  Future<void> _connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;
    bool connected = false;
    // Repeatedly attempt to connect to the device and start scanning again if the connection fails
    for (int attempt = 0; attempt < 10; attempt++) {
      try {
        await device.connect();
        connected = true;
        break;
      } catch (e) {
        if (attempt == 4) startScanning();
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    if (!connected) {
      startScanning();
      return;
    }

    // Discover the services offered by the device or start scanning again if the discovery fails
    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      startScanning();
      return;
    }

    // Find the target service with the characteristics corresponding to the lamp state variables
    BluetoothService? targetService;
    for (BluetoothService service in services) {
      if (service.uuid.toString() == '6932598e-c4fe-4855-9701-240a78abc000') {
        targetService = service;
        break;
      }
    }

    // Subscribe to the characteristics and read their values
    if (targetService != null) {
      for (BluetoothCharacteristic characteristic in targetService.characteristics) {
        switch (characteristic.uuid.toString()) {
          case 'dfc1a400-3523-4626-bd77-3469dbed8b74':
            _isOnCharacteristic = characteristic;
            _subscribeToCharacteristic(_isOnCharacteristic!, _onIsOnReceived);
            _isOnCharacteristic!.read().then(_onIsOnReceived);
            break;
          case '05f52bf8-4823-42c6-8647-dc89b76ad4e4':
            _brightnessCharacteristic = characteristic;
            // Skip subscribing to the brightness characteristic for now due to synchronization issues
            // _subscribeToCharacteristic(_brightnessCharacteristic!, _onBrightnessReceived);
            // _brightnessCharacteristic!.read().then(_onBrightnessReceived);
            break;
          case 'b2516e35-6917-43b7-8cad-c7065a9e0033':
            _colorCharacteristic = characteristic;
            _subscribeToCharacteristic(_colorCharacteristic!, _onColorReceived);
            _colorCharacteristic!.read().then(_onColorReceived);
            break;
          case '0d72cbb7-742f-4030-b4ec-3aefb8c1eb1a':
            _selectedAnimationCharacteristic = characteristic;
            _subscribeToCharacteristic(_selectedAnimationCharacteristic!, _onAnimationReceived);
            _selectedAnimationCharacteristic!.read().then(_onAnimationReceived);
            break;
          case '2b3e71d1-4c3e-418e-942b-67f28951c2d3':
            _nextAlarmCharacteristic = characteristic;
            _subscribeToCharacteristic(_nextAlarmCharacteristic!, _onNextAlarmReceived);
            _nextAlarmCharacteristic!.read().then(_onNextAlarmReceived);
            break;
        }
      }
    }

    // Set the connection state to true, start monitoring the device connection and notify the listeners about a state change
    _isConnected = true;
    monitorDeviceConnection();
    notifyListeners();
  }

  // Helper function for subscribing to the given characteristic and listening for data changes by setting the appropriate callback function
  void _subscribeToCharacteristic(BluetoothCharacteristic characteristic, Function(List<int>) onDataReceived) {
    final subscription = characteristic.lastValueStream.listen(onDataReceived);
    _connectedDevice?.cancelWhenDisconnected(subscription);
    characteristic.setNotifyValue(true);
  }

  // Functions for handling the received data from the BLE characteristics corresponding to the lamp state variables

  // Interpret the received data as a boolean value, update the isOn state variable with it and notify the listeners about the change
  void _onIsOnReceived(List<int> value) {
    _isOn = value.isNotEmpty && value[0] == 1;
    // print("isOn: $_isOn");
    notifyListeners();
  }


  // Interpret the received data as a double value, update the brightness state variable with it and notify the listeners about the change
  // Skip subscribing to the brightness characteristic for now due to synchronization issues
  // void _onBrightnessReceived(List<int> value) async {
  //   await _brightnessMutex.acquire();
  //   try {
  //     if (value.isNotEmpty) {
  //       double newBrightness = value[0] / 250.0;
  //       if (newBrightness != _brightness) {
  //         _brightness = newBrightness;
  //         print("brightness: $_brightness");
  //       }
  //     }
  //   } finally {
  //     _brightnessMutex.release();
  //     notifyListeners();
  //   }
  // }

  // Interpret the received data as a Color value, update the color state variable with it and notify the listeners about the change
  void _onColorReceived(List<int> value) async {
    await _colorMutex.acquire();
    try {
      if (value.length == 4) {
        int colorValue = ByteData.view(Uint8List.fromList(value).buffer).getUint32(0, Endian.little);
        _color = Color.fromARGB(255, (colorValue >> 16) & 0xFF, (colorValue >> 8) & 0xFF, colorValue & 0xFF);
        notifyListeners();
      }
    } finally {
      _colorMutex.release();
    }
  }

  // Interpret the received data as an integer, update the selectedAnimation state variable with it and notify the listeners about the change
  void _onAnimationReceived(List<int> value) {
    if (value.isNotEmpty) {
      _selectedAnimation = value[0];
      notifyListeners();
    }
  }

  // Interpret the received data as a DateTime value, update the nextAlarm state variable with it and notify the listeners about the change
  void _onNextAlarmReceived(List<int> value) {
    if (value.length == 5) {
      int flag = value[0];
      int timestamp = ByteData.view(Uint8List.fromList(value.sublist(1)).buffer).getUint32(0, Endian.little);
      if (flag == 1) {
        _nextAlarm = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      } else if (flag == 0) {
        // Update the current time if needed
      }
      notifyListeners();
    }
  }

  // Getters for the lamp state variables
  bool get isOn => _isOn;
  double get brightness => _brightness;
  Color get color => _color;
  int get selectedAnimation => _selectedAnimation;
  DateTime? get nextAlarm => _nextAlarm;
  bool get isConnected => _isConnected ?? false;

  // Functions for updating the lamp state variables from the app

  // Toggle the isOn state variable, write the updated value to the BLE characteristic and notify the listeners about the change
  void toggle() {
    _isOn = !_isOn;
    if (_isOnCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected) {
      _isOnCharacteristic!.write([_isOn ? 1 : 0]);
    } else {
      startScanning();
    }
    notifyListeners();
  }

  // Helper variables to achieve responsive brightness updates in the lamp by reducing redundant data sent to the BLE characteristics, which can otherwise cause delays due to buffering or something
  double _lastSentBrightness = -1.0;
  final double _brightnessThreshold = 0.05;

  // Set the brightness state variable, write the updated value to the BLE characteristic and notify the listeners about the change
  void setBrightness(double brightness) async {
    await _brightnessMutex.acquire();
    try {
      _brightness = brightness;
      if (_brightnessCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected &&
          (brightness - _lastSentBrightness).abs() > _brightnessThreshold) {
        _brightnessCharacteristic!.write([(brightness * 250).toInt()]);
        _lastSentBrightness = brightness;
      }
    } finally {
      _brightnessMutex.release();
      notifyListeners();
    }
  }

  // Helper variables to achieve responsive color updates in the lamp by reducing redundant data sent to the BLE characteristics, which can otherwise cause delays due to buffering or something
  Color _lastSentColor = Colors.black;
  final double _colorThreshold = 16.0;

  // Set the color state variable, write the updated value to the BLE characteristic and notify the listeners about the change
  void setColor(Color color) async {
    await _colorMutex.acquire();
    try {
      _color = color;

      double colorDifference = sqrt(
        pow(color.red - _lastSentColor.red, 2) +
        pow(color.green - _lastSentColor.green, 2) +
        pow(color.blue - _lastSentColor.blue, 2)
      );

      if (_colorCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected &&
          colorDifference > _colorThreshold) {
        int value = (color.red << 16) | (color.green << 8) | color.blue;
        Uint8List data = Uint8List(4);
        ByteData buffer = ByteData.view(data.buffer);
        buffer.setUint32(0, value, Endian.little);
        _colorCharacteristic!.write(data);
        _lastSentColor = color;
      } else {
        startScanning();
      }
      notifyListeners();
    } finally {
      _colorMutex.release();
    }
  }

  // Set the nextAlarm state variable, write the updated value to the BLE characteristic along with the current time for syncing and notify the listeners about the change
  void setNextAlarm(DateTime? nextAlarm) {
    _nextAlarm = nextAlarm;

    if (_nextAlarmCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected) {
      // Sync the next alarm with the lamp signaled by the flag value 1
      if (nextAlarm != null) {
        int value = nextAlarm.millisecondsSinceEpoch ~/ 1000;
        Uint8List data = Uint8List(5);
        ByteData buffer = ByteData.view(data.buffer);
        buffer.setUint8(0, 1);
        buffer.setUint32(1, value, Endian.little);
        _nextAlarmCharacteristic!.write(data);
      } else {
        _nextAlarmCharacteristic!.write([0, 0, 0, 0, 0]);
      }

      // Sync the current time with the lamp signaled by the flag value 0
      DateTime now = DateTime.now();
      int nowValue = now.millisecondsSinceEpoch ~/ 1000;
      Uint8List nowData = Uint8List(5);
      ByteData nowBuffer = ByteData.view(nowData.buffer);
      nowBuffer.setUint8(0, 0);
      nowBuffer.setUint32(1, nowValue, Endian.little);
      _nextAlarmCharacteristic!.write(nowData);
    } else {
      startScanning();
    }
    notifyListeners();
  }

  // Bring up the time picker dialog to select the next alarm time or set it to null upon cancellation
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final DateTime now = DateTime.now();
      final DateTime pickedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (pickedDateTime.isBefore(now)) {
        pickedDateTime.add(const Duration(days: 1));
      }
      setNextAlarm(pickedDateTime);
    } else {
      setNextAlarm(null);
    }
  }

  // Set the selectedAnimation state variable, write the updated value to the BLE characteristic and notify the listeners about the change
  void setSelectedAnimation(int selectedAnimation) {
    _selectedAnimation = selectedAnimation;
    if (_selectedAnimationCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected) {
      _selectedAnimationCharacteristic!.write([selectedAnimation]);
    } else {
      startScanning();
    }
    notifyListeners();
  }
}


class LEDZeppelinApp extends StatelessWidget {
  const LEDZeppelinApp({super.key});

  // Application root widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Zeppelin App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'LED Zeppelin App Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _selectTime(BuildContext context) async {
    await Provider.of<LampState>(context, listen: false).selectTime(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // The bottommost background element
          Consumer<LampState>(
            builder: (context, lampState, child) => GestureDetector(
              onTap: () {
                lampState.toggle();
              },
              child: GradientBackground(
                isOn: lampState.isOn,
                color: lampState.color,
                brightness: lampState.brightness,
              ),
            ),
          ),
          // CelestialBody widget is the sun/moon element that indicates the brightness level and the selected color
          Consumer<LampState>(
            builder: (context, lampState, child) => GestureDetector(
              onTap: () {
                lampState.toggle();
              },
              child: CelestialBody(
                  isDay: true,
                  brightness: lampState.brightness,
                  color: lampState.color),
            ),
          ),
          // Midground widget is the topmost background element
          Positioned(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Consumer<LampState>(
                builder: (context, lampState, child) => Midground(
                  isOn: lampState.isOn,
                  color: lampState.color,
                  brightness: lampState.brightness,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 96),
              Consumer<LampState>(
                builder: (context, lampState, child) => NextAlarm(
                  nextAlarm: lampState.nextAlarm,
                  brightness: lampState.brightness,
                  isOn: lampState.isOn,
                  onAlarmTap: () {
                    _selectTime(context);
                  },
                ),
              ),
              const SizedBox(height: 280),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Consumer<LampState>(
                      builder: (context, lampState, child) => SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6.0,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.5),
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10.0),
                        ),
                        child: Slider(
                          value: lampState.brightness,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (double value) {
                            lampState.setBrightness(value);
                          },
                        ),
                      ),
                    ),
                  ),
                  Consumer<LampState>(
                    builder: (context, lampState, child) => Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.color_lens,
                          shadows: [
                            Shadow(color: Colors.black38, blurRadius: 16.0)
                          ],
                        ),
                        color: Colors.white,
                        iconSize: 36,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor:
                                const Color.fromARGB(255, 20, 20, 20),
                            builder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: SingleChildScrollView(
                                    child: Theme(
                                  data: Theme.of(context).copyWith(
                                    textTheme:
                                        Theme.of(context).textTheme.apply(
                                              bodyColor: Colors.white,
                                              displayColor: Colors.white,
                                            ),
                                  ),
                                  child: HueRingPicker(
                                    pickerColor: lampState.color,
                                    hueRingStrokeWidth: 30,
                                    displayThumbColor: false,
                                    onColorChanged: (Color color) {
                                      if (color.red == color.green &&
                                          color.green == color.blue) {
                                        lampState.setColor(Colors.white);
                                      } else {
                                        lampState.setColor(
                                            HSLColor.fromColor(color)
                                                .withLightness(0.7)
                                                .withSaturation(1)
                                                .toColor());
                                      }
                                    },
                                  ),
                                )),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Consumer<LampState>(
                  builder: (context, lampState, child) => AlarmAnimationsList(
                    selectedAnimation: lampState.selectedAnimation,
                    color: lampState.color,
                    onAnimationSelected: (int selectedAnimation) {
                      lampState.setSelectedAnimation(selectedAnimation);
                    },
                  ),
                ),
              ),
            ],
          ),
          Consumer<LampState>(
            builder: (context, lampState, child) {
              if (!lampState.isConnected || lampState._connectedDevice == null) {
                return const AlertDialog(
                  title: Text('Connection Required'),
                  content: Text(
                      'Please turn on the lamp and Bluetooth, and allow necessary permissions.'),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
