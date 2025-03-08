import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/landing_page.dart';
import 'pages/pml_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(DementiaCookingApp());
}

class DementiaCookingApp extends StatelessWidget {
  DementiaCookingApp({super.key});

  // Define app routes
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => LandingPage()),
      GoRoute(path: '/pml', builder: (context, state) => PMLPage()),
      GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
