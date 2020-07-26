import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/pages/user_list.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/constant.dart';

class FollowingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return UsersListPage(
        pageTitle: 'Following',
        userIdsList: state.profileUser.following,
        appBarIcon: AppIcon.follow,
        emptyScreenText:
            '${state?.profileUser?.userName ?? state.userModel.userName} isn\'t follow anyone',
        emptyScreenSubTileText: 'When they do they\'ll be listed here.');
  }
}
