import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/message.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/pages/message/message.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/chat.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/label/url.dart';

class ChatScreenPage extends StatefulWidget {
  ChatScreenPage({Key key, this.userProfileId}) : super(key: key);

  final String userProfileId;

  ChatScreenPageState createState() => ChatScreenPageState();
}

class ChatScreenPageState extends State<ChatScreenPage> {
  final messageController = new TextEditingController();
  String senderId;
  String userImage;
  ChatState state;
  ScrollController _controller;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _controller = ScrollController();
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.setIsChatScreenOpen = true;
    senderId = state.userId;
    chatState.databaseInit(chatState.chatUser.userId, state.userId);
    chatState.getchatDetailAsync();
    super.initState();
  }

  Widget _chatScreenBody() {
    final state = Provider.of<ChatState>(context);
    if (state.messageList == null || state.messageList.length == 0) {
      return Center(
        child: Text(
          'No message found',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.builder(
      controller: _controller,
      shrinkWrap: true,
      reverse: true,
      physics: BouncingScrollPhysics(),
      itemCount: state.messageList.length,
      itemBuilder: (context, index) => senderId == null
          ? Container()
          : MessageChat(state.messageList[index],
              state.messageList[index].senderId == senderId, userImage, state),
    );
  }

  Future<bool> _onWillPop() async {
    state.setIsChatScreenOpen = false;
    state.dispose();
    return true;
  }

  void submitMessage() {
    var authState = Provider.of<AuthState>(context, listen: false);
    Message message;
    message = Message(
        message: messageController.text,
        createdAt: DateTime.now().toUtc().toString(),
        senderId: authState.getUser.userId,
        receiverId: state.chatUser.userId,
        seen: false,
        timestamp: DateTime
            .now()
            .toUtc()
            .millisecondsSinceEpoch
            .toString(),
        senderName: authState.firebaseUser.displayName);
    if (messageController.text == null || messageController.text.isEmpty) {
      return;
    }
    User myUser = User(
        displayName: authState.getUser.displayName,
        userId: authState.getUser.userId,
        userName: authState.getUser.userName,
        profilePict: authState.getUser.profilePict);
    User secondUser = User(
      displayName: state.chatUser.displayName,
      userId: state.chatUser.userId,
      userName: state.chatUser.userName,
      profilePict: state.chatUser.profilePict,
    );
    state.onMessageSubmitted(message, myUser: myUser, secondUser: secondUser);
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      messageController.clear();
    });
    try {
      if (state.messageList != null &&
          state.messageList.length > 1 &&
          _controller.offset > 0) {
        _controller.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    } catch (e) {
      print("[Error] $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    state = Provider.of<ChatState>(context, listen: false);
    userImage = state.chatUser.profilePict;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              UrlText(
                text: state.chatUser.displayName,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                state.chatUser.userName,
                style: TextStyle(color: AppColor.darkGrey, fontSize: 15),
              )
            ],
          ),
          iconTheme: IconThemeData(color: Colors.blue),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.info, color: AppColor.primary),
                onPressed: () {
                  Navigator.pushNamed(context, '/ConversationInformation');
                })
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: _chatScreenBody(),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Divider(
                      thickness: 0,
                      height: 1,
                    ),
                    TextField(
                      onSubmitted: (val) async {
                        submitMessage();
                      },
                      controller: messageController,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                        alignLabelWithHint: true,
                        hintText: 'Start with a message...',
                        suffixIcon: IconButton(
                            icon: Icon(Icons.send), onPressed: submitMessage),
                        // fillColor: Colors.black12, filled: true
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
