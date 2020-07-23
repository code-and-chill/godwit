import 'package:flutter/material.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/state/feedState.dart';
import 'package:twitter/widgets/tweet/tweet.dart';
import 'package:twitter/widgets/tweet/unavailableTweet.dart';
import 'package:provider/provider.dart';

class ParentTweetWidget extends StatelessWidget {
  ParentTweetWidget({Key key, this.childRetwetkey, this.type, this.isImageAvailable, this.trailing}) : super(key: key);

  final String childRetwetkey;
  final TweetType type;
  final Widget trailing;
  final bool isImageAvailable;

  void onTweetPressed(BuildContext context, Feed model) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    feedstate.getpostDetailFromDatabase(null, model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
  }

  @override
  Widget build(BuildContext context) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    return FutureBuilder(
      future: feedstate.fetchTweet(childRetwetkey),
      builder: (context, AsyncSnapshot<Feed> snapshot) {
        if (snapshot.hasData) {
          return Tweet(model: snapshot.data, type: TweetType.ParentTweet, trailing: trailing);
        }
        if ((snapshot.connectionState == ConnectionState.done || snapshot.connectionState == ConnectionState.waiting) && !snapshot.hasData) {
          return UnavailableTweet(
            snapshot: snapshot,
            type: type,
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
