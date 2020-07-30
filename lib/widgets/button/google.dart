import 'package:flutter/material.dart';
import 'package:twitter/widgets/button/social.dart';
import 'package:twitter/widgets/label/title.dart';

class GoogleButton extends StatelessWidget {
  final Function() action;

  GoogleButton(this.action);

  @override
  Widget build(BuildContext context) {
    return SocialButton(
      action: action,
      label: TitleText(
        'Continue with Google',
        color: Colors.black54,
      ),
      imageAsset: Image.asset(
        'assets/images/google_logo.png',
        height: 20,
        width: 20,
      ),
    );
  }
}
