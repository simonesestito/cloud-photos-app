import 'package:cloud_photos_app/preferences/preferences.dart';
import 'package:cloud_photos_app/screen/home_screen.dart';
import 'package:cloud_photos_app/screen/login_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final hasLogin = Preferences.instance.getLoginName() != null;

    return MaterialApp(
      title: 'Photos App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: hasLogin ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
