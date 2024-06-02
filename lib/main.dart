import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:led_zeppelin_app/components/celestial.dart';
import 'package:provider/provider.dart';

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
  // Lamp state variables
  bool _isOn = true;
  double _brightness = 1;
  Color _color = Colors.white; // Deal with black
  int _selectedAnimation = 1;
  DateTime _nextAlarm = DateTime.now();

  // Getters
  bool get isOn => _isOn;
  double get brightness => _brightness;
  Color get color => _color;
  int get selectedAnimation => _selectedAnimation;
  DateTime get nextAlarm => _nextAlarm;

  // Update functions
  void toggle() {
    _isOn = !_isOn;
    notifyListeners();
  }

  void setBrightness(double brightness) {
    _brightness = brightness;
    notifyListeners();
  }

  void setColor(Color color) {
    _color = color;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Expanded(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Consumer<LampState>(
                    builder: (context, lampState, child) => Slider(
                        value: lampState.brightness,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (double value) {
                          lampState.setBrightness(value);
                        }),
                ),
              ),
              Consumer<LampState>(
                builder: (context, lampState, child) => Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: SingleChildScrollView(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  textTheme: Theme.of(context).textTheme.apply(
                                    bodyColor: Colors.white,
                                    displayColor: Colors.white,
                                  ),
                                ),
                                child: HueRingPicker(
                                  pickerColor: lampState.color,
                                  hueRingStrokeWidth: 30,
                                  displayThumbColor: false,
                                  onColorChanged: (Color color) {
                                    if (color.red == color.green && color.green == color.blue) {
                                      lampState.setColor(Colors.white);
                                    } else {
                                      lampState.setColor(HSLColor.fromColor(color).withLightness(0.7).withSaturation(1).toColor());
                                    }
                                  },
                                ),
                              )
                            ),
                          );
                        },
                      );
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
