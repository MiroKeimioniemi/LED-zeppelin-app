import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/midground.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => lampState(),
      child: const LEDZeppelinApp(),
    ),
  );
}

// App state
class lampState extends ChangeNotifier {

  // Lamp state variables
  bool _isOn = false;
  int _brightness = 100;
  Color _color = Colors.white;
  int _selectedAnimation = 1;
  DateTime _nextAlarm = DateTime.now();

  // Getters
  bool get isOn => _isOn;
  int get brightness => _brightness;
  Color get color => _color;
  int get selectedAnimation => _selectedAnimation;
  DateTime get nextAlarm => _nextAlarm;

  // Update functions
  void toggle() {
    _isOn = !_isOn;
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            Midground(color: Provider.of<lampState>(context).color),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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