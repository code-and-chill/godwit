import 'package:flutter/material.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/pages/user_list.dart';
import 'package:twitter/utilities/routes/custom_route.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/label/text.dart';

class LikeComment extends StatelessWidget {
  final bool isLikeAvailable;
  final bool isRetweetAvailable;
  final bool isLikeRetweetAvailable;
  final Feed feed;

  LikeComment(this.isLikeAvailable, this.isRetweetAvailable,
      this.isLikeRetweetAvailable, this.feed,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        Navigator.of(context).push(
                          CustomRoute<bool>(
                            builder: (BuildContext context) => UsersListPage(
                              pageTitle: "Liked by",
                              userIdsList:
                                  feed.likes.map((userId) => userId).toList(),
                              emptyScreenText: "This tweet has no like yet",
                              emptyScreenSubTileText:
                                  "Once a user likes this tweet, user list will be shown here",
                            ),
                          ),
                        );
                      },
                      child: AnimatedCrossFade(
                        firstChild: SizedBox.shrink(),
                        secondChild: Row(
                          children: <Widget>[
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    child: child, scale: animation);
                              },
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
}
