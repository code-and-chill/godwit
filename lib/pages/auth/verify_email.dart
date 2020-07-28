import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/label/notify.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/title.dart';

class VerifyEmailPage extends StatefulWidget {
  final VoidCallback loginCallback;

  const VerifyEmailPage({Key key, this.loginCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TwitterColor.mystic,
      appBar: AppBar(
        title: CustomText(
          'Email Verification',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: fullHeight(context),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: state.firebaseUser.isEmailVerified
              ? <Widget>[
                  NotifyText(
                    title: 'Your email address is verified',
                    subTitle:
                        'You have got your blue tick on your name. Cheers !!',
                  ),
                ]
              : <Widget>[
                  NotifyText(
                    title: 'Verify your email address',
                    subTitle:
                        'Send email verification email link to ${state.firebaseUser.email} to verify address',
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Wrap(
                      children: <Widget>[
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          color: Colors.blueAccent,
                          onPressed: () {
                            state.sendEmailVerification(_scaffoldKey);
                          },
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          child: TitleText(
                            'Send Link',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
