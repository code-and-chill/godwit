import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  final Color splashColor;
  final Function(bool, int) function1;
  final Function onPressed;
  final bool isEnable;
  final int no;
  final Color color;
  final Widget child;
  final BorderRadius radius;

  CustomInkWell(
      {this.child,
      this.function1,
      this.onPressed,
      this.isEnable = false,
      this.no = 0,
      this.color = Colors.transparent,
      this.splashColor,
      this.radius});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          if (function1 != null) {
            function1(isEnable, no);
          } else if (onPressed != null) {
            onPressed();
          }
        },
        splashColor: splashColor,
        child: child,
      ),
    );
  }
}
