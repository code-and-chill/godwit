import 'package:flutter/material.dart';
import 'package:twitter/widgets/label/text.dart';

class ExtendedText extends StatelessWidget {
  final String text;
  final bool isExpanded;
  final TextStyle style;
  final Function onPressed;
  final TickerProvider provider;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;
  final int wordLimit;
  final bool isAnimated;

  ExtendedText(this.onPressed, this.provider, this.padding,
      {this.text,
      this.isExpanded,
      this.style,
      this.alignment = Alignment.topRight,
      this.wordLimit = 100,
      this.isAnimated = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedSize(
          vsync: provider,
          duration: Duration(milliseconds: (isAnimated ? 500 : 0)),
          child: ConstrainedBox(
            constraints: isExpanded
                ? BoxConstraints()
                : BoxConstraints(maxHeight: wordLimit == 100 ? 100.0 : 260.0),
            child: CustomText(text,
                softWrap: true,
                overflow: TextOverflow.fade,
                style: style,
                align: TextAlign.start),
          ),
        ),
        text != null && text.length > wordLimit
            ? Container(
                alignment: alignment,
                child: InkWell(
                  onTap: onPressed,
                  child: Padding(
                    padding: padding,
                    child: Text(
                      !isExpanded ? 'more...' : 'Less...',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
