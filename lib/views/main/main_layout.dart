import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../map/map_screen.dart';
// RoutesScreen en standby por decisión de producto (Fase 0.1)
import '../profile/profile_screen.dart';
import '../../core/widgets/navigation/proxvel_bottom_navigation.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static MainLayoutState? of(BuildContext context) => context.findAncestorStateOfType<MainLayoutState>();

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    FavoritesScreen(),
    // RoutesScreen() — standby (Fase 0.1)
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
