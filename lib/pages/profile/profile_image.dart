import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/choice.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';

class ProfileImageView extends StatelessWidget {
  const ProfileImageView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const List<Choice> choices = const <Choice>[
      const Choice(title: 'Share image link', icon: Icons.share),
      const Choice(title: 'Open in browser', icon: Icons.open_in_browser),
      const Choice(title: 'Save', icon: Icons.save),
    ];
    var authState = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: (d) {
              switch (d.title) {
                case "Share image link":
                  share(authState.profileUser.profilePict);
                  break;
                case "Open in browser":
                  launchURL(authState.profileUser.profilePict);
                  break;
                case "Save":
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: fullWidth(context),
          // height: fullWidth(context),
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  customAdvanceNetworkImage(authState.profileUser.profilePict),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
