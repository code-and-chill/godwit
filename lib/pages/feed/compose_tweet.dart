import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/feed/feed.dart';
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
import 'package:twitter/widgets/user/user_list.dart';

class ComposeTweetPage extends StatefulWidget {
  ComposeTweetPage({Key key, this.isRetweet, this.isTweet = true})
      : super(key: key);

  final bool isRetweet;
  final bool isTweet;

  ComposeTweetReplyPageState createState() => ComposeTweetReplyPageState();
}

class ComposeTweetReplyPageState extends State<ComposeTweetPage> {
  TextEditingController textEditingController;
  ScrollController scrollController;
  Feed feed;
  File image;
  bool isScrollingDown = false;

  @override
  void dispose() {
    scrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var feedState = Provider.of<FeedState>(context, listen: false);
    feed = feedState.getTweetToReply;
    scrollController = ScrollController();
    textEditingController = TextEditingController();
    scrollController
      ..addListener(() {
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (!isScrollingDown) {
            Provider.of<TweetState>(context, listen: false)
                .setIsScrolllingDown = true;
          }
        }
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          Provider.of<TweetState>(context, listen: false).setIsScrolllingDown =
              false;
        }
      });
    super.initState();
  }

  void _onCrossIconPressed() {
    setState(() {
      image = null;
    });
  }

  void _onImageIconSelected(File file) {
    setState(() {
      image = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    var feedState = Provider.of<FeedState>(context, listen: false);
    var tweetState = Provider.of<TweetState>(context, listen: false);
    var searchState = Provider.of<SearchState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: customText(''),
        onActionPressed: () async {
          if (textEditingController.text == null ||
              textEditingController.text.isEmpty ||
              textEditingController.text.length > 280) {
            return;
          }

          myScreenLoader.showLoader(context);

          var myUser = authState.getUser;
          var profilePict = myUser.profilePict ?? mockProfilePicture;
          var commentedUser = User(
              displayName: myUser.displayName ?? myUser.email.split('@')[0],
              profilePict: profilePict,
              userId: myUser.userId,
              isVerified: authState.getUser.isVerified,
              userName: authState.getUser.userName);
          var tags = getHashTags(textEditingController.text);
          Feed tweet = Feed(
              description: textEditingController.text,
              user: commentedUser,
              createdAt: DateTime.now().toUtc().toString(),
              tags: tags,
              parentKey: widget.isTweet
                  ? null
                  : widget.isRetweet ? null : feedState.getTweetToReply.key,
              childRetweetKey:
              widget.isTweet ? null : widget.isRetweet ? feed.key : null,
              userId: myUser.userId);

          if (image != null) {
            await feedState.uploadFile(image).then((imagePath) {
              if (imagePath != null) {
                tweet.imagePath = imagePath;
                if (widget.isTweet) {
                  feedState.createTweet(tweet);
                } else if (widget.isRetweet) {
                  feedState.createReTweet(tweet);
                } else {
                  feedState.addCommentToPost(tweet);
                }
              }
            });
          } else {
            if (widget.isTweet) {
              feedState.createTweet(tweet);
            } else if (widget.isRetweet) {
              feedState.createReTweet(tweet);
            } else {
              feedState.addCommentToPost(tweet);
            }
          }

          await tweetState
              .sendNotification(tweet, searchState)
              .then((_) {
            myScreenLoader.hideLoader();
            Navigator.pop(context);
          });
        },
        isCrossButton: true,
        submitButtonText:
        widget.isTweet ? 'Tweet' : widget.isRetweet ? 'Retweet' : 'Reply',
        isSubmitDisable: !Provider
            .of<TweetState>(context)
            .enableSubmitButton ||
            Provider
                .of<FeedState>(context)
                .isBusy,
        isBottomLine: Provider
            .of<TweetState>(context)
            .isScrollingDown,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: scrollController,
              child:
              widget.isRetweet ? _ComposeRetweet(this) : ComposeTweet(this),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ComposeBottomIconWidget(
                textEditingController: textEditingController,
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
    extends View<ComposeTweetPage, ComposeTweetReplyPageState> {
  _ComposeRetweet(this.viewState) : super(viewState);

  final ComposeTweetReplyPageState viewState;

  Widget _tweet(BuildContext context, Feed feed) {
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
                    child: customImage(context, feed.user.profilePict),
                  ),
                  SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: 0, maxWidth: fullWidth(context) * .5),
                    child: TitleText(feed.user.displayName,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 3),
                  feed.user.isVerified
                      ? TwitterIcon(
                    icon: AppIcon.blueTick,
                    iconColor: AppColor.primary,
                    size: 13,
                    paddingIcon: 3,
                  )
                      : SizedBox(width: 0),
                  SizedBox(width: feed.user.isVerified ? 5 : 0),
                  Flexible(
                    child: CustomText(
                      '${feed.user.userName}',
                      style: userNameStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  CustomText('· ${getChatTime(feed.createdAt)}',
                      style: userNameStyle),
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        ),
        UrlText(
          text: feed.description,
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
    var searchState = Provider.of<SearchState>(context);
    var tweetState = Provider.of<TweetState>(context);
    return Container(
      height: fullHeight(context),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: customImage(context, authState.firebaseUser?.photoUrl,
                    height: 40),
              ),
              Expanded(
                child: _TextField(
                  isTweet: false,
                  isRetweet: true,
                  textEditingController: viewState.textEditingController,
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
              image: viewState.image,
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
                      child: _tweet(context, viewState.feed),
                    ),
                  ],
                ),
                !tweetState.displayUserList ||
                    searchState.users == null ||
                    searchState.users.length <= 0
                    ? SizedBox.shrink()
                    : UserList(
                  data: searchState.users,
                  textEditingController: viewState.textEditingController,
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

class ComposeTweet extends View<ComposeTweetPage, ComposeTweetReplyPageState> {
  ComposeTweet(this.viewState) : super(viewState);

  final ComposeTweetReplyPageState viewState;

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
                      text: viewState.feed.description ?? '',
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
                    text:
                    'Replying to ${viewState.feed.user.userName ??
                        viewState.feed.user.displayName}',
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
                customImage(context, viewState.feed.user.profilePict,
                    height: 40),
                SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: 0, maxWidth: fullWidth(context) * .5),
                  child: TitleText(viewState.feed.user.displayName,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 3),
                viewState.feed.user.isVerified
                    ? TwitterIcon(
                  icon: AppIcon.blueTick,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
                    : SizedBox(width: 0),
                SizedBox(width: viewState.feed.user.isVerified ? 5 : 0),
                CustomText('${viewState.feed.user.userName}',
                    style: userNameStyle.copyWith(fontSize: 15)),
                SizedBox(width: 5),
                Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: CustomText(
                      '- ${getChatTime(viewState.feed.createdAt)}',
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
    var searchState = Provider.of<SearchState>(context);
    var tweetState = Provider.of<TweetState>(context);
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
              customImage(context, authState.firebaseUser?.photoUrl,
                  height: 40),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: _TextField(
                  isTweet: widget.isTweet,
                  textEditingController: viewState.textEditingController,
                ),
              )
            ],
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                ComposeTweetImage(
                  image: viewState.image,
                  onCrossIconPressed: viewState._onCrossIconPressed,
                ),
                !tweetState.displayUserList ||
                    searchState.users == null ||
                    searchState.users.length <= 0
                    ? SizedBox.shrink()
                    : UserList(
                  data: searchState.users,
                  textEditingController: viewState.textEditingController,
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
  const _TextField({Key key,
    this.textEditingController,
    this.isTweet = false,
    this.isRetweet = false})
      : super(key: key);
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
            Provider.of<TweetState>(context, listen: false)
                .onDescriptionChanged(text, searchState);
          },
          maxLines: null,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: isTweet
                  ? 'What\'s happening?'
                  : isRetweet ? 'Add a comment' : 'Tweet your reply',
              hintStyle: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
