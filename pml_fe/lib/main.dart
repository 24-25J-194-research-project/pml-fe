import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/landing_page.dart';
import 'pages/pml_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';
import 'pages/recipie_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/recipie_detail_page.dart';
import 'pages/interactive_cooking_page.dart';
import 'pages/companion_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // ✅ Initialize Flutter bindings at the very beginning
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Request permissions after initialization
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await requestMicrophonePermission();
  });

  runApp(DementiaCookingApp());
}

Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.request();
  if (status.isGranted) {
    print("Microphone permission granted");
  } else if (status.isDenied) {
    print("Microphone permission denied");
  } else if (status.isPermanentlyDenied) {
    print(
      "Microphone permission permanently denied. Please enable it from settings.",
    );
    openAppSettings(); // ✅ Opens app settings if permission is permanently denied
  }
}

class DementiaCookingApp extends StatelessWidget {
  DementiaCookingApp({super.key});

  // Define app routes
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => LandingPage()),
      GoRoute(path: '/pml', builder: (context, state) => PMLPage()),
      GoRoute(path: '/companion', builder: (context, state) => CompanionPage()),
      GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
      GoRoute(path: '/recipes', builder: (context, state) => RecipePage()),
      GoRoute(
        path: '/recipe-details',
        builder: (context, state) {
          final recipe =
              state.extra as Map<String, dynamic>; // ✅ Pass data through extra
          return RecipeDetailPage(recipe: recipe);
        },
      ),
      GoRoute(
        path: '/interactive-cooking',
        builder: (context, state) {
          final recipe = state.extra as Map<String, dynamic>;
          return InteractiveCookingPage(recipe: recipe);
        },
      ),
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
