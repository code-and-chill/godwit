import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/pages/feed/feed.dart';
import 'package:twitter/pages/message/chat_list.dart';
import 'package:twitter/states/app.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/chat.dart';
import 'package:twitter/states/feed/feed.dart';
import 'package:twitter/states/notification.dart';
import 'package:twitter/states/search.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/widgets/navigation/bottom_menubar.dart';

import '../widgets/navigation/sidebar.dart';
import 'notification/notification.dart';
import 'search/search.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  int pageIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var appState = Provider.of<AppState>(context, listen: false);
      var feedState = Provider.of<FeedState>(context, listen: false);
      var authState = Provider.of<AuthState>(context, listen: false);
      var notificationState =
          Provider.of<NotificationState>(context, listen: false);
      var chatState = Provider.of<ChatState>(context, listen: false);
      var searchState = Provider.of<SearchState>(context, listen: false);

      appState.setPageIndex = 0;
      feedState.databaseInit();
      feedState.getDataFromDatabase();
      authState.databaseInit();
      searchState.getDataFromDatabase();
      notificationState.databaseInit(authState.userId);
      notificationState.initfirebaseService();
      chatState.databaseInit(authState.userId, authState.userId);

      authState.updateFCMToken();
      chatState.getFCMServerKey();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<NotificationState>(context);

      /// Check if user receive chat notification from firebase
      /// Redirect to chat screen
      /// `notificationSenderId` is a user id who sends you a message
      /// `notificationReceiverId` is a your user id.
      if (state.notificationType == NotificationType.Message &&
          state.notificationReciverId == authState.getUser.userId) {
        state.setNotificationType = null;
        state.getuserDetail(state.notificationSenderId).then((user) {
          cprint("Opening user chat screen");
          final chatState = Provider.of<ChatState>(context, listen: false);
          chatState.setChatUser = user;
          Navigator.pushNamed(context, '/ChatScreenPage');
        });
      }

      /// Checks for user tag tweet notification
      /// If you are mentioned in tweet then it redirect to user profile who mentioed you in a tweet
      /// You can check that tweet on his profile timeline
      /// `notificationSenderId` is user id who tagged you in a tweet
      else if (state.notificationType == NotificationType.Mention &&
          state.notificationReciverId == authState.getUser.userId) {
        state.setNotificationType = null;
        Navigator.of(context)
            .pushNamed('/ProfilePage/' + state.notificationSenderId);
      }
    });
    return Scaffold(
      key: scaffoldKey,
      bottomNavigationBar: BottomMenubar(),
      drawer: SidebarMenu(),
      body: SafeArea(
        child: Container(
          child: getPage(Provider
              .of<AppState>(context)
              .pageIndex),
        ),
      ),
    );
  }

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return FeedPage(
          scaffoldKey: scaffoldKey,
          refreshIndicatorKey: refreshIndicatorKey,
        );
        break;
      case 1:
        return SearchPage(scaffoldKey: scaffoldKey);
        break;
      case 2:
        return NotificationPage(scaffoldKey: scaffoldKey);
        break;
      case 3:
        return ChatListPage(scaffoldKey: scaffoldKey);
        break;
      default:
        return FeedPage(scaffoldKey: scaffoldKey);
        break;
    }
  }
}
