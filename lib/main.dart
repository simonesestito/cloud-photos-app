import 'package:cloud_photos_app/preferences/preferences.dart';
import 'package:cloud_photos_app/screen/home_screen.dart';
import 'package:cloud_photos_app/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
      theme: _createTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: hasLogin ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }

  ThemeData _createTheme() => ThemeData(
        colorScheme: _createColorScheme(),
        elevatedButtonTheme: _createElevatedButtonTheme(),
        searchBarTheme: _createSearchBarTheme(),
        inputDecorationTheme: _createInputDecoration(),
      );

  ColorScheme _createColorScheme() =>
      ColorScheme.fromSeed(seedColor: Colors.green);

  ElevatedButtonThemeData _createElevatedButtonTheme() =>
      const ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStatePropertyAll(EdgeInsets.all(24)),
          elevation: MaterialStatePropertyAll(4),
        ),
      );

  SearchBarThemeData _createSearchBarTheme() => const SearchBarThemeData(
        elevation: MaterialStatePropertyAll(0),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );

  InputDecorationTheme _createInputDecoration() => const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      );
}
