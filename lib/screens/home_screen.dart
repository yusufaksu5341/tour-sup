import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.camera_alt_outlined),
        selectedIcon: const Icon(Icons.camera_alt),
        label: l10n.navScan,
      ),
      NavigationDestination(
        icon: const Icon(Icons.local_taxi_outlined),
        selectedIcon: const Icon(Icons.local_taxi),
        label: l10n.navTaxi,
      ),
      NavigationDestination(
        icon: const Icon(Icons.sos_outlined),
        selectedIcon: const Icon(Icons.sos),
        label: l10n.navEmergency,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outlined),
        selectedIcon: const Icon(Icons.person),
        label: l10n.navProfile,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: destinations,
      ),
    );
  }
}
