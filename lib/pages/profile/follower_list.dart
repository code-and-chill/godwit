import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/pages/user_list.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';

class FollowListPage extends StatelessWidget {
  final String pageTitle;
  final FollowType followType;

  FollowListPage(this.followType, {Key key, this.pageTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    if (followType == FollowType.Followers) {
      return UsersListPage(
        pageTitle: pageTitle,
        userIdsList: state.profileUser?.followers,
        appBarIcon: AppIcon.follow,
        emptyScreenText:
            '${state?.profileUser?.userName ?? state.getUser.userName} doesn\'t have any followers',
        emptyScreenSubTileText:
            'When someone follow them, they\'ll be listed here.',
      );
    }
    return UsersListPage(
        pageTitle: 'Following',
        userIdsList: state.profileUser.following,
        appBarIcon: AppIcon.follow,
        emptyScreenText:
        '${state?.profileUser?.userName ??
            state.getUser.userName} isn\'t follow anyone',
        emptyScreenSubTileText: 'When they do they\'ll be listed here.');
  }
}
