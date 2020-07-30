import 'package:flutter/material.dart';
import 'package:twitter/utilities/geometry.dart';
import 'package:twitter/widgets/label/text.dart';

class CustomAlert extends StatelessWidget {
  final Function onPressed;
  final String title;
  final String okText;
  final String cancelText;

  CustomAlert(this.onPressed, this.title,
      {this.okText = 'OK', this.cancelText = 'Cancel'});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Alert',
          style: TextStyle(
              fontSize: getDimension(context, 25), color: Colors.black54)),
      content: CustomText(title, style: TextStyle(color: Colors.black45)),
      actions: <Widget>[
        FlatButton(
          textColor: Colors.grey,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(cancelText),
        ),
        FlatButton(
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.pop(context);
            onPressed();
          },
          child: Text(okText),
        )
      ],
    );
  }
}
