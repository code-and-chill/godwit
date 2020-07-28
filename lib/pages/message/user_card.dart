import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/message.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/chat.dart';
import 'package:twitter/states/search.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/button/ripple.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/title.dart';

class UserCard extends StatelessWidget {
  final User user;
  final Message lastMessage;

  UserCard(this.user, this.lastMessage);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        onTap: () {
          final chatState = Provider.of<ChatState>(context, listen: false);
          final searchState = Provider.of<SearchState>(context, listen: false);
          chatState.setChatUser = user;
          if (searchState.users.any((x) => x.userId == user.userId)) {
            chatState.setChatUser =
                searchState.users.where((x) => x.userId == user.userId).first;
          }
          Navigator.pushNamed(context, '/ChatScreenPage');
        },
        leading: RippleButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/ProfilePage/${user.userId}');
          },
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(28),
              image: DecorationImage(
                  image: customAdvanceNetworkImage(
                    user.profilePict ?? mockProfilePicture,
                  ),
                  fit: BoxFit.cover),
            ),
          ),
        ),
        title: TitleText(
          user.displayName ?? "NA",
          fontSize: 16,
          fontWeight: FontWeight.w800,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: CustomText(
          getLastMessage(lastMessage.message) ?? '@${user.displayName}',
          style: onPrimarySubTitleText.copyWith(color: Colors.black54),
        ),
        trailing: lastMessage == null
            ? SizedBox.shrink()
            : Text(
                getChatTime(lastMessage.createdAt).toString(),
              ),
      ),
    );
  }

  String getLastMessage(String message) {
    if (message != null && message.isNotEmpty) {
      if (message.length > 100) {
        message = message.substring(0, 80) + '...';
        return message;
      } else {
        return message;
      }
    }
    return null;
  }
}
