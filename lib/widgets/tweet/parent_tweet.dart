import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/states/feed.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/widgets/tweet/tweet.dart';
import 'package:twitter/widgets/tweet/unavailable_tweet.dart';

class ParentTweetWidget extends StatelessWidget {
  ParentTweetWidget(
      {Key key,
      this.childRetweetKey,
      this.type,
      this.isImageAvailable,
      this.trailing})
      : super(key: key);

  final String childRetweetKey;
  final TweetType type;
  final Widget trailing;
  final bool isImageAvailable;

  void onTweetPressed(BuildContext context, Feed model) {
    var feedState = Provider.of<FeedState>(context, listen: false);
    feedState.getpostDetailFromDatabase(null, model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
  }

  @override
  Widget build(BuildContext context) {
    var feedState = Provider.of<FeedState>(context, listen: false);
    return FutureBuilder(
      future: feedState.fetchTweet(childRetweetKey),
      builder: (context, AsyncSnapshot<Feed> snapshot) {
        if (snapshot.hasData) {
          return Tweet(
              model: snapshot.data,
              type: TweetType.ParentTweet,
              trailing: trailing);
        }
        if ((snapshot.connectionState == ConnectionState.done ||
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
