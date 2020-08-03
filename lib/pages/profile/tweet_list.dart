import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/label/notify.dart';
import 'package:twitter/widgets/layout/loader.dart';
import 'package:twitter/widgets/navigation/tweet_bottom_sheet.dart';
import 'package:twitter/widgets/tweet/tweet.dart';

class TweetList extends StatelessWidget {
  final List<Feed> tweetsList;
  final bool isReply;
  final bool isMedia;
  final bool isMyProfile;

  TweetList({this.tweetsList, this.isReply, this.isMedia, this.isMyProfile});

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    List<Feed> list;

    /// If user hasn't tweeted yet
    if (isMedia) {
      list = tweetsList.where((x) => x.imagePath != null).toList();
    } else if (!isReply) {
      /// Display all independent Tweets
      /// No comments Tweet will display

      list = tweetsList
          .where((x) => x.parentKey == null || x.childRetweetKey != null)
          .toList();
    } else {
      /// Display all reply Tweets
      /// No independent tweet will display
      list = tweetsList
          .where((x) => x.parentKey != null && x.childRetweetKey == null)
          .toList();
    }

    /// if [authState.isbusy] is true then an loading indicator will be displayed on screen.
    return authState.isAppBusy
        ? Container(
            height: fullHeight(context) - 180,
            child: CustomScreenLoader(
              height: double.infinity,
              width: fullWidth(context),
              backgroundColor: Colors.white,
            ),
          )

        /// if tweet list is empty or null then need to show user a message
        : list == null || list.length < 1
            ? Container(
                padding: EdgeInsets.only(top: 50, left: 30, right: 30),
                child: NotifyText(
                  title: isMyProfile
                      ? 'You haven\'t ${isReply ? 'reply to any Tweet' : isMedia ? 'post any media Tweet yet' : 'post any Tweet yet'}'
                      : '${authState.profileUser.userName} hasn\'t ${isReply ? 'reply to any Tweet' : isMedia ? 'post any media Tweet yet' : 'post any Tweet yet'}',
                  subTitle: isMyProfile
                      ? 'Tap tweet button to add new'
                      : 'Once he\'ll do, they will be shown up here',
                ),
              )

            /// If tweets available then tweet list will displayed
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 0),
                itemCount: list.length,
                itemBuilder: (context, index) => Container(
                  color: TwitterColor.white,
                  child: Tweet(
                    feed: list[index],
                    isDisplayOnProfile: true,
                    trailing: TweetBottomSheet().tweetOptionIcon(
                      context,
                      list[index],
                      TweetType.Tweet,
                    ),
                  ),
                ),
              );
  }
}
