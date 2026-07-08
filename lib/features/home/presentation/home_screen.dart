import 'package:celebray/features/calendar/presentation/calendar_screen.dart';
import 'package:celebray/features/generator/presentation/generator_screen.dart';
import 'package:celebray/features/home/widgets/elegant_bottom_nav.dart';
import 'package:celebray/features/notifications/notification_navigation_handler.dart';
import 'package:celebray/features/reminders/presentation/reminders_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigationHandler.consumePendingNavigation();
    });
  }

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
