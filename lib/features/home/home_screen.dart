import 'package:celebray/features/calendar/calendar_screen.dart';
import 'package:celebray/features/generator/generator_screen.dart';
import 'package:celebray/features/home/widgets/elegant_bottom_nav.dart';
import 'package:celebray/features/reminders/ui/reminders_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const RemindersScreen(),
      const CalendarScreen(),
      const GeneratorScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: ElegantBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
