import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/pages/user_list.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/feed.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/routes.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/text.dart';
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
        isTweetDetail ? _likeCommentWidget(context) : SizedBox(),
        _likeCommentsIcons(context, feed)
      ],
    ));
  }

  Widget _likeCommentsIcons(BuildContext context, Feed model) {
    var authState = Provider.of<AuthState>(context, listen: false);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 0, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          _iconWidget(
            context,
            text: isTweetDetail ? '' : model.commentCount.toString(),
            icon: AppIcon.reply,
            iconColor: iconColor,
            size: size ?? 20,
            onPressed: () {
              var state = Provider.of<FeedState>(context, listen: false);
              state.setTweetToReply = model;
              Navigator.of(context).pushNamed('/ComposeTweetPage');
            },
          ),
          _iconWidget(context,
              text: isTweetDetail ? '' : model.retweetCount.toString(),
              icon: AppIcon.retweet,
              iconColor: iconColor,
              size: size ?? 20,
              onPressed: () {
                TweetBottomSheet().openRetweetBottomSheet(context, type, model);
              }),
          _iconWidget(
            context,
            text: isTweetDetail ? '' : model.likeCount.toString(),
            icon: model.likes.any((userId) => userId == authState.userId)
                ? AppIcon.heartFill
                : AppIcon.heartEmpty,
            onPressed: () {
              addLikeToTweet(context);
            },
            iconColor: model.likes.any((userId) => userId == authState.userId)
                ? iconEnableColor
                : iconColor,
            size: size ?? 20,
          ),
          _iconWidget(context, text: '',
              icon: null,
              sysIcon: Icons.share,
              onPressed: () {
                share('${model.description}',
                    subject: '${model.user.displayName}\'s post');
              },
              iconColor: iconColor,
              size: size ?? 20),
        ],
      ),
    );
  }

  Widget _iconWidget(BuildContext context,
      {String text,
        int icon,
        Function onPressed,
        IconData sysIcon,
        Color iconColor,
        double size = 20}) {
    return Expanded(
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                if (onPressed != null) onPressed();
              },
              icon: sysIcon != null
                  ? Icon(sysIcon, color: iconColor, size: size)
                  : TwitterIcon(
                size: size,
                icon: icon,
                isTwitterIcon: true,
                iconColor: iconColor,
              ),
            ),
            CustomText(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
                fontSize: size - 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _likeCommentWidget(BuildContext context) {
    bool isLikeAvailable =
    feed.likeCount != null ? feed.likeCount > 0 : false;
    bool isRetweetAvailable = feed.retweetCount > 0;
    bool isLikeRetweetAvailable = isRetweetAvailable || isLikeAvailable;
    return Column(
      children: <Widget>[
        Divider(
          endIndent: 10,
          height: 0,
        ),
        AnimatedContainer(
          padding:
          EdgeInsets.symmetric(vertical: isLikeRetweetAvailable ? 12 : 0),
          duration: Duration(milliseconds: 500),
          child: !isLikeRetweetAvailable
              ? SizedBox.shrink()
              : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              !isRetweetAvailable
                  ? SizedBox.shrink()
                  : CustomText(feed.retweetCount.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              !isRetweetAvailable
                  ? SizedBox.shrink()
                  : SizedBox(width: 5),
              AnimatedCrossFade(
                firstChild: SizedBox.shrink(),
                secondChild: CustomText('Retweets', style: subtitleStyle),
                crossFadeState: !isRetweetAvailable
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: Duration(milliseconds: 800),
              ),
              !isRetweetAvailable
                  ? SizedBox.shrink()
                  : SizedBox(width: 20),
              InkWell(
                onTap: () {
                  onLikeTextPressed(context);
                },
                child: AnimatedCrossFade(
                  firstChild: SizedBox.shrink(),
                  secondChild: Row(
                    children: <Widget>[
                      customSwitcherWidget(
                        duraton: Duration(milliseconds: 300),
                        child: CustomText(feed.likeCount.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                            key: ValueKey(feed.likeCount)),
                      ),
                      SizedBox(width: 5),
                      CustomText('Likes', style: subtitleStyle)
                    ],
                  ),
                  crossFadeState: !isLikeAvailable
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 300),
                ),
              )
            ],
          ),
        ),
        !isLikeRetweetAvailable
            ? SizedBox.shrink()
            : Divider(
                endIndent: 10,
                height: 0,
              ),
      ],
    );
  }

  void addLikeToTweet(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToTweet(feed, authState.userId);
  }

  void onLikeTextPressed(BuildContext context) {
    Navigator.of(context).push(
      CustomRoute<bool>(
        builder: (BuildContext context) => UsersListPage(
          pageTitle: "Liked by",
          userIdsList: feed.likes.map((userId) => userId).toList(),
          emptyScreenText: "This tweet has no like yet",
          emptyScreenSubTileText:
          "Once a user likes this tweet, user list will be shown here",
        ),
      ),
    );
  }
}
