import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/page.dart' as page;
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/navigation/appbar.dart';
import 'package:twitter/widgets/navigation/header.dart';

import '../../widgets/layout/settings_row.dart';

class SettingsAndPrivacyPage extends StatelessWidget {
  const SettingsAndPrivacyPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).getUser ?? User();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customText(
          'Settings and privacy',
        ),
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget(user.userName),
          SettingRowWidget(
            "Account",
            navigateTo: page.Account,
          ),
          Divider(height: 0),
          SettingRowWidget("Privacy and Policy",
              navigateTo: page.PrivacyAndSafety),
          SettingRowWidget("Notification", navigateTo: page.Notification),
          SettingRowWidget("Content preferences",
              navigateTo: page.ContentPreference),
          HeaderWidget(
            'General',
            secondHeader: true,
          ),
          SettingRowWidget("Display and Sound",
              navigateTo: 'DisplayAndSoundPage'),
          SettingRowWidget("Data usage", navigateTo: page.DataUsage),
          SettingRowWidget("Accessibility", navigateTo: page.Accessibility),
          SettingRowWidget("Proxy", navigateTo: page.Proxy),
          SettingRowWidget(
            "About Twitter",
            navigateTo: page.About,
          ),
          SettingRowWidget(
            null,
            showDivider: false,
            vPadding: 10,
            subtitle:
                'These settings affect all of your Twitter accounts on this device.',
          )
        ],
      ),
    );
  }
}
