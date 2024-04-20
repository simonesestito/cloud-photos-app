import 'package:cloud_photos_app/widgets/spacer.dart';
import 'package:flutter/material.dart';

class LabeledIcon extends StatelessWidget {
  static const _kIconSize = 48.0;

  final Widget icon;
  final Widget text;

  const LabeledIcon({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconTheme(
            data: Theme.of(context).iconTheme.copyWith(size: _kIconSize),
            child: icon,
          ),
          const SpacerBox(),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyLarge!,
            child: text,
          ),
        ],
      ),
    );
  }
}
