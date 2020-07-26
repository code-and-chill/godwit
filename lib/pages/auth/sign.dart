import 'package:flutter/material.dart';
import 'package:twitter/widgets/label/text.dart';

class Sign extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String type;
  final Widget body;

  Sign({this.scaffoldKey, this.type, this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: CustomText(
          type,
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child: body),
    );
  }
}
