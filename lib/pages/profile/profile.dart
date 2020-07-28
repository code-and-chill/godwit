import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/choice.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/pages/profile/avatar.dart';
import 'package:twitter/pages/profile/banner.dart';
import 'package:twitter/pages/profile/tweet_list.dart';
import 'package:twitter/pages/profile/user_name.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/feed.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/navigation/tab_painter.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.profileId}) : super(key: key);

  final String profileId;

  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isMyProfile = false;
  int pageIndex = 0;
  TabController tabController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var authState = Provider.of<AuthState>(context, listen: false);
      authState.getProfileUser(userProfileId: widget.profileId);
      isMyProfile =
          widget.profileId == null || widget.profileId == authState.userId;
    });
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    var feedState = Provider.of<FeedState>(context);
    var authState = Provider.of<AuthState>(context);
    List<Feed> list;
    String id = widget.profileId ?? authState.userId;

    /// Filter user's tweet among all tweets available in home page tweets list
    if (feedState.feedlist != null && feedState.feedlist.length > 0) {
      list = feedState.feedlist.where((x) => x.userId == id).toList();
    }
    return WillPopScope(
      onWillPop: () async {
        final state = Provider.of<AuthState>(context, listen: false);
        state.removeLastUser();
        return true;
      },
      child: Scaffold(
        floatingActionButton: !isMyProfile ? null : _floatingActionButton(),
        backgroundColor: TwitterColor.mystic,
        body: NestedScrollView(
          // controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
            return <Widget>[
              getAppbar(),
              authState.isAppBusy
                  ? SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        child: authState.isAppBusy
                            ? SizedBox.shrink()
                            : UserNameRowWidget(
                                user: authState.profileUser,
                                isMyProfile: isMyProfile,
                              ),
                      ),
                    ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      color: TwitterColor.white,
                      child: TabBar(
                        indicator: TabIndicator(),
                        controller: tabController,
                        tabs: <Widget>[
                          Text("Tweets"),
                          Text("Tweets & replies"),
                          Text("Media")
                        ],
                      ),
                    )
                  ],
                ),
              )
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              TweetList(
                tweetsList: list,
                isReply: false,
                isMedia: false,
                isMyProfile: isMyProfile,
              ),
              TweetList(
                  tweetsList: list,
                  isReply: true,
                  isMedia: false,
                  isMyProfile: isMyProfile),
              TweetList(
                  tweetsList: list,
                  isReply: false,
                  isMedia: true,
                  isMyProfile: isMyProfile)
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar getAppbar() {
    var authState = Provider.of<AuthState>(context);
    return SliverAppBar(
      forceElevated: false,
      expandedHeight: 200,
      elevation: 0,
      stretch: true,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        authState.isAppBusy
            ? SizedBox.shrink()
            : PopupMenuButton<Choice>(
                onSelected: (d) {},
                itemBuilder: (BuildContext context) {
                  return defaultChoices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: authState.isAppBusy
            ? SizedBox.shrink()
            : Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            SizedBox.expand(
              child: Container(
                padding: EdgeInsets.only(top: 50),
                height: 30,
                color: Colors.white,
              ),
            ),
            // Container(height: 50, color: Colors.black),

            /// Banner image
            BannerImage(
              image: customNetworkImage(
                'https://pbs.twimg.com/profile_banners/457684585/1510495215/1500x500',
                fit: BoxFit.fill,
              ),
            ),

            /// User avatar, message icon, profile edit and follow/following button
            Avatar(
              isMyProfile: isMyProfile,
              profileUser: authState.profileUser,
            ),
          ],
              ),
      ),
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage');
      },
      child: TwitterIcon(
        icon: AppIcon.fabTweet,
        iconColor: Theme
            .of(context)
            .colorScheme
            .onPrimary,
        size: 25,
      ),
    );
  }
}
