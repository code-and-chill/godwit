import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/navigation/ink_well.dart';

import 'geometry.dart';

Widget customTitleText(String title, {BuildContext context}) {
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

Widget customNetworkImage(String path, {BoxFit fit = BoxFit.contain}) {
  return CachedNetworkImage(
    fit: fit,
    imageUrl: path ?? mockProfilePicture,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: fit,
        ),
      ),
    ),
    placeholderFadeInDuration: Duration(milliseconds: 500),
    placeholder: (context, url) => Container(
      color: Color(0xffeeeeee),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

dynamic customAdvanceNetworkImage(String path) {
  if (path == null) {
    path = mockProfilePicture;
  }
  return CachedNetworkImageProvider(
    path ?? mockProfilePicture,
  );
}

void showAlert(BuildContext context,
    {@required Function onPressedOk,
      @required String title,
      String okText = 'OK',
      String cancelText = 'Cancel'}) async {
  showDialog(
      context: context,
      builder: (context) {
        return customAlert(context,
            onPressedOk: onPressedOk,
            title: title,
            okText: okText,
            cancelText: cancelText);
      });
}

Widget customAlert(BuildContext context,
    {@required Function onPressedOk,
      @required String title,
      String okText = 'OK',
      String cancelText = 'Cancel'}) {
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
          onPressedOk();
        },
        child: Text(okText),
      )
    ],
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

Widget emptyListWidget(BuildContext context, String title,
    {String subTitle, String image = 'emptyImage.png'}) {
  return Container(
    color: Color(0xfffafafa),
    child: Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: fullWidth(context) * .95,
            height: fullWidth(context) * .95,
            decoration: BoxDecoration(
              // color: Color(0xfff1f3f6),
              boxShadow: <BoxShadow>[
                // BoxShadow(blurRadius: 50,offset: Offset(0, 0),color: Color(0xffe2e5ed),spreadRadius:20),
                BoxShadow(
                  offset: Offset(0, 0),
                  color: Color(0xffe2e5ed),
                ),
                BoxShadow(
                    blurRadius: 50,
                    offset: Offset(10, 0),
                    color: Color(0xffffffff),
                    spreadRadius: -5),
              ],
              shape: BoxShape.circle,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/$image', height: 170),
              SizedBox(
                height: 20,
              ),
              CustomText(
                title,
                style: Theme
                    .of(context)
                    .typography
                    .dense
                    .display1
                    .copyWith(color: Color(0xff9da9c7)),
              ),
              CustomText(
                subTitle,
                style: Theme
                    .of(context)
                    .typography
                    .dense
                    .body2
                    .copyWith(color: Color(0xffabb8d6)),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Widget loader() {
  if (Platform.isIOS) {
    return Center(
      child: CupertinoActivityIndicator(),
    );
  } else {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }
}

Widget customSwitcherWidget(
    {@required child, Duration duraton = const Duration(milliseconds: 500)}) {
  return AnimatedSwitcher(
    duration: duraton,
    transitionBuilder: (Widget child, Animation<double> animation) {
      return ScaleTransition(child: child, scale: animation);
    },
    child: child,
  );
}

Widget customExtendedText(String text, bool isExpanded,
    {BuildContext context,
    TextStyle style,
    @required Function onPressed,
    @required TickerProvider provider,
    AlignmentGeometry alignment = Alignment.topRight,
    @required EdgeInsetsGeometry padding,
    int wordLimit = 100,
    bool isAnimated = true}) {
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

Widget customListTile(BuildContext context,
    {Widget title,
      Widget subtitle,
      Widget leading,
      Widget trailing,
      Function onTap}) {
  return CustomInkWell(
    splashColor: Theme
        .of(context)
        .primaryColorLight,
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
                      TextStyle(color: Theme
                          .of(context)
                          .backgroundColor),
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
