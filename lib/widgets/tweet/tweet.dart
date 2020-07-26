import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/states/feed.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/image/icons_row.dart';
import 'package:twitter/widgets/tweet/tweet_detail_body.dart';

import '../image/tweetImage.dart';
import 'retweet.dart';
import 'tweet_body.dart';

class Tweet extends StatelessWidget {
  final Feed model;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;

  const Tweet(
      {Key key,
      this.model,
      this.trailing,
      this.type = TweetType.Tweet,
      this.isDisplayOnProfile = false})
      : super(key: key);

  void onLongPressedTweet(BuildContext context) {
    if (type == TweetType.Detail || type == TweetType.ParentTweet) {
      var text = ClipboardData(text: model.description);
      Clipboard.setData(text);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: TwitterColor.black,
          content: Text(
            'Tweet copied to clipboard',
          ),
        ),
      );
    }
  }

  void onTapTweet(BuildContext context) {
    var feedState = Provider.of<FeedState>(context, listen: false);
    if (type == TweetType.Detail || type == TweetType.ParentTweet) {
      return;
    }
    if (type == TweetType.Tweet && !isDisplayOnProfile) {
      feedState.clearAllDetailAndReplyTweetStack();
    }
    feedState.getpostDetailFromDatabase(null, model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        /// Left vertical bar of a tweet
        type != TweetType.ParentTweet
            ? SizedBox.shrink()
            : Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 38,
                    top: 75,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3.0, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
        InkWell(
          onLongPress: () {
            onLongPressedTweet(context);
          },
          onTap: () {
            onTapTweet(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: type == TweetType.Tweet || type == TweetType.Reply
                      ? 12
                      : 0,
                ),
                child: type == TweetType.Tweet || type == TweetType.Reply
                    ? TweetBody(
                  isDisplayOnProfile: isDisplayOnProfile,
                  feed: model,
                  trailing: trailing,
                  type: type,
                )
                    : TweetDetailBody(
                  isDisplayOnProfile: isDisplayOnProfile,
                  model: model,
                  trailing: trailing,
                  type: type,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: TweetImage(
                  model: model,
                  type: type,
                ),
              ),
              model.childRetweetKey == null
                  ? SizedBox.shrink()
                  : RetweetWidget(
                childRetweetKey: model.childRetweetKey,
                type: type,
                isImageAvailable:
                model.imagePath != null && model.imagePath.isNotEmpty,
              ),
              Padding(
                padding:
                EdgeInsets.only(left: type == TweetType.Detail ? 10 : 60),
                child: TweetIconsRow(
                  type: type,
                  feed: model,
                  isTweetDetail: type == TweetType.Detail,
                  iconColor: Theme
                      .of(context)
                      .textTheme
                      .caption
                      .color,
                  iconEnableColor: TwitterColor.ceriseRed,
                  size: 20,
                ),
              ),
              type == TweetType.ParentTweet
                  ? SizedBox.shrink()
                  : Divider(height: .5, thickness: .5)
            ],
          ),
        ),
      ],
    );
  }
}
