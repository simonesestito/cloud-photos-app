import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget createAppBarWithWindowBar({
  Widget? title,
  List<Widget>? actions,
  Color? backgroundColor,
}) =>
    WindowTitleBar(
      backgroundColor: backgroundColor,
      child: AppBar(
        title: title,
        actions: actions,
        backgroundColor: backgroundColor,
      ),
    );

class WindowTitleBar extends StatelessWidget implements PreferredSizeWidget {
  static const appName = 'Cloud Photos App';
  final PreferredSizeWidget child;
  final Color? backgroundColor;

  const WindowTitleBar({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WindowTitleBarBox(
          child: Stack(
            children: [
              SizedBox.expand(child: Material(color: backgroundColor)),
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Text(appName),
                  Expanded(child: MoveWindow()),
                  MinimizeWindowButton(),
                  MaximizeWindowButton(),
                  CloseWindowButton(),
                ],
              ),
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
