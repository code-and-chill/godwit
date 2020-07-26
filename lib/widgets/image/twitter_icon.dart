import 'package:flutter/material.dart';

class TwitterIcon extends StatelessWidget {
  final int icon;
  final bool isEnable;
  final double size;
  final bool isTwitterIcon;
  final bool isFontAwesomeRegular;
  final bool isFontAwesomeSolid;
  final Color iconColor;
  final double paddingIcon;

  const TwitterIcon({
    this.icon,
    this.isEnable = false,
    this.size = 18,
    this.isTwitterIcon = true,
    this.isFontAwesomeRegular = false,
    this.isFontAwesomeSolid = false,
    this.iconColor,
    this.paddingIcon = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTwitterIcon ? paddingIcon : 0),
      child: Icon(
        IconData(icon,
            fontFamily: isTwitterIcon
                ? 'TwitterIcon'
                : isFontAwesomeRegular
                    ? 'AwesomeRegular'
                    : isFontAwesomeSolid ? 'AwesomeSolid' : 'Fontello'),
        size: size,
        color: isEnable ? Theme.of(context).primaryColor : iconColor,
      ),
    );
  }
}
