import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'components/alarm_animations_list.dart';
import 'components/celestial.dart';
import 'components/next_alarm.dart';
import 'components/gradient_background.dart';
import 'components/midground.dart';

void main() {
  // Ensure that the app is initialized and the orientation is locked to portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(
            ChangeNotifierProvider(
              create: (context) => LampState(),
              child: const LEDZeppelinApp(),
            ),
          ));
}

// App state
class LampState extends ChangeNotifier {
  bool _isOn = true;
  double _brightness = 0.5;
  Color _color = Colors.white;
  int _selectedAnimation = 1;
  DateTime? _nextAlarm;
  BluetoothDevice? _connectedDevice;
  bool? _isConnected;

  BluetoothCharacteristic? _isOnCharacteristic;
  BluetoothCharacteristic? _brightnessCharacteristic;
  BluetoothCharacteristic? _colorCharacteristic;
  BluetoothCharacteristic? _selectedAnimationCharacteristic;
  BluetoothCharacteristic? _nextAlarmCharacteristic;

  final Guid _isOnUuid = Guid('dfc1a400-3523-4626-bd77-3469dbed8b74');
  final Guid _brightnessUuid = Guid('05f52bf8-4823-42c6-8647-dc89b76ad4e4');
  final Guid _colorUuid = Guid('b2516e35-6917-43b7-8cad-c7065a9e0033');
  final Guid _selectedAnimationUuid = Guid('0d72cbb7-742f-4030-b4ec-3aefb8c1eb1a');
  final Guid _nextAlarmUuid = Guid('2b3e71d1-4c3e-418e-942b-67f28951c2d3');

  LampState() {
    startScanning();
  }

