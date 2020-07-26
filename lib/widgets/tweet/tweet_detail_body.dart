import 'package:flutter/material.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/geometry.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/label/url.dart';
import 'package:twitter/widgets/tweet/parent_tweet.dart';

class TweetDetailBody extends StatelessWidget {
  final Feed model;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;

  const TweetDetailBody(
      {Key key, this.model, this.trailing, this.type, this.isDisplayOnProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double descriptionFontSize = type == TweetType.Tweet
        ? getDimension(context, 15)
        : type == TweetType.Detail
            ? getDimension(context, 18)
            : type == TweetType.ParentTweet ? getDimension(context, 14) : 10;

    FontWeight descriptionFontWeight =
        type == TweetType.Tweet || type == TweetType.Tweet
            ? FontWeight.w300
            : FontWeight.w400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        model.parentKey != null &&
                model.childRetweetKey == null &&
                type != TweetType.ParentTweet
            ? ParentTweetWidget(
                childRetweetKey: model.parentKey,
                isImageAvailable: false,
                trailing: trailing)
            : SizedBox.shrink(),
        Container(
          width: fullWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/ProfilePage/' + model?.userId);
                  },
                  child: customImage(context, model.user.profilePict),
                ),
                title: Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: 0, maxWidth: fullWidth(context) * .5),
                      child: TitleText(model.user.displayName,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          overflow: TextOverflow.ellipsis),
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
                    SizedBox(
                      width: model.user.isVerified ? 5 : 0,
                    ),
                  ],
                ),
                subtitle:
                    CustomText('${model.user.userName}', style: userNameStyle),
                trailing: trailing,
              ),
              Padding(
                padding: type == TweetType.ParentTweet
                    ? EdgeInsets.only(left: 80, right: 16)
                    : EdgeInsets.symmetric(horizontal: 16),
                child: UrlText(
                  text: model.description,
                  onHashTagPressed: (tag) {
                    print(tag);
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: descriptionFontSize,
                    fontWeight: descriptionFontWeight,
                  ),
                  urlStyle: TextStyle(
                    color: Colors.blue,
                    fontSize: descriptionFontSize,
                    fontWeight: descriptionFontWeight,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
