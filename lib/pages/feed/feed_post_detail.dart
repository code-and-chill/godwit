import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/states/feed/feed.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/page.dart' as page;
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/navigation/tweet_bottom_sheet.dart';
import 'package:twitter/widgets/tweet/tweet.dart';

class FeedPostDetail extends StatefulWidget {
  FeedPostDetail({Key key, this.postId}) : super(key: key);
  final String postId;

  FeedPostDetailState createState() => FeedPostDetailState();
}

class FeedPostDetailState extends State<FeedPostDetail> {
  String postId;

  @override
  void initState() {
    postId = widget.postId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var feedState = Provider.of<FeedState>(context);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<FeedState>(context, listen: false)
            .removeLastTweetDetail(postId);
        return Future.value(true);
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var state = Provider.of<FeedState>(context, listen: false);
            state.setTweetToReply = state.getTweetDetails?.last;
            Navigator.of(context)
                .pushNamed('/ ' + page.ComposeTweet + '/' + postId);
          },
          child: Icon(Icons.add),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: customText('Thread'),
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              backgroundColor: Theme.of(context).appBarTheme.color,
              bottom: PreferredSize(
                child: Container(
                  color: Colors.grey.shade200,
                  height: 1.0,
                ),
                preferredSize: Size.fromHeight(0.0),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  feedState.getTweetDetails == null ||
                      feedState.getTweetDetails.length == 0
                      ? Container()
                      : Tweet(
                    feed: feedState.getTweetDetails?.last,
                    type: TweetType.Detail,
                    trailing: TweetBottomSheet().tweetOptionIcon(
                        context,
                        feedState.getTweetDetails?.last,
                        TweetType.Detail),
                  ),
                  Container(
                    height: 6,
                    width: fullWidth(context),
                    color: TwitterColor.mystic,
                  )
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                feedState.tweetReplyMap == null ||
                    feedState.tweetReplyMap.length == 0 ||
                    feedState.tweetReplyMap[postId] == null
                    ? [
                  Container(
                    child: Center(),
                  )
                ]
                    : feedState.tweetReplyMap[postId]
                    .map((x) =>
                    Tweet(
                      feed: x,
                      type: TweetType.Reply,
                      trailing: TweetBottomSheet()
                          .tweetOptionIcon(context, x, TweetType.Reply),
                    ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
