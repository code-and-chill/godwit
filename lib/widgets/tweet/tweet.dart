import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/states/feed/feed.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/image/icons_row.dart';
import 'package:twitter/widgets/tweet/tweet_detail_body.dart';

import '../image/tweetImage.dart';
import 'retweet.dart';
import 'tweet_body.dart';

class Tweet extends StatelessWidget {
  final Feed feed;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;

  const Tweet(
      {Key key,
      this.feed,
      this.trailing,
      this.type = TweetType.Tweet,
      this.isDisplayOnProfile = false})
      : super(key: key);

  void onLongPressedTweet(BuildContext context) {
    if (type == TweetType.Detail || type == TweetType.ParentTweet) {
      var text = ClipboardData(text: feed.description);
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
    feedState.getPostDetailFromDatabase(null, feed: feed);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + feed.key);
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
                  feed: feed,
                  trailing: trailing,
                  type: type,
                )
                    : TweetDetailBody(
                  isDisplayOnProfile: isDisplayOnProfile,
                  model: feed,
                  trailing: trailing,
                  type: type,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: TweetImage(
                  model: feed,
                  type: type,
                ),
              ),
              feed.childRetweetKey == null
                  ? SizedBox.shrink()
                  : RetweetWidget(
                childRetweetKey: feed.childRetweetKey,
                type: type,
                isImageAvailable:
                feed.imagePath != null && feed.imagePath.isNotEmpty,
              ),
              Padding(
                padding:
                EdgeInsets.only(left: type == TweetType.Detail ? 10 : 60),
                child: TweetIconsRow(
                  type: type,
                  feed: feed,
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
