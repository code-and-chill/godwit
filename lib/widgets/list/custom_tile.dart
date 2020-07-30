import 'package:flutter/material.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/navigation/ink_well.dart';

class CustomListTile extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Widget leading;
  final Widget trailing;
  final Function onTap;

  CustomListTile(
      {this.title, this.subtitle, this.leading, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      splashColor: Theme.of(context).primaryColorLight,
      radius: BorderRadius.circular(0.0),
      onPressed: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Container(
              width: 40,
              height: 40,
              child: leading,
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              width: fullWidth(context) - 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: title ?? Container()),
                      trailing ?? Container(),
                    ],
                  ),
                  subtitle
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
