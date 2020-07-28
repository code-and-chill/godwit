import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final Widget image;

  BannerImage({this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 180, padding: EdgeInsets.only(top: 28), child: image);
  }
}
