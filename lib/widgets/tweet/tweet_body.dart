import 'package:flutter/material.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/label/url.dart';

class TweetBody extends StatelessWidget {
  final Feed feed;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;

  const TweetBody(
      {Key key, this.feed, this.trailing, this.type, this.isDisplayOnProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double descriptionFontSize = type == TweetType.Tweet
        ? 15
        : type == TweetType.Detail || type == TweetType.ParentTweet ? 18 : 14;
    FontWeight descriptionFontWeight =
        type == TweetType.Tweet || type == TweetType.Tweet
            ? FontWeight.w400
            : FontWeight.w400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 10),
        Container(
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              // If tweet is displaying on someone's profile then no need to navigate to same user's profile again.
              if (isDisplayOnProfile) {
                return;
              }
              Navigator.of(context).pushNamed('/ProfilePage/' + feed?.userId);
            },
            child: customImage(context, feed.user.profilePict),
          ),
        ),
        SizedBox(width: 20),
        Container(
          width: fullWidth(context) - 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
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
                        SizedBox(
                          width: feed.user.isVerified ? 5 : 0,
                        ),
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
                      ],
                    ),
                  ),
                  Container(child: trailing == null ? SizedBox() : trailing),
                ],
              ),
              UrlText(
                text: feed.description,
                onHashTagPressed: (tag) {
                  cprint(tag);
                },
                style: TextStyle(
                    color: Colors.black,
                    fontSize: descriptionFontSize,
                    fontWeight: descriptionFontWeight),
                urlStyle: TextStyle(
                    color: Colors.blue,
                    fontSize: descriptionFontSize,
                    fontWeight: descriptionFontWeight),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
