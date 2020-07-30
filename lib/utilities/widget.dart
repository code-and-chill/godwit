import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/image/network_image.dart';

import 'geometry.dart';

Widget customText(String title, {BuildContext context}) {
  return Text(
    title ?? '',
    style: TextStyle(
      color: Colors.black87,
      fontFamily: 'HelveticaNeue',
      fontWeight: FontWeight.w900,
      fontSize: 20,
    ),
  );
}

Widget heading(String heading,
    {double horizontalPadding = 10, BuildContext context}) {
  double fontSize = 16;
  if (context != null) {
    fontSize = getDimension(context, 16);
  }
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: Text(
      heading,
      style: AppTheme.apptheme.typography.dense.display1
          .copyWith(fontSize: fontSize),
    ),
  );
}

Widget customImage(
  BuildContext context,
  String path, {
  double height = 50,
  bool isBorder = false,
}) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade100, width: isBorder ? 2 : 0),
    ),
    child: CircleAvatar(
      maxRadius: height / 2,
      backgroundColor: Theme.of(context).cardColor,
      backgroundImage: customAdvanceNetworkImage(path ?? mockProfilePicture),
    ),
  );
}

double fullWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double fullHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

SizedBox sizedBox({double height = 5, String title}) {
  return SizedBox(
    height: title == null || title.isEmpty ? 0 : height,
  );
}

void customSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String msg,
    {double height = 30, Color backgroundColor = Colors.black}) {
  if (_scaffoldKey == null || _scaffoldKey.currentState == null) {
    return;
  }
  _scaffoldKey.currentState.hideCurrentSnackBar();
  final snackBar = SnackBar(
    backgroundColor: backgroundColor,
    content: Text(
      msg,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  );
  _scaffoldKey.currentState.showSnackBar(snackBar);
}

openImagePicker(BuildContext context, Function onImageSelected) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 100,
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(
              'Pick an image',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Use Camera',
                      style:
                          TextStyle(color: Theme.of(context).backgroundColor),
                    ),
                    onPressed: () {
                      getImage(context, ImageSource.camera, onImageSelected);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: FlatButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Use Gallery',
                      style:
                      TextStyle(color: Theme
                          .of(context)
                          .backgroundColor),
                    ),
                    onPressed: () {
                      getImage(context, ImageSource.gallery, onImageSelected);
                    },
                  ),
                )
              ],
            )
          ],
        ),
      );
    },
  );
}

getImage(BuildContext context, ImageSource source, Function onImageSelected) {
  ImagePicker.pickImage(source: source, imageQuality: 50).then((File file) {
    onImageSelected(file);
    Navigator.pop(context);
  });
}
