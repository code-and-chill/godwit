import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/feed.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/image/icon.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/like/like_comment.dart';
import 'package:twitter/widgets/navigation/tweet_bottom_sheet.dart';

class TweetIconsRow extends StatelessWidget {
  final Feed feed;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isTweetDetail;
  final TweetType type;

  const TweetIconsRow(
      {Key key,
      this.feed,
      this.iconColor,
      this.iconEnableColor,
      this.size,
      this.isTweetDetail = false,
      this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    return Container(
        child: Column(
      children: <Widget>[
        isTweetDetail
            ? Column(
                children: <Widget>[
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 5),
                      CustomText(getPostingTime(feed.createdAt),
                        style: textStyle14),
                      SizedBox(width: 10),
                      CustomText('Twitter for Android',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor))
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              )
            : SizedBox(),
        isTweetDetail
            ? LikeComment(
                feed.likeCount != null ? feed.likeCount > 0 : false,
                feed.retweetCount > 0,
                feed.likeCount != null
                    ? feed.likeCount > 0
                    : false || feed.retweetCount > 0,
                feed,
              )
            : SizedBox(),
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(bottom: 0, top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 20,
              ),
              CustomIcon(
                text: isTweetDetail ? '' : feed.commentCount.toString(),
                icon: AppIcon.reply,
                iconColor: iconColor,
                size: size ?? 20,
                onPressed: () {
                  var state = Provider.of<FeedState>(context, listen: false);
                  state.setTweetToReply = feed;
                  Navigator.of(context).pushNamed('/ComposeTweetPage');
                },
              ),
              CustomIcon(
                  text: isTweetDetail ? '' : feed.retweetCount.toString(),
                  icon: AppIcon.retweet,
                  iconColor: iconColor,
                  size: size ?? 20,
                  onPressed: () {
                    TweetBottomSheet()
                        .openRetweetBottomSheet(context, type, feed);
                  }),
              CustomIcon(
                text: isTweetDetail ? '' : feed.likeCount.toString(),
                icon: feed.likes.any((userId) => userId == authState.userId)
                    ? AppIcon.heartFill
                    : AppIcon.heartEmpty,
                onPressed: () {
                  state.addLikeToTweet(feed, authState.userId);
                },
                iconColor:
                    feed.likes.any((userId) => userId == authState.userId)
                        ? iconEnableColor
                        : iconColor,
                size: size ?? 20,
              ),
              CustomIcon(
                  text: '',
                  icon: null,
                  sysIcon: Icons.share,
                  onPressed: () {
                    share('${feed.description}',
                        subject: '${feed.user.displayName}\'s post');
                  },
                  iconColor: iconColor,
                  size: size ?? 20),
            ],
          ),
        )
      ],
    ));
  }
}
