import 'dart:async';

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
  Timer? _debounce;
  // Lamp state variables
  bool _isOn = true;
  double _brightness = 1;
  Color _color = Colors.white;
  int _selectedAnimation = 1;
  DateTime? _nextAlarm;
  BluetoothDevice? _connectedDevice;
  // BluetoothCharacteristic? _controlCharacteristic;

  BluetoothCharacteristic? _isOnCharacteristic;
  BluetoothCharacteristic? _brightnessCharacteristic;
  BluetoothCharacteristic? _colorCharacteristic;
  BluetoothCharacteristic? _selectedAnimationCharacteristic;
  BluetoothCharacteristic? _nextAlarmCharacteristic;

  final Guid _isOnUuid = Guid('dfc1a400-3523-4626-bd77-3469dbed8b74');
  final Guid _brightnessUuid = Guid('05f52bf8-4823-42c6-8647-dc89b76ad4e4');
  final Guid _colorUuid = Guid('b2516e35-6917-43b7-8cad-c7065a9e0033');
  final Guid _selectedAnimationUuid = Guid('0d72cbb7-742f-4030-b4ec-3aefb8c1eb1a');
  final Guid _nextAlarmUuid = Guid('');

  LampState() {
    FlutterBluePlus flutterBlue = FlutterBluePlus();

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 60));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.platformName} found! rssi: ${r.rssi}');
        if (r.device.platformName == 'LED Zeppelin') {
          print("connecting to ${r.device.platformName}");
          FlutterBluePlus.stopScan(); 
          _connectToDevice(r.device);
          break;
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
  _connectedDevice = device;
  for (int attempt = 0; attempt <= 10; attempt++) {
    try {
      await device.connect();
      break; // If the connection is successful, exit the loop
    } catch (e) {
      if (attempt == 10) rethrow; // If this was the last attempt, rethrow the exception
      await Future.delayed(const Duration(seconds: 1)); // Wait for a second before retrying
    }
  }
  List<BluetoothService> services = await device.discoverServices();
  
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
          break;
        case '05f52bf8-4823-42c6-8647-dc89b76ad4e4':
          _brightnessCharacteristic = characteristic;
          break;
        case 'b2516e35-6917-43b7-8cad-c7065a9e0033':
          _colorCharacteristic = characteristic;
          break;
        case '0d72cbb7-742f-4030-b4ec-3aefb8c1eb1a':
          _selectedAnimationCharacteristic = characteristic;
          break;
        case '2b3e71d1-4c3e-418e-942b-67f28951c2d3':
          _nextAlarmCharacteristic = characteristic;
          break;
      }
    }
  }

    // if (_controlCharacteristic != null) {
    //   _sendLampState();
    // }
  }

  // void _sendLampState() {
  //   if (_controlCharacteristic == null) return;
  //   List<int> values = [
  //     _isOn ? 1 : 0,
  //     (_brightness * 100).toInt(),
  //     _color.red,
  //     _color.green,
  //     _color.blue
  //   ];
  //   _controlCharacteristic!.write(values);
  // }

  // Getters
  bool get isOn => _isOn;
  double get brightness => _brightness;
  Color get color => _color;
  int get selectedAnimation => _selectedAnimation;
  DateTime? get nextAlarm => _nextAlarm;

  // Update functions
  void toggle() {
    _isOn = !_isOn;
    notifyListeners();
    if (_isOnCharacteristic != null) _isOnCharacteristic!.write([isOn ? 1 : 0]);
  }

  void setBrightness(double brightness) {
    _brightness = brightness;
    notifyListeners();
    // if (_brightnessCharacteristic != null) _brightnessCharacteristic!.write([(brightness * 250).toInt()]);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 5), () {
      if (_brightnessCharacteristic != null) {
        _brightnessCharacteristic!.write([(brightness * 250).toInt()]);
      }
    });
  }

  void setColor(Color color) {
    _color = color;
    notifyListeners();
    // _sendLampState();
  }

  void setNextAlarm(DateTime? nextAlarm) {
    _nextAlarm = nextAlarm;
    notifyListeners();
    // _sendLampState();
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
        // If the picked time is in the past, move it to the next day
        pickedDateTime.add(const Duration(days: 1));
      }
      setNextAlarm(pickedDateTime);
    } else {
      // If the cancel button is pressed, set nextAlarm to null
      setNextAlarm(null);
    }
  }

  void setSelectedAnimation(int selectedAnimation) {
    _selectedAnimation = selectedAnimation;
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
        ],
      ),
    );
  }
}
