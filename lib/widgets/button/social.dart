import 'package:flutter/material.dart';
import 'package:twitter/widgets/button/ripple.dart';
import 'package:twitter/widgets/label/title.dart';

class SocialButton extends StatelessWidget {
  final TitleText label;
  final Image imageAsset;
  final Function action;

  const SocialButton({
    this.action,
    this.label,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return RippleButton(
      onPressed: () {
        action(context);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0xffeeeeee),
              blurRadius: 15,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Wrap(
          children: <Widget>[
            imageAsset,
            SizedBox(width: 10),
            label,
          ],
        ),
      ),
    );
  }
}
