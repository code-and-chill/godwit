import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/text.dart';

class ComposeBottomIconWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function(File) onImageIconSelected;

  ComposeBottomIconWidget(
      {Key key, this.textEditingController, this.onImageIconSelected})
      : super(key: key);

  @override
  _ComposeBottomIconWidgetState createState() =>
      _ComposeBottomIconWidgetState();
}

class _ComposeBottomIconWidgetState extends State<ComposeBottomIconWidget> {
  bool reachToWarning = false;
  bool reachToOver = false;
  Color wordCountColor;
  String tweet = '';

  @override
  void initState() {
    wordCountColor = Colors.blue;
    widget.textEditingController.addListener(() {
      setState(() {
        tweet = widget.textEditingController.text;
        if (widget.textEditingController.text != null &&
            widget.textEditingController.text.isNotEmpty) {
          if (widget.textEditingController.text.length > 259 &&
              widget.textEditingController.text.length < 280) {
            wordCountColor = Colors.orange;
          } else if (widget.textEditingController.text.length >= 280) {
            wordCountColor = Theme.of(context).errorColor;
          } else {
            wordCountColor = Colors.blue;
          }
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: fullWidth(context),
        height: 50,
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            color: Theme.of(context).backgroundColor),
        child: Row(
          children: <Widget>[
            IconButton(
                onPressed: () {
                  setImage(ImageSource.gallery);
                },
                icon: TwitterIcon(
                    icon: AppIcon.image, iconColor: AppColor.primary)),
            IconButton(
                onPressed: () {
                  setImage(ImageSource.camera);
                },
                icon: TwitterIcon(
                    icon: AppIcon.camera, iconColor: AppColor.primary)),
            Expanded(
                child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: tweet != null && tweet.length > 289
                      ? Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: CustomText('${280 - tweet.length}',
                              style: TextStyle(
                                  color: Theme.of(context).errorColor)),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              value: getTweetLimit(),
                              backgroundColor: Colors.grey,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(wordCountColor),
                            ),
                            tweet.length > 259
                                ? CustomText('${280 - tweet.length}',
                                    style: TextStyle(color: wordCountColor))
                                : CustomText('',
                                    style: TextStyle(color: wordCountColor))
                          ],
                        )),
            ))
          ],
        ),
      ),
    );
  }

  void setImage(ImageSource source) {
    ImagePicker.pickImage(source: source, imageQuality: 20).then((File file) {
      setState(() {
        widget.onImageIconSelected(file);
      });
    });
  }

  double getTweetLimit() {
    if (tweet == null || tweet.isEmpty) {
      return 0.0;
    }
    if (tweet.length > 280) {
      return 1.0;
    }
    var length = tweet.length;
    var val = length * 100 / 28000.0;
    return val;
  }
}
