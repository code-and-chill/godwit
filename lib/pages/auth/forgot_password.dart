import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/input/text_field.dart';
import 'package:twitter/widgets/label/text.dart';

class ForgetPasswordPage extends StatefulWidget {
  final VoidCallback loginCallback;

  const ForgetPasswordPage({Key key, this.loginCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  FocusNode focusNode;
  TextEditingController emailController;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    focusNode = FocusNode();
    emailController = TextEditingController(text: '');
    focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: CustomText('Forget Password', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: Container(
          height: fullHeight(context),
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  child: Column(
                children: <Widget>[
                  CustomText('Forget Password',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: CustomText(
                        'Enter your email address below to receive password reset instruction',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54),
                        align: TextAlign.center),
                  )
                ],
              )),
              SizedBox(height: 50),
              CustomTextField(hint: 'Enter email', controller: emailController),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  width: MediaQuery.of(context).size.width,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    color: TwitterColor.dodgetBlue,
                    onPressed: () {
                      if (emailController.text == null ||
                          emailController.text.isEmpty) {
                        customSnackBar(
                            scaffoldKey, 'Email field cannot be empty');
                        return;
                      }
                      if (!validateEmail(emailController.text)) {
                        customSnackBar(
                            scaffoldKey, 'Please enter valid email address');
                        return;
                      }

                      focusNode.unfocus();
                      state.forgetPassword(emailController.text,
                          scaffoldKey: scaffoldKey);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child:
                        Text('Submit', style: TextStyle(color: Colors.white)),
                  )),
            ],
          )),
    );
  }
}
