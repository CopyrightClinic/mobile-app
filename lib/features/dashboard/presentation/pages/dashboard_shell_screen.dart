import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dashboard_bottom_navigation.dart';

class DashboardShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: navigationShell, bottomNavigationBar: DashboardBottomNavigation(navigationShell: navigationShell));
  }
}
