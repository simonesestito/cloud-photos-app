import 'package:cloud_photos_app/widgets/labeled_icon.dart';
import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final Object error;

  const AppErrorWidget(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabeledIcon(
      icon: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      ),
      text: Text(error.toString()),
    );
  }
}
