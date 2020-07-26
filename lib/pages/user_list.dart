import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/search.dart';
import 'package:twitter/states/tweet.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/notify.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/list/user_list.dart';
import 'package:twitter/widgets/navigation/appbar.dart';

class UsersListPage extends StatelessWidget {
  UsersListPage({
    Key key,
    this.pageTitle = "",
    this.appBarIcon,
    this.emptyScreenText,
    this.emptyScreenSubTileText,
    this.userIdsList,
  }) : super(key: key);

  final String pageTitle;
  final String emptyScreenText;
  final String emptyScreenSubTileText;
  final int appBarIcon;
  final List<String> userIdsList;

  @override
  Widget build(BuildContext context) {
    List<User> userList;
    return Scaffold(
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
          isBackButton: true,
          title: customTitleText(pageTitle),
          icon: appBarIcon),
      body: Consumer<SearchState>(
        builder: (context, state, child) {
          if (userIdsList != null && userIdsList.isNotEmpty) {
            userList = state.getuserDetail(userIdsList);
          }
          return !(userList != null && userList.isNotEmpty)
              ? Container(
                  width: fullWidth(context),
                  padding: EdgeInsets.only(top: 0, left: 30, right: 30),
                  child: NotifyText(
                    title: emptyScreenText,
                    subTitle: emptyScreenSubTileText,
                  ),
                )
              : UserListWidget(
                  list: userList,
                  emptyScreenText: emptyScreenText,
                  emptyScreenSubTileText: emptyScreenSubTileText,
                );
        },
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({Key key, this.list, this.textEditingController})
      : super(key: key);
  final List<User> list;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return !Provider.of<Tweet>(context).displayUserList ||
            list == null ||
            list.length < 0 ||
            list.length == 0
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsetsDirectional.only(bottom: 50),
            color: TwitterColor.white,
            constraints:
                BoxConstraints(minHeight: 30, maxHeight: double.infinity),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return UserTile(
                  user: list[index],
                  onUserSelected: (user) {
                    textEditingController.text = Provider.of<Tweet>(context)
                            .getDescription(user.userName) +
                        " ";
                    textEditingController.selection = TextSelection.collapsed(
                        offset: textEditingController.text.length);
                    Provider.of<Tweet>(context).onUserSelected();
                  },
                );
              },
            ),
          );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({Key key, this.user, this.onUserSelected}) : super(key: key);
  final User user;
  final ValueChanged<User> onUserSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onUserSelected(user);
      },
      leading: customImage(context, user.profilePict, height: 35),
      title: Row(
        children: <Widget>[
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: 0, maxWidth: fullWidth(context) * .5),
            child: TitleText(user.displayName,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 3),
          user.isVerified
              ? TwitterIcon(
                  icon: AppIcon.blueTick,
                  iconColor: AppColor.primary,
                  size: 13,
                  paddingIcon: 3,
                )
              : SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName),
    );
  }
}
