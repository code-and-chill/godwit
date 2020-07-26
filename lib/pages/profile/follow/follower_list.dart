import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/pages/user_list.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/constant.dart';

class FollowerListPage extends StatelessWidget {
  FollowerListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return UsersListPage(
      pageTitle: 'Followers',
      userIdsList: state.profileUser?.followers,
      appBarIcon: AppIcon.follow,
      emptyScreenText:
          '${state?.profileUser?.userName ?? state.userModel.userName} doesn\'t have any followers',
      emptyScreenSubTileText:
          'When someone follow them, they\'ll be listed here.',
    );
  }
}
