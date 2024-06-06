// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class BLEService {

//   void connect(BuildContext context) {
//     var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
//     print(state);
//     if (state == BluetoothAdapterState.on) {
//         // usually start scanning, connecting, etc
//         // Start scanning w/ timeout
//         // Optional: use `stopScan()` as an alternative to timeout
//         await FlutterBluePlus.startScan(
//           withServices:[Guid("6932598e-c4fe-4855-9701-240a78abc000")], // match any of the specified services
//           withNames:["LED Zeppelin"], // *or* any of the specified names
//           timeout: Duration(seconds:15));

//         // wait for scanning to stop
//         await FlutterBluePlus.isScanning.where((val) => val == false).first;
//         // enable auto connect
//         //  - note: autoConnect is incompatible with mtu argument, so you must call requestMtu yourself
//         await device.connect(autoConnect:true, mtu:null)

//         // wait until connection
//         //  - when using autoConnect, connect() always returns immediately, so we must
//         //    explicity listen to `device.connectionState` to know when connection occurs 
//         await device.connectionState.where((val) => val == BluetoothConnectionState.connected).first;
//     } else {
//         // show an error to the user
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Bluetooth is off'),
//               content: const Text('Please turn on Bluetooth and grant the necessary permissions.'),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('OK'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     const RouteSettings(
//                       name: '/settings',
//                       arguments: 'bluetooth',);
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     });
//     }
// });
//   }

//   var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
//     print(state);
//     if (state == BluetoothAdapterState.on) {
//         // usually start scanning, connecting, etc
//     } else {
//         // show an error to the user, etc
//     }
// });

// }



