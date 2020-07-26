import 'package:flutter/material.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/layout/settings_row.dart';
import 'package:twitter/widgets/navigation/appbar.dart';
import 'package:twitter/widgets/navigation/header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'About Twitter',
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(
            'Help',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Help Centre",
            vPadding: 0,
            showDivider: false,
            onPressed: () {
              launchURL("https://github.com/TheAlphamerc/twitter/issues");
            },
          ),
          HeaderWidget('Legal'),
          SettingRowWidget(
            "Terms of Service",
            showDivider: true,
          ),
          SettingRowWidget(
            "Privacy policy",
            showDivider: true,
          ),
          SettingRowWidget(
            "Cookie use",
            showDivider: true,
          ),
          SettingRowWidget(
            "Legal notices",
            showDivider: true,
            onPressed: () async {
              showLicensePage(
                context: context,
                applicationName: 'Fwitter',
                applicationVersion: '1.0.0',
                useRootNavigator: true,
              );
            },
          ),
          HeaderWidget('Developer'),
          SettingRowWidget("Github", showDivider: true, onPressed: () {
            launchURL("https://github.com/TheAlphamerc");
          }),
          SettingRowWidget("LinkidIn", showDivider: true, onPressed: () {
            launchURL("https://www.linkedin.com/in/thealphamerc/");
          }),
          SettingRowWidget("Twitter", showDivider: true, onPressed: () {
            launchURL("https://twitter.com/TheAlphaMerc");
          }),
          SettingRowWidget("Blog", showDivider: true, onPressed: () {
            launchURL("https://dev.to/thealphamerc");
          }),
        ],
      ),
    );
  }
}
