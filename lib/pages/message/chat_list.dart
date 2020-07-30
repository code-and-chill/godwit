import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/pages/message/user_card.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/chat.dart';
import 'package:twitter/states/search.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/button/new_message.dart';
import 'package:twitter/widgets/empty/empty_list.dart';
import 'package:twitter/widgets/navigation/appbar.dart';

class ChatListPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ChatListPage({Key key, this.scaffoldKey}) : super(key: key);

  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.setIsChatScreenOpen = true;

    // chatState.databaseInit(state.profileUserModel.userId,state.userId);
    chatState.getUserchatList(state.firebaseUser.uid);
    super.initState();
  }

  Widget _body() {
    final state = Provider.of<ChatState>(context);
    final searchState = Provider.of<SearchState>(context, listen: false);
    if (state.chatUserList == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No message available ',
          subTitle:
              'When someone sends you message,User list\'ll show up here \n  To send message tap message button.',
        ),
      );
    } else {
      if (searchState.userList.isEmpty) {
        searchState.resetFilterList();
      }
      return ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: state.chatUserList.length,
        itemBuilder: (context, index) =>
            UserCard(
                searchState.users.firstWhere(
                      (x) => x.userId == state.chatUserList[index].key,
                  orElse: () => User(userName: "Unknown"),
                ),
                state.chatUserList[index]),
        separatorBuilder: (context, index) {
          return Divider(
            height: 0,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: customText(
          'Messages',
        ),
        icon: AppIcon.settings,
        onActionPressed: () {
          Navigator.pushNamed(context, '/DirectMessagesPage');
        },
      ),
      floatingActionButton: NewMessageButton(),
      backgroundColor: TwitterColor.mystic,
      body: _body(),
    );
  }
}
