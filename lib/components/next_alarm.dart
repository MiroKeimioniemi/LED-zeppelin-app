import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextAlarm extends StatelessWidget {
  final DateTime? nextAlarm;
  final double brightness;
  final bool isOn;
  final VoidCallback onAlarmTap; // Add this line

  const NextAlarm({
    Key? key,
    required this.nextAlarm,
    required this.brightness,
    required this.isOn,
    required this.onAlarmTap, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next Alarm:',
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
                      nextAlarm == null? '--:--' : DateFormat('HH:mm').format(nextAlarm!),
                      style: TextStyle(
                        fontSize: 64,
                        color: (brightness < 0.5 || !isOn)? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: (brightness < 0.5 || !isOn)? Colors.white : Colors.black,
                    onPressed: onAlarmTap, // Use the callback here
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