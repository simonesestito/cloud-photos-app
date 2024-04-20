import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cloud_photos_app/preferences/preferences.dart';
import 'package:cloud_photos_app/screen/home_screen.dart';
import 'package:cloud_photos_app/screen/login_screen.dart';
import 'package:cloud_photos_app/screen/single_image_screen.dart';
import 'package:cloud_photos_app/screen/user_details_screen.dart';
import 'package:cloud_photos_app/screen/user_search_results_screen.dart';
import 'package:cloud_photos_app/widgets/window_title_bar.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.ensureInitialized();

  // From the docs: https://github.com/bitsdojo/bitsdojo_window?tab=readme-ov-file#flutter-app-integration
  doWhenWindowReady(() {
    const initialSize = Size(1000, 800);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = WindowTitleBar.appName;
    appWindow.show();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final hasLogin = Preferences.instance.getLoginName() != null;

    return WindowBorder(
      color: Colors.black38,
      width: 1,
      child: MaterialApp(
        title: WindowTitleBar.appName,
        theme: _createTheme(),
        debugShowCheckedModeBanner: false,
        initialRoute: hasLogin ? HomeScreen.kRouteName : LoginScreen.kRouteName,
        routes: {
          LoginScreen.kRouteName: (context) => const LoginScreen(),
          HomeScreen.kRouteName: (context) => const HomeScreen(),
          UserSearchResultsScreen.kRouteName: (_) =>
              const UserSearchResultsScreen(),
          UserDetailsScreen.kRouteName: (_) => const UserDetailsScreen(),
          SingleImageScreen.kRouteName: (_) => const SingleImageScreen(),
        },
      ),
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
