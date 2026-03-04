import 'package:flutter/material.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/app_drawer.dart';
import 'package:health_safety_inspection/widgets/custom_bottom_nav.dart';
import 'package:health_safety_inspection/screens/dashboard_screen.dart';
import 'package:health_safety_inspection/screens/inspections_screen.dart';
import 'package:health_safety_inspection/screens/sites_screen.dart';
import 'package:health_safety_inspection/screens/settings_screen.dart';

/// Global key so any PageHeader can open the drawer.
final GlobalKey<ScaffoldState> shellScaffoldKey = GlobalKey<ScaffoldState>();

class HomeScreen extends StatefulWidget {
  final int initialTab;

  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  static const _pages = <Widget>[
    DashboardScreen(),
    InspectionsScreen(),
    SitesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: shellScaffoldKey,
      backgroundColor: AppColors.backgroundColor(context),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onTabSelected: (index) => setState(() => _currentIndex = index),
      ),
      drawerEdgeDragWidth: 40,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