  void startScanning() {
    notifyListeners();
    print("scanning");
    FlutterBluePlus flutterBlue = FlutterBluePlus();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // print('${r.device.platformName} found! rssi: ${r.rssi}');
        if (r.device.platformName == 'LED Zeppelin') {
          // print("connecting to ${r.device.platformName}");
          FlutterBluePlus.stopScan();
          _connectToDevice(r.device);
          break;
        }
      }
    });

    notifyListeners();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;
    for (int attempt = 0; attempt <= 10; attempt++) {
      try {
        await device.connect();
        break;
      } catch (e) {
        _isConnected = false;
        _isOnCharacteristic = null;
        _brightnessCharacteristic = null;
        _colorCharacteristic = null;
        _selectedAnimationCharacteristic = null;
        _nextAlarmCharacteristic = null;
        _connectedDevice = null;
        if (attempt == 5) startScanning();
        await Future.delayed(const Duration(seconds: 1));
      }
      _isConnected = false;
      _isOnCharacteristic = null;
      _brightnessCharacteristic = null;
      _colorCharacteristic = null;
      _selectedAnimationCharacteristic = null;
      _nextAlarmCharacteristic = null;
      _connectedDevice = null;
    }

    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      startScanning();
      return;
    }
    BluetoothService? targetService;
    for (BluetoothService service in services) {
      if (service.uuid.toString() == '6932598e-c4fe-4855-9701-240a78abc000') {
        targetService = service;
        break;
      }
    }

    if (targetService != null) {
      for (BluetoothCharacteristic characteristic in targetService.characteristics) {
        switch (characteristic.uuid.toString()) {
          case 'dfc1a400-3523-4626-bd77-3469dbed8b74':
            _isOnCharacteristic = characteristic;
            _subscribeToCharacteristic(_isOnCharacteristic!, _onIsOnReceived);
            break;
          case '05f52bf8-4823-42c6-8647-dc89b76ad4e4':
            _brightnessCharacteristic = characteristic;
            _subscribeToCharacteristic(_brightnessCharacteristic!, _onBrightnessReceived);
            break;
          case 'b2516e35-6917-43b7-8cad-c7065a9e0033':
            _colorCharacteristic = characteristic;
            _subscribeToCharacteristic(_colorCharacteristic!, _onColorReceived);
            break;
          case '0d72cbb7-742f-4030-b4ec-3aefb8c1eb1a':
            _selectedAnimationCharacteristic = characteristic;
            _subscribeToCharacteristic(_selectedAnimationCharacteristic!, _onAnimationReceived);
            break;
          case '2b3e71d1-4c3e-418e-942b-67f28951c2d3':
            _nextAlarmCharacteristic = characteristic;
            _subscribeToCharacteristic(_nextAlarmCharacteristic!, _onNextAlarmReceived);
            break;
        }
      }
    }

    _isConnected = true;
    notifyListeners();
  }

  void _subscribeToCharacteristic(BluetoothCharacteristic characteristic, Function(List<int>) onDataReceived) {
    final subscription = characteristic.lastValueStream.listen(onDataReceived);
    _connectedDevice?.cancelWhenDisconnected(subscription);
    characteristic.setNotifyValue(true);
  }

  void _onIsOnReceived(List<int> value) {
    _isOn = value.isNotEmpty && value[0] as bool;
    notifyListeners();
  }

  void _onBrightnessReceived(List<int> value) {
    if (value.isNotEmpty && value[0] != _brightness * 250.0) {
      _brightness = value[0] / 250.0;
      notifyListeners();
    }
  }

  void _onColorReceived(List<int> value) {
    if (value.length == 4) {
      int colorValue = ByteData.view(Uint8List.fromList(value).buffer).getUint32(0, Endian.little);
      _color = Color.fromARGB(255, (colorValue >> 16) & 0xFF, (colorValue >> 8) & 0xFF, colorValue & 0xFF);
      notifyListeners();
    }
  }

  void _onAnimationReceived(List<int> value) {
    if (value.isNotEmpty) {
      _selectedAnimation = value[0];
      notifyListeners();
    }
  }

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

  // Getters
  bool get isOn => _isOn;
  double get brightness => _brightness;
  Color get color => _color;
  int get selectedAnimation => _selectedAnimation;
  DateTime? get nextAlarm => _nextAlarm;
  bool get isConnected => _isConnected ?? false;

  // Update functions
  void toggle() {
    _isOn = !_isOn;
    notifyListeners();
    (_isOnCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected) ? _isOnCharacteristic!.write([isOn ? 1 : 0]) : startScanning();
  }

  double _lastSentBrightness = -1.0;
  final double _brightnessThreshold = 0.05;

  void setBrightness(double brightness) {
    _brightness = brightness;
    if ((_brightnessCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected) && ((brightness - _lastSentBrightness).abs() > _brightnessThreshold)) {
      _brightnessCharacteristic!.write([(brightness * 250).toInt()]);
      _lastSentBrightness = brightness;
    } else {
      startScanning();
    }
    notifyListeners();
  }

  Color _lastSentColor = Colors.black;
  final double _colorThreshold = 16.0;

  void setColor(Color color) {
    _color = color;
    notifyListeners();

    double colorDifference = sqrt(
      pow(color.red - _lastSentColor.red, 2) +
      pow(color.green - _lastSentColor.green, 2) +
      pow(color.blue - _lastSentColor.blue, 2)
    );

    if (_colorCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected && colorDifference > _colorThreshold) {
      int value = (color.red << 16) | (color.green << 8) | color.blue;
      Uint8List data = Uint8List(4);
      ByteData buffer = ByteData.view(data.buffer);
      buffer.setUint32(0, value, Endian.little);
      _colorCharacteristic!.write(data);
      _lastSentColor = color;
    } else {
      startScanning();
    }
  }

  void setNextAlarm(DateTime? nextAlarm) {
    _nextAlarm = nextAlarm;
    notifyListeners();

    if (_nextAlarmCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected) {
      if (nextAlarm != null) {
        int value = nextAlarm.millisecondsSinceEpoch ~/ 1000;
        Uint8List data = Uint8List(5); // Increase the size to 5 to accommodate the flag byte
        ByteData buffer = ByteData.view(data.buffer);
        buffer.setUint8(0, 1); // Set the flag byte to 1 to indicate this is the next alarm
        buffer.setUint32(1, value, Endian.little); // Start from the second byte
        _nextAlarmCharacteristic!.write(data);
      } else {
        _nextAlarmCharacteristic!.write([0, 0, 0, 0, 0]);
      }

      // Send the current time
      DateTime now = DateTime.now();
      int nowValue = now.millisecondsSinceEpoch ~/ 1000;
      Uint8List nowData = Uint8List(5); // Increase the size to 5 to accommodate the flag byte
      ByteData nowBuffer = ByteData.view(nowData.buffer);
      nowBuffer.setUint8(0, 0); // Set the flag byte to 0 to indicate this is the current time
      nowBuffer.setUint32(1, nowValue, Endian.little); // Start from the second byte
      _nextAlarmCharacteristic!.write(nowData);
    } else {
      startScanning();
    }
  }

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

  void setSelectedAnimation(int selectedAnimation) {
    _selectedAnimation = selectedAnimation;
    notifyListeners();
    (_selectedAnimationCharacteristic != null && _connectedDevice != null && _connectedDevice!.isConnected) ? _selectedAnimationCharacteristic!.write([selectedAnimation]) : startScanning();
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
