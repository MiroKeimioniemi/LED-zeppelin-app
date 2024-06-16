import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// NextAlarm widget displays the time of the next alarm and an edit button
class NextAlarm extends StatelessWidget {
  final DateTime? nextAlarm;
  final double brightness;
  final bool isOn;
  final VoidCallback onAlarmTap;

  // NextAlarm widget constructor with nextAlarm, brightness, isOn and onAlarmTap parameters
  const NextAlarm({
    Key? key,
    required this.nextAlarm,
    required this.brightness,
    required this.isOn,
    required this.onAlarmTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return a centered column with the text 'Next Alarm:' and the time of the next alarm along with a pen icon button to edit the alarm to the right of it
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
              padding: const EdgeInsets.only(left: 42.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      // Ternary operator to check if nextAlarm is null and display '--:--' if it is, otherwise format the time using the DateFormat class
                      nextAlarm == null? '--:--' : DateFormat('HH:mm').format(nextAlarm!),
                      style: TextStyle(
                        fontSize: 64,
                        // If the brightness is less than 0.5 or the lamp is off, the text color is white, otherwise it is black so that there is enough contrast
                        color: (brightness < 0.5 || !isOn)? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: (brightness < 0.5 || !isOn)? Colors.white : Colors.black,
                    onPressed: onAlarmTap,
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