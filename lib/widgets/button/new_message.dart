import 'package:flutter/material.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/page.dart' as page;
import 'package:twitter/widgets/image/twitter_icon.dart';

class NewMessageButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/' + page.NewMessage);
      },
      child: TwitterIcon(
        icon: AppIcon.newMessage,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }
}
