import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/layout/settings_row.dart';
import 'package:twitter/widgets/navigation/header.dart';
import 'package:twitter/widgets/navigation/settings_appbar.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).getUser ?? User();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: SettingsAppBar(
        title: 'Account',
        subtitle: user?.userName,
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget('Login and security'),
          SettingRowWidget(
            "Username",
            subtitle: user?.userName,
            // navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          SettingRowWidget(
            "Phone",
            subtitle: user?.contact,
          ),
          SettingRowWidget(
            "Email address",
            subtitle: user?.email,
            navigateTo: 'VerifyEmailPage',
          ),
          SettingRowWidget("Password"),
          SettingRowWidget("Security"),
          HeaderWidget(
            'Data and Permission',
            secondHeader: true,
          ),
          SettingRowWidget("Country"),
          SettingRowWidget("Your Twitter data"),
          SettingRowWidget("Apps and sessions"),
          SettingRowWidget(
            "Log out",
            textColor: TwitterColor.ceriseRed,
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              final state = Provider.of<AuthState>(context);
              state.logoutCallback();
            },
          ),
        ],
      ),
    );
  }
}
