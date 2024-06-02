import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
}

class LEDZeppelinApp extends StatelessWidget {
  const LEDZeppelinApp({super.key});

  // Application root widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Zeppelin App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
              color: lampState.color
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
          Consumer<LampState>(
            builder: (context, lampState, child) => 
              Slider(value: lampState.brightness, onChanged: (double value) {lampState.setBrightness(value);}),
            ),
          
        ],
      ),
    );
  }
}


// ChatGPT version


// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sun and Moon Slider',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   double _sliderValue = 0.5;
//   Color _selectedColor = Colors.orange;
//   List<TimeOfDay> _alarms = [];

//   void _openColorPicker() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Pick a color'),
//           content: SingleChildScrollView(
//             child: ColorPicker(
//               pickerColor: _selectedColor,
//               onColorChanged: (Color color) {
//                 setState(() {
//                   _selectedColor = color;
//                 });
//               },
//             ),
//           ),
//           actions: <Widget>[
//             ElevatedButton(
//               child: Text('Got it'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _setAlarm() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _alarms.add(picked);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sun and Moon Slider'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.alarm_add),
//             onPressed: _setAlarm,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [_selectedColor.withOpacity(0.5), Colors.black],
//                 stops: [_sliderValue, _sliderValue],
//               ),
//             ),
//           ),
//           Column(
//             children: <Widget>[
//               Expanded(
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       left: MediaQuery.of(context).size.width / 2 - 50,
//                       bottom: _sliderValue * MediaQuery.of(context).size.height - 100,
//                       child: Icon(
//                         _sliderValue < 0.5 ? Icons.nightlight_round : Icons.wb_sunny,
//                         color: Colors.white,
//                         size: 100,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Slider(
//                 value: _sliderValue,
//                 onChanged: (double value) {
//                   setState(() {
//                     _sliderValue = value;
//                   });
//                 },
//               ),
//               ElevatedButton(
//                 onPressed: _openColorPicker,
//                 child: Text('Pick Color'),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _alarms.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(
//                         _alarms[index].format(context),
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }