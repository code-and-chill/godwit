import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/chat.dart';
import 'package:twitter/states/search.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/navigation/appbar.dart';

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<StatefulWidget> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  TextEditingController textController;

  @override
  void initState() {
    textController = TextEditingController();
    super.initState();
  }

  Widget _userTile(User user) {
    return ListTile(
      onTap: () {
        final chatState = Provider.of<ChatState>(context, listen: false);
        chatState.setChatUser = user;
        Navigator.pushNamed(context, '/ChatScreenPage');
      },
      leading: customImage(context, user.profilePict, height: 40),
      title: Row(
        children: <Widget>[
          ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: 0, maxWidth: fullWidth(context) - 104),
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
                  paddingIcon: 3)
              : SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName),
    );
  }

  Future<bool> _onWillPop() async {
    final state = Provider.of<SearchState>(context, listen: false);
    state.filterByUsername("");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          scaffoldKey: widget.scaffoldKey,
          isBackButton: true,
          isBottomLine: true,
          title: customText(
            'New Message',
          ),
        ),
        body: Consumer<SearchState>(
          builder: (context, state, child) {
            return Column(
              children: <Widget>[
                TextField(
                  onChanged: (text) {
                    state.filterByUsername(text);
                  },
                  decoration: InputDecoration(
                    hintText: "Search for people and groups",
                    hintStyle: TextStyle(fontSize: 20),
                    prefixIcon: TwitterIcon(
                      icon: AppIcon.search,
                      iconColor: TwitterColor.woodsmoke_50,
                      size: 25,
                      paddingIcon: 5,
                    ),
                    border: InputBorder.none,
                    fillColor: TwitterColor.mystic,
                    filled: true,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) =>
                        _userTile(
                          state.users[index],
                        ),
                    separatorBuilder: (_, index) =>
                        Divider(
                          height: 0,
                        ),
                    itemCount: state.users.length,
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
