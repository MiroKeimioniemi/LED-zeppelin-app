import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextAlarm extends StatelessWidget {
  
  final DateTime nextAlarm;
  final double brightness;
  final bool isOn;

  const NextAlarm({super.key, required this.nextAlarm, required this.brightness, required this.isOn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next Sunrise:',
              style: TextStyle(
                fontSize: 16,
                color: (brightness < 0.5 || !isOn)? Colors.white : Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 42.0), // Adjust this value as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      DateFormat('hh:mm').format(nextAlarm),
                      style: TextStyle(
                        fontSize: 64,
                        color: (brightness < 0.5 || !isOn)? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: (brightness < 0.5 || !isOn)? Colors.white : Colors.black,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}