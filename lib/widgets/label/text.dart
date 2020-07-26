import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twitter/utilities/widget.dart';

class CustomText extends StatelessWidget {
  final String message;
  final TextStyle style;
  final TextAlign align;
  final TextOverflow overflow;
  final bool softWrap;

  const CustomText(this.message,
      {Key key, this.style, this.align, this.overflow, this.softWrap = false});

  @override
  Widget build(BuildContext context) {
    if (message != null) {
      return Text(
        message,
        style: style ??
            TextStyle(
              fontSize: style.fontSize ??
                  Theme.of(context).textTheme.body1.fontSize -
                      (fullWidth(context) <= 375 ? 2 : 0),
            ),
        textAlign: align ?? TextAlign.justify,
        overflow: overflow,
        softWrap: softWrap,
        key: key,
      );
    }
    return SizedBox(
      height: 0,
      width: 0,
    );
  }
}
