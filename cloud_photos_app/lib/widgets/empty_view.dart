import 'package:cloud_photos_app/widgets/labeled_icon.dart';
import 'package:flutter/material.dart';

class ListEmptyView extends StatelessWidget {
  const ListEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return LabeledIcon(
      icon: Icon(
        Icons.no_accounts,
        color: Theme.of(context).colorScheme.primary,
      ),
      text: const Text('No results'),
    );
  }
}
