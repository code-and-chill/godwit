import 'package:flutter/material.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';

class TappableIcon extends StatelessWidget {
  final double size;
  final bool isEnable;
  final Function onPressed1;
  final bool isBoolValue;
  final int id;
  final Function onPressed2;
  final bool isFontAwesomeRegular;
  final bool isFontAwesomeSolid;
  final bool isTwitterIcon;
  final Color iconColor;
  final EdgeInsetsGeometry padding;
  final int icon;

  const TappableIcon(this.icon,
      {this.size = 16,
      this.isEnable = false,
      this.onPressed1,
      this.isBoolValue,
      this.id,
      this.onPressed2,
      this.isFontAwesomeRegular = false,
      this.isTwitterIcon = false,
      this.isFontAwesomeSolid = false,
      this.iconColor,
      this.padding = const EdgeInsets.all(10)});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: 10,
      height: 10,
      padding: padding ?? EdgeInsets.all(10),
      shape: CircleBorder(),
      color: Colors.transparent,
      elevation: 0,
      onPressed: () {
        if (onPressed1 != null) {
          onPressed1(isBoolValue, id);
        } else if (onPressed2 != null) {
          onPressed2();
        }
      },
      child: TwitterIcon(
          icon: icon,
          size: size,
          isEnable: isEnable,
          isTwitterIcon: isTwitterIcon,
          isFontAwesomeRegular: isFontAwesomeRegular,
          isFontAwesomeSolid: isFontAwesomeSolid,
          iconColor: iconColor),
    );
  }
}
