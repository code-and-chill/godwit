import 'package:flutter/material.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/label/title.dart';

class NotifyText extends StatelessWidget {
  final String subTitle;
  final String title;

  const NotifyText({Key key, this.subTitle, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TitleText(title, fontSize: 20, textAlign: TextAlign.center),
        SizedBox(
          height: 20,
        ),
        TitleText(
          subTitle,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.darkGrey,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
