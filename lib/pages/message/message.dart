import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twitter/model/message.dart';
import 'package:twitter/states/chat.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/network_image.dart';
import 'package:twitter/widgets/label/url.dart';

class MessageChat extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final bool isMyMessage;
  final Message chat;
  final String userImage;
  final ChatState chatState;

  MessageChat(this.chat, this.isMyMessage, this.userImage, this.chatState);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment:
          isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              width: 15,
            ),
            isMyMessage
                ? SizedBox()
                : CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: customAdvanceNetworkImage(userImage),
                  ),
            Expanded(
              child: Container(
                alignment:
                    isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                margin: EdgeInsets.only(
                  right: isMyMessage ? 10 : (fullWidth(context) / 4),
                  top: 20,
                  left: isMyMessage ? (fullWidth(context) / 4) : 10,
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: getBorder(isMyMessage),
                        color: isMyMessage
                            ? TwitterColor.dodgetBlue
                            : TwitterColor.mystic,
                      ),
                      child: UrlText(
                        text: chat.message,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isMyMessage ? TwitterColor.white : Colors.black,
                        ),
                        urlStyle: TextStyle(
                          fontSize: 16,
                          color: isMyMessage
                              ? TwitterColor.white
                              : TwitterColor.dodgetBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: InkWell(
                        borderRadius: getBorder(isMyMessage),
                        onLongPress: () {
                          var text = ClipboardData(text: chat.message);
                          Clipboard.setData(text);
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              backgroundColor: TwitterColor.white,
                              content: Text(
                                'Message copied',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        },
                        child: SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 10, left: 10),
          child: Text(
            getChatTime(chat.createdAt),
            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12),
          ),
        )
      ],
    );
  }

  BorderRadius getBorder(bool myMessage) {
    return BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomRight: myMessage ? Radius.circular(0) : Radius.circular(20),
      bottomLeft: myMessage ? Radius.circular(20) : Radius.circular(0),
    );
  }
}
