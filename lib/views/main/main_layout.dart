import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../map/map_screen.dart';
import '../routes/routes_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/navigation/proxvel_bottom_navigation.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    FavoritesScreen(),
    RoutesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: ProxvelBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
