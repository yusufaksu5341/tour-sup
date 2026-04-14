import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'taxi_screen.dart';
import 'emergency_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ScanScreen(),
    TaxiScreen(),
    EmergencyScreen(),
    ProfileScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.camera_alt_outlined),
      selectedIcon: Icon(Icons.camera_alt),
      label: 'Tara',
    ),
    NavigationDestination(
      icon: Icon(Icons.local_taxi_outlined),
      selectedIcon: Icon(Icons.local_taxi),
      label: 'Taksi',
    ),
    NavigationDestination(
      icon: Icon(Icons.sos_outlined),
      selectedIcon: Icon(Icons.sos),
      label: 'Acil',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TourSup'),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: _destinations,
      ),
    );
  }
}
