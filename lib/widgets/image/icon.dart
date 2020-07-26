import 'package:flutter/material.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/text.dart';

class CustomIcon extends StatelessWidget {
  final String text;
  final int icon;
  final Function onPressed;
  final IconData sysIcon;
  final Color iconColor;
  final double size;

  const CustomIcon(
      {this.text,
      this.icon,
      this.onPressed,
      this.sysIcon,
      this.iconColor,
      this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                if (onPressed != null) onPressed();
              },
              icon: sysIcon != null
                  ? Icon(sysIcon, color: iconColor, size: size)
                  : TwitterIcon(
                      size: size,
                      icon: icon,
                      iconColor: iconColor,
                    ),
            ),
            CustomText(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
                fontSize: size - 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
