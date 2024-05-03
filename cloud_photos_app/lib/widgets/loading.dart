import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  static const kLoadingSize = 48.0;

  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: kLoadingSize,
        width: kLoadingSize,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
