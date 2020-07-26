import 'package:flutter/material.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/label/notify.dart';

import '../../utilities/widget.dart';

class EmptyList extends StatelessWidget {
  EmptyList(this.title, {this.subTitle});

  final String subTitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: fullHeight(context) - 135,
        color: TwitterColor.mystic,
        child: NotifyText(
          title: title,
          subTitle: subTitle,
        ));
  }
}
