import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/tweet.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/user/user_tile.dart';

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
