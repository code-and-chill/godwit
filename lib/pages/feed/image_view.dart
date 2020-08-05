import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/feed/feed.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/icons_row.dart';
import 'package:twitter/widgets/image/network_image.dart';

class ImageViewPge extends StatefulWidget {
  ImageViewPageState createState() => ImageViewPageState();
}

class ImageViewPageState extends State<ImageViewPge> {
  bool isToolAvailable = true;

  FocusNode focusNode;
  TextEditingController textEditingController;

  @override
  void initState() {
    focusNode = FocusNode();
    textEditingController = TextEditingController();
    super.initState();
  }

  Widget _body() {
    var state = Provider.of<FeedState>(context);
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            color: Colors.brown.shade700,
            constraints: BoxConstraints(
              maxHeight: fullHeight(context),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  isToolAvailable = !isToolAvailable;
                });
              },
              child: state.getTweetDetails.last.imagePath == null
                  ? Container()
                  : Container(
                      alignment: Alignment.center,
                      child: Container(
                        child: CustomNetworkImage(
                          state.getTweetDetails.last.imagePath,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        !isToolAvailable
            ? Container()
            : Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.brown.shade700.withAlpha(200),
                      ),
                      child: Wrap(
                        children: <Widget>[
                          BackButton(
                            color: Colors.white,
                          ),
                        ],
                      )),
                )),
        !isToolAvailable
            ? Container()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TweetIconsRow(
                        feed: state.getTweetDetails.last,
                        iconColor: Theme.of(context).colorScheme.onPrimary,
                        iconEnableColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      Container(
                        color: Colors.brown.shade700.withAlpha(200),
                        padding:
                        EdgeInsets.only(right: 10, left: 10, bottom: 10),
                        child: TextField(
                          controller: textEditingController,
                          maxLines: null,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            fillColor: Colors.blue,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _submitButton();
                              },
                              icon: Icon(Icons.send, color: Colors.white),
                            ),
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            hintText: 'Comment here..',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  void _submitButton() {
    if (textEditingController.text == null ||
        textEditingController.text.isEmpty) {
      return;
    }
    if (textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var user = authState.getUser;
    var profilePic = user.profilePict;
    if (profilePic == null) {
      profilePic = mockProfilePicture;
    }
    var name =
        authState.getUser.displayName ?? authState.getUser.email.split('@')[0];
    var pic = authState.getUser.profilePict ?? mockProfilePicture;
    var tags = getHashTags(textEditingController.text);

    User commentedUser = User(
        displayName: name,
        userName: authState.getUser.userName,
        isVerified: authState.getUser.isVerified,
        profilePict: pic,
        userId: authState.userId);

    var postId = state.getTweetDetails.last.key;

    Feed reply = Feed(
      description: textEditingController.text,
      user: commentedUser,
      createdAt: DateTime.now().toUtc().toString(),
      tags: tags,
      userId: commentedUser.userId,
      parentKey: postId,
    );
    state.addCommentToPost(reply);
    FocusScope.of(context).requestFocus(focusNode);
    setState(() {
      textEditingController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }
}
