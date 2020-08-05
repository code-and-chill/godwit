import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/feed/feed.dart';
import 'package:twitter/states/notification.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/page.dart' as page;
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/empty/empty_list.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/label/url.dart';
import 'package:twitter/widgets/navigation/appbar.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key, this.scaffoldKey}) : super(key: key);

  /// scaffoldKey used to open sidebar drawer
  final GlobalKey<ScaffoldState> scaffoldKey;

  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<NotificationState>(context, listen: false);
      var authstate = Provider.of<AuthState>(context, listen: false);
      state.getDataFromDatabase(authstate.userId);
    });
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/' + page.Notification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: customText(
          'Notifications',
        ),
        icon: AppIcon.settings,
        onActionPressed: onSettingIconPressed,
      ),
      body: NotificationPageBody(),
    );
  }
}

class NotificationPageBody extends StatelessWidget {
  const NotificationPageBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var notificationState = Provider.of<NotificationState>(context);
    var authState = Provider.of<AuthState>(context);
    var list = notificationState.notificationList;
    if (notificationState?.isAppBusy ??
        true && (list == null || list.isEmpty)) {
      return SizedBox(
        height: 3,
        child: LinearProgressIndicator(),
      );
    } else if (list == null || list.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No Notification available yet',
          subTitle: 'When new notification found, they\'ll show up here.',
        ),
      );
    }
    return ListView.builder(
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) => FutureBuilder(
        future: notificationState.getTweetDetail(list[index].tweetKey),
        builder: (BuildContext context, AsyncSnapshot<Feed> snapshot) {
          if (snapshot.hasData) {
            return NotificationTile(
              feed: snapshot.data,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            return SizedBox(
              height: 4,
              child: LinearProgressIndicator(),
            );
          } else {
            notificationState.removeNotification(
                authState.userId, list[index].tweetKey);
            return SizedBox();
          }
        },
      ),
      itemCount: list.length,
    );
  }
}

class NotificationTile extends StatelessWidget {
  final Feed feed;

  const NotificationTile({Key key, this.feed}) : super(key: key);

  Widget _userList(BuildContext context, List<String> list) {
    // List<String> names = [];
    var length = list.length;
    List<Widget> avatarList = [];
    final int noOfUser = list.length;
    var state = Provider.of<NotificationState>(context);
    if (list != null && list.length > 5) {
      list = list.take(5).toList();
    }
    avatarList = list.map((userId) {
      return UserAvatar(userId, state, (name) {
        // names.add(name);
      });
    }).toList();
    if (noOfUser > 5) {
      avatarList.add(
        Text(
          " +${noOfUser - 5}",
          style: subtitleStyle.copyWith(fontSize: 16),
        ),
      );
    }

    var col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(width: 20),
            TwitterIcon(
                icon: AppIcon.heartFill,
                iconColor: TwitterColor.ceriseRed,
                size: 25),
            SizedBox(width: 10),
            Row(children: avatarList),
          ],
        ),
        // names.length > 0 ? Text(names[0]) : SizedBox(),
        Padding(
          padding: EdgeInsets.only(left: 60, bottom: 5, top: 5),
          child: TitleText(
            '$length people like your Tweet',
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
    return col;
  }

  Widget UserAvatar(String userId, NotificationState state,
      ValueChanged<String> name) {
    return FutureBuilder(
      future: state.getuserDetail(userId),
      //  initialData: InitialData,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          name(snapshot.data.displayName);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(
                    '/' + page.Profile + '/' + snapshot.data?.userId);
              },
              child:
                  customImage(context, snapshot.data.profilePict, height: 30),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var description = feed.description.length > 150
        ? feed.description.substring(0, 150) + '...'
        : feed.description;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: TwitterColor.white,
          child: ListTile(
            onTap: () {
              var state = Provider.of<FeedState>(context, listen: false);
              state.getPostDetailFromDatabase(null, feed: feed);
              Navigator.of(context).pushNamed(
                  '/' + page.FeedPostDetail + '/' + feed.key);
            },
            title: _userList(context, feed.likes),
            subtitle: Padding(
              padding: EdgeInsets.only(left: 60),
              child: UrlText(
                text: description,
                style: TextStyle(
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        Divider(height: 0, thickness: .6)
      ],
    );
  }
}
