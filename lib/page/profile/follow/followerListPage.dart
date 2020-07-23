import 'package:flutter/material.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/page/common/usersListPage.dart';
import 'package:twitter/state/authState.dart';
import 'package:provider/provider.dart';

class FollowerListPage extends StatelessWidget {
  FollowerListPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return UsersListPage(
      pageTitle: 'Followers',
      userIdsList: state.profileUserModel?.followersList,
      appBarIcon: AppIcon.follow,
      emptyScreenText: '${state?.profileUserModel?.userName ?? state.userModel.userName} doesn\'t have any followers',
      emptyScreenSubTileText: 'When someone follow them, they\'ll be listed here.',
    );
  }
}
