import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/states/feed/feed.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/button/ripple.dart';
import 'package:twitter/widgets/image/tweetImage.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/label/url.dart';
import 'package:twitter/widgets/tweet/unavailable_tweet.dart';

class RetweetWidget extends StatelessWidget {
  const RetweetWidget(
      {Key key, this.childRetweetKey, this.type, this.isImageAvailable = false})
      : super(key: key);

  final String childRetweetKey;
  final bool isImageAvailable;
  final TweetType type;

  Widget _tweet(BuildContext context, Feed feed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: fullWidth(context) - 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
                child: TitleText(
                  feed.user.displayName,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis,
                ),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: UrlText(
            text: feed.description,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            urlStyle:
            TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: feed.imagePath == null ? 8 : 0),
        TweetImage(model: feed, type: type, isRetweetImage: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var feedState = Provider.of<FeedState>(context, listen: false);
    return FutureBuilder(
      future: feedState.fetchTweet(childRetweetKey),
      builder: (context, AsyncSnapshot<Feed> snapshot) {
        if (snapshot.hasData) {
          return Container(
            margin: EdgeInsets.only(
                left: type == TweetType.Tweet || type == TweetType.ParentTweet
                    ? 70
                    : 12,
                right: 16,
                top: isImageAvailable ? 8 : 5),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.extraLightGrey, width: .5),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: RippleButton(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              onPressed: () {
                feedState.getPostDetailFromDatabase(null, feed: snapshot.data);
                Navigator.of(context)
                    .pushNamed('/FeedPostDetail/' + snapshot.data.key);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: _tweet(context, snapshot.data),
              ),
            ),
          );
        } else if ((snapshot.connectionState == ConnectionState.done ||
            snapshot.connectionState == ConnectionState.waiting) &&
            !snapshot.hasData) {
          return UnavailableTweet(
            snapshot: snapshot,
            type: type,
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
