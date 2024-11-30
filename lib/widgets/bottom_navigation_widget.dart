import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow_outlined), label: 'Shorts'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 40), label: ''),
        BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined), label: 'Subscriptions'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'You'),
      ],
    );
  }
}
