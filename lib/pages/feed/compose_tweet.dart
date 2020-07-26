import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/feed.dart';
import 'package:twitter/states/search.dart';
import 'package:twitter/states/tweet.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/bottom_icon.dart';
import 'package:twitter/widgets/image/tweet_image.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/label/url.dart';
import 'package:twitter/widgets/layout/view.dart';
import 'package:twitter/widgets/navigation/appbar.dart';

import '../user_list.dart';

class ComposeTweetPage extends StatefulWidget {
  ComposeTweetPage({Key key, this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;

  _ComposeTweetReplyPageState createState() => _ComposeTweetReplyPageState();
}

class _ComposeTweetReplyPageState extends State<ComposeTweetPage> {
  bool isScrollingDown = false;
  Feed model;
  ScrollController scrollController;

  File _image;
  TextEditingController _textEditingController;

  @override
  void dispose() {
    scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    model = feedState.tweetToReplyModel;
    scrollController = ScrollController();
    _textEditingController = TextEditingController();
    scrollController..addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        Provider.of<Tweet>(context, listen: false).setIsScrolllingDown = true;
      }
    }
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      Provider.of<Tweet>(context, listen: false).setIsScrolllingDown = false;
    }
  }

  void _onCrossIconPressed() {
    setState(() {
      _image = null;
    });
  }

  void _onImageIconSelected(File file) {
    setState(() {
      _image = file;
    });
  }

  /// Submit tweet to save in firebase database
  void _submitButton() async {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty ||
        _textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    myScreenLoader.showLoader(context);

    Feed tweetModel = createTweetModel();

    /// If tweet contain image
    /// First image is uploaded on firebase storage
    /// After sucessfull image upload to firebase storage it returns image path
    /// Add this image path to tweet model and save to firebase database
    if (_image != null) {
      await state.uploadFile(_image).then((imagePath) {
        if (imagePath != null) {
          tweetModel.imagePath = imagePath;

          /// If type of tweet is new tweet
          if (widget.isTweet) {
            state.createTweet(tweetModel);
          }

          /// If type of tweet is  retweet
          else if (widget.isRetweet) {
            state.createReTweet(tweetModel);
          }

          /// If type of tweet is new comment tweet
          else {
            state.addcommentToPost(tweetModel);
          }
        }
      });
    }

    /// If tweet did not contain image
    else {
      /// If type of tweet is new tweet
      if (widget.isTweet) {
        state.createTweet(tweetModel);
      }

      /// If type of tweet is  retweet
      else if (widget.isRetweet) {
        state.createReTweet(tweetModel);
      }

      /// If type of tweet is new comment tweet
      else {
        state.addcommentToPost(tweetModel);
      }
    }

    /// Checks for username in tweet description
    /// If foud sends notification to all tagged user
    /// If no user found or not compost tweet screen is closed and redirect back to home page.
    await Provider.of<Tweet>(context, listen: false)
        .sendNotification(
        tweetModel, Provider.of<SearchState>(context, listen: false))
        .then((_) {
      /// Hide running loader on screen
      myScreenLoader.hideLoader();

      /// Navigate back to home page
      Navigator.pop(context);
    });
  }

  /// Return Tweet model which is either a new Tweet , retweet model or comment model
  /// If tweet is new tweet then `parentkey` and `childRetwetkey` should be null
  /// IF tweet is a comment then it should have `parentkey`
  /// IF tweet is a retweet then it should have `childRetwetkey`
  Feed createTweetModel() {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var myUser = authState.userModel;
    var profilePic = myUser.profilePict ?? mockProfilePicture;
    var commentedUser = User(
        displayName: myUser.displayName ?? myUser.email.split('@')[0],
        profilePict: profilePic,
        userId: myUser.userId,
        isVerified: authState.userModel.isVerified,
        userName: authState.userModel.userName);
    var tags = getHashTags(_textEditingController.text);
    Feed reply = Feed(
        description: _textEditingController.text,
        user: commentedUser,
        createdAt: DateTime.now().toUtc().toString(),
        tags: tags,
        parentKey: widget.isTweet ? null : widget.isRetweet ? null : state.tweetToReplyModel.key,
        childRetweetKey: widget.isTweet ? null : widget.isRetweet ? model.key : null,
        userId: myUser.userId);
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: customTitleText(''),
        onActionPressed: _submitButton,
        isCrossButton: true,
        submitButtonText: widget.isTweet ? 'Tweet' : widget.isRetweet
            ? 'Retweet'
            : 'Reply',
        isSubmitDisable: !Provider
            .of<Tweet>(context)
            .enableSubmitButton || Provider
            .of<FeedState>(context)
            .isBusy,
        isBottomLine: Provider
            .of<Tweet>(context)
            .isScrollingDown,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollController,
              child: widget.isRetweet ? _ComposeRetweet(this) : ComposeTweet(
                  this),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ComposeBottomIconWidget(
                textEditingController: _textEditingController,
                onImageIconSelected: _onImageIconSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposeRetweet
    extends View<ComposeTweetPage, _ComposeTweetReplyPageState> {
  _ComposeRetweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;

  Widget _tweet(BuildContext context, Feed model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // SizedBox(width: 10),

        SizedBox(width: 20),
        Container(
          width: fullWidth(context) - 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: 25,
                    height: 25,
                    child: customImage(context, model.user.profilePict),
                  ),
                  SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 0, maxWidth: fullWidth(context) * .5),
                    child: TitleText(model.user.displayName, fontSize: 16, fontWeight: FontWeight.w800, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 3),
                  model.user.isVerified
                      ? TwitterIcon(
                    icon: AppIcon.blueTick,
                    iconColor: AppColor.primary,
                    size: 13,
                    paddingIcon: 3,
                  )
                      : SizedBox(width: 0),
                  SizedBox(width: model.user.isVerified ? 5 : 0),
                  Flexible(
                    child: CustomText(
                      '${model.user.userName}',
                      style: userNameStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  CustomText('· ${getChatTime(model.createdAt)}',
                      style: userNameStyle),
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
        UrlText(
          text: model.description,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          urlStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Container(
      height: fullHeight(context),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: customImage(
                    context, authState.firebaseUser?.photoUrl, height: 40),
              ),
              Expanded(
                child: _TextField(
                  isTweet: false,
                  isRetweet: true,
                  textEditingController: viewState._textEditingController,
                ),
              ),
              SizedBox(
                width: 16,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 16, left: 80, bottom: 8),
            child: ComposeTweetImage(
              image: viewState._image,
              onCrossIconPressed: viewState._onCrossIconPressed,
            ),
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 75, right: 16, bottom: 16),
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColor.extraLightGrey, width: .5),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: _tweet(context, viewState.model),
                    ),
                  ],
                ),
                UserList(
                  list: Provider
                      .of<SearchState>(context)
                      .users,
                  textEditingController: viewState._textEditingController,
                )
              ],
            ),
          ),
          SizedBox(height: 50)
        ],
      ),
    );
  }
}

