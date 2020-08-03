import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/tweet.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/user/user_tile.dart';

class UserList extends StatelessWidget {
  const UserList({Key key, this.data, this.textEditingController})
      : super(key: key);
  final List<User> data;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(bottom: 50),
      color: TwitterColor.white,
      constraints: BoxConstraints(minHeight: 30, maxHeight: double.infinity),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return UserTile(
            user: data[index],
            onTap: (user) {
              textEditingController.text = Provider.of<TweetState>(context)
                      .getDescription(user.userName) +
                  " ";
              textEditingController.selection = TextSelection.collapsed(
                  offset: textEditingController.text.length);
              Provider.of<TweetState>(context).onUserSelected();
            },
          );
        },
      ),
    );
  }
}
