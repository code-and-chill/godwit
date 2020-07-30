import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/chat.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/button/ripple.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/url.dart';
import 'package:twitter/widgets/layout/settings_row.dart';
import 'package:twitter/widgets/navigation/appbar.dart';
import 'package:twitter/widgets/navigation/header.dart';

class ConversationInformation extends StatelessWidget {
  const ConversationInformation({Key key}) : super(key: key);

  Widget _header(BuildContext context, User user) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: SizedBox(
                height: 80,
                width: 80,
                child: RippleButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('/ProfilePage/' + user?.userId);
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: customImage(context, user.profilePict, height: 80),
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              UrlText(
                text: user.displayName,
                style: onPrimaryTitleText.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              user.isVerified
                  ? TwitterIcon(
                      icon: AppIcon.blueTick,
                      iconColor: AppColor.primary,
                      size: 18,
                      paddingIcon: 3,
                    )
                  : SizedBox(width: 0),
            ],
          ),
          CustomText(
            user.userName,
            style: onPrimarySubTitleText.copyWith(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<ChatState>(context).chatUser ?? User();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customText(
          'Conversation information',
        ),
      ),
      body: ListView(
        children: <Widget>[
          _header(context, user),
          HeaderWidget('Notifications'),
          SettingRowWidget(
            "Mute conversation",
            visibleSwitch: true,
          ),
          Container(
            height: 15,
            color: TwitterColor.mystic,
          ),
          SettingRowWidget(
            "Block ${user.userName}",
            textColor: TwitterColor.dodgetBlue,
            showDivider: false,
          ),
          SettingRowWidget("Report ${user.userName}", textColor: TwitterColor.dodgetBlue, showDivider: false),
          SettingRowWidget("Delete conversation", textColor: TwitterColor.ceriseRed, showDivider: false),
        ],
      ),
    );
  }
}