class ComposeTweet extends View<ComposeTweetPage, _ComposeTweetReplyPageState> {
  ComposeTweet(this.viewState) : super(viewState);

  final _ComposeTweetReplyPageState viewState;

  Widget tweetCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 30),
              margin: EdgeInsets.only(left: 20, top: 20, bottom: 3),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 2.0,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: fullWidth(context) - 72,
                    child: UrlText(
                      text: viewState.model.description ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      urlStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  UrlText(
                    text: 'Replying to ${viewState.model.user.userName ?? viewState.model.user.displayName}',
                    style: TextStyle(
                      color: TwitterColor.paleSky,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                customImage(
                    context, viewState.model.user.profilePict, height: 40),
                SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: 0, maxWidth: fullWidth(context) * .5),
                  child: TitleText(
                      viewState.model.user.displayName, fontSize: 16,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 3),
                viewState.model.user.isVerified
                    ? TwitterIcon(
                  icon: AppIcon.blueTick,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
                    : SizedBox(width: 0),
                SizedBox(width: viewState.model.user.isVerified ? 5 : 0),
                CustomText('${viewState.model.user.userName}',
                    style: userNameStyle.copyWith(fontSize: 15)),
                SizedBox(width: 5),
                Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: CustomText(
                      '- ${getChatTime(viewState.model.createdAt)}',
                      style: userNameStyle.copyWith(fontSize: 12)),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context, listen: false);
    return Container(
      height: fullHeight(context),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          viewState.widget.isTweet ? SizedBox.shrink() : tweetCard(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              customImage(
                  context, authState.firebaseUser?.photoUrl, height: 40),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: _TextField(
                  isTweet: widget.isTweet,
                  textEditingController: viewState._textEditingController,
                ),
              )
            ],
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                ComposeTweetImage(
                  image: viewState._image,
                  onCrossIconPressed: viewState._onCrossIconPressed,
                ),
                UserList(
                  list: Provider
                      .of<SearchState>(context)
                      .users,
                  textEditingController: viewState._textEditingController,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({Key key, this.textEditingController, this.isTweet = false, this.isRetweet = false}) : super(key: key);
  final TextEditingController textEditingController;
  final bool isTweet;
  final bool isRetweet;

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: textEditingController,
          onChanged: (text) {
            Provider.of<Tweet>(context, listen: false).onDescriptionChanged(
                text, searchState);
          },
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isTweet ? 'What\'s happening?' : isRetweet ? 'Add a comment' : 'Tweet your reply',
              hintStyle: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
