// Import the necessary libraries
import 'dart:async';                // Asynchronous functions such as await and Future

import 'package:flutter/material.dart';                         // Material design widgets such as Scaffold, Stack, Column, Row, Slider, IconButton, Icon, AlertDialog, etc.
import 'package:flutter/services.dart';                         // Services such as SystemChrome for setting the preferred orientation
import 'package:flutter_colorpicker/flutter_colorpicker.dart';  // Color picker widget
import 'package:provider/provider.dart';                        // Provider for managing the state of the app

import 'components/alarm_animations_list.dart';  // AlarmAnimationsList widget for displaying the list of animations
import 'components/celestial.dart';              // CelestialBody widget for displaying the sun element
import 'components/next_alarm.dart';             // NextAlarm widget for displaying the next alarm time
import 'components/gradient_background.dart';    // GradientBackground widget for displaying the background gradient
import 'components/midground.dart';
import 'lamp_state.dart';              // Midground widget for displaying the topmost background element

// Main function to run the flutter app
void main() {
  // Ensure that the app always runs in portrait mode by setting the preferred orientation after initializing the widgets
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(
            // Use the ChangeNotifierProvider to provide the LampState as the BuildContext to the entire app defined in the LEDZeppelinApp widget
            ChangeNotifierProvider(
              create: (context) => LampState(),
              child: const LEDZeppelinApp(),
            ),
          ));
}

// LEDZeppelinApp class to define the root widget of the application
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

// MyHomePage class to define the main page of the application
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// MyHomePageState class to manage the state of the main page
class _MyHomePageState extends State<MyHomePage> {
  // Function to bring up the color picker dialog to select the lamp color
  Future<void> _selectTime(BuildContext context) async {
    await Provider.of<LampState>(context, listen: false).selectTime(context);
  }

  // Main build function to define the layout of the main page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Stack widget to overlay the background elements with the foreground elements
      body: Stack(
        children: <Widget>[
          // The bottom-most background element
          // Consumer widget listens to the LampState changes and rebuilds the widget it wraps accordingly using its builder function
          Consumer<LampState>(
            // GestureDetector widget listens to the tap event and toggles the lamp state between on and off
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
          // CelestialBody widget is the sun element that indicates the brightness level and the selected color
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
          // Midground widget is the topmost background element that also responds to the brightness level and color of the lamp
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
          // Column widget to stack the foreground elements
          Column(
            children: [
              // SizedBox widget to provide vertical spacing between the foreground elements
              const SizedBox(height: 96),
              Consumer<LampState>(
                // The custom NextAlarm widget displays the next alarm time and allows the user to set a new alarm time
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
              // Row widget to align the slider and color picker button horizontally
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Expanded widget to allow the slider to take up the remaining space
                  Expanded(
                    child: Consumer<LampState>(
                      // Slider widget to adjust the brightness level of the lamp
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
                      // IconButton widget to bring up the color picker dialog
                      child: IconButton(
                        icon: const Icon(
                          Icons.color_lens,
                          shadows: [
                            Shadow(color: Colors.black38, blurRadius: 16.0)
                          ],
                        ),
                        color: Colors.white,
                        iconSize: 36,
                        // Function to bring up the color picker dialog
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
                  // AlarmAnimationsList widget displays the list of available animations
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
              // AlertDialog widget to prompt the user to turn on the lamp and Bluetooth that persists until the lamp is connected
              if (!lampState.isConnected) {
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
