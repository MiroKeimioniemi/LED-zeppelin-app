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
            builder: (context, lampState, child) => GradientBackground(
              isOn: lampState.isOn,
              color: lampState.color,
              brightness: lampState.brightness,
            ),
          ),
          // CelestialBody widget is the sun/moon element that indicates the brightness level and the selected color
          Consumer<LampState>(
            builder: (context, lampState, child) => CelestialBody(
                isDay: true,
                brightness: lampState.brightness,
                color: lampState.color),
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
            children: [
              Consumer<LampState>(
                builder: (context, lampState, child) => Slider(
                    value: lampState.brightness,
                    max: 1.0,
                    // divisions: 250,
                    // label: '${(lampState.brightness * 100).toInt()}%',
                    onChanged: (double value) {
                      lampState.setBrightness(value);
                    }),
              ),
              Consumer<LampState>(
                builder: (context, lampState, child) => IconButton(
                  icon: Icon(Icons.color_lens),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: HueRingPicker(
                            pickerColor: lampState.color,
                            hueRingStrokeWidth: 30,
                            onColorChanged: (Color color) {
                              lampState.setColor(color);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
