import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AlarmAnimationsList extends StatelessWidget {
  final int selectedAnimation;
  final Color color;
  final Function(int) onAnimationSelected;

  AlarmAnimationsList({
    super.key,
    required this.selectedAnimation,
    required this.color,
    required this.onAnimationSelected,
  });

  final List<AlarmAnimation> alarmAnimations = [
    AlarmAnimation(
      title: 'Red Dawn',
      duration: '10min',
      gradient: const LinearGradient(
        colors: [Color(0xFFFFC047), Color(0xFF6F1515), Color(0xFF2C0D0D)],
        stops: [0, 0.74, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    AlarmAnimation(
      title: 'Intruder Alert',
      duration: '10sec',
      gradient: const LinearGradient(
        colors: [Colors.red, Colors.blue],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    AlarmAnimation(
      title: 'Brighten Up',
      duration: '1min',
      gradient: const LinearGradient(
        colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 140, 140, 140)
        ],
        stops: [0, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const itemHeight =
        120.0; // Adjust this value to match the height of your items
    final controller = ScrollController();

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.idle &&
            !controller.position.isScrollingNotifier.value) {
          final index = (controller.offset / itemHeight).round();
          Future.delayed(Duration.zero, () {
            controller.animateTo(
              index * itemHeight,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
            );
          });
        }
        return true;
      },
      child: ListView.builder(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: alarmAnimations.length,
        itemBuilder: (context, index) {
          final animation = alarmAnimations[index];
          return Card(
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color:
                    index == selectedAnimation - 1 ? color : Colors.transparent,
                width: 4.0,
              ),
            ),
            elevation: 10,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              title: Text(
                animation.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(animation.duration),
              leading: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: animation.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () {
                onAnimationSelected(index + 1);
              },
            ),
          );
        },
      ),
    );
  }
}

class AlarmAnimation {
  final String title;
  final String duration;
  final Gradient gradient;

  AlarmAnimation({
    required this.title,
    required this.duration,
    required this.gradient,
  });
}
