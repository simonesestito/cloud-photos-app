import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget createAppBarWithWindowBar(
        {Widget? title, List<Widget>? actions}) =>
    WindowTitleBar(child: AppBar(title: title, actions: actions));

class WindowTitleBar extends StatelessWidget implements PreferredSizeWidget {
  static const appName = 'Cloud Photos App';
  final PreferredSizeWidget child;

  const WindowTitleBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WindowTitleBarBox(
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Text(appName),
              Expanded(child: MoveWindow()),
              MinimizeWindowButton(),
              MaximizeWindowButton(),
              CloseWindowButton(),
            ],
          ),
        ),
        child,
      ],
    );
  }

  @override
  Size get preferredSize {
    final barHeight = appWindow.titleBarHeight + child.preferredSize.height;
    return Size(child.preferredSize.width, barHeight);
  }
}
