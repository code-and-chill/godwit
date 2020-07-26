import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/feed.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/empty/empty_list.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/layout/loader.dart';
import 'package:twitter/widgets/navigation/ink_well.dart';
import 'package:twitter/widgets/navigation/tweet_bottom_sheet.dart';
import 'package:twitter/widgets/tweet/tweet.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage/tweet');
      },
      child: TwitterIcon(
        icon: AppIcon.fabTweet,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingActionButton(context),
      backgroundColor: TwitterColor.mystic,
      body: SafeArea(
        child: Container(
          height: fullHeight(context),
          width: fullWidth(context),
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () async {
              /// refresh home page feed
              var feedState = Provider.of<FeedState>(context, listen: false);
              feedState.getDataFromDatabase();
              return Future.value(true);
            },
            child: _FeedPageBody(
              refreshIndicatorKey: refreshIndicatorKey,
              scaffoldKey: scaffoldKey,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedPageBody extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  const _FeedPageBody({Key key, this.scaffoldKey, this.refreshIndicatorKey}) : super(key: key);
  Widget _getUserAvatar(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: CustomInkWell(
        splashColor: Theme
            .of(context)
            .primaryColorLight,
        radius: BorderRadius.circular(0.0),
        onPressed: () {
          scaffoldKey.currentState.openDrawer();
        },
        child:
        customImage(context, authState.userModel?.profilePict, height: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authstate = Provider.of<AuthState>(context, listen: false);
    return Consumer<FeedState>(
      builder: (context, state, child) {
        final List<Feed> list = state.getTweetList(authstate.userModel);
        return CustomScrollView(
          slivers: <Widget>[
            child,
            state.isBusy && list == null
                ? SliverToBoxAdapter(
                    child: Container(
                      height: fullHeight(context) - 135,
                      child: CustomScreenLoader(
                        height: double.infinity,
                        width: fullWidth(context),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                : !state.isBusy && list == null
                    ? SliverToBoxAdapter(
                        child: EmptyList(
                          'No Tweet added yet',
                          subTitle: 'When new Tweet added, they\'ll show up here \n Tap tweet button to add new',
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate(
                          list.map(
                            (model) {
                              return Container(
                                color: Colors.white,
                                child: Tweet(
                                  model: model,
                                  trailing: TweetBottomSheet().tweetOptionIcon(
                                    context,
                                    model,
                                    TweetType.Tweet,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      )
          ],
        );
      },
      child: SliverAppBar(
        floating: true,
        elevation: 0,
        leading: _getUserAvatar(context),
        title: customTitleText('Home'),
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
    );
  }
}
