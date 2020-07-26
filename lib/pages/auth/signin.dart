import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/page.dart' as page;
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/button/social.dart';
import 'package:twitter/widgets/input/text_field.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/layout/loader.dart';

class SignIn extends StatefulWidget {
  final Function loginCallback;

  const SignIn({Key key, this.loginCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController;
  TextEditingController passwordController;
  final CustomLoader loader = CustomLoader();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: CustomText('Sign in', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 150),
              CustomTextField(hint: 'Enter email', controller: emailController),
              CustomTextField(
                  hint: 'Enter password',
                  controller: passwordController,
                  isNeedToBeObscured: true),
              Container(
                width: fullWidth(context),
                margin: EdgeInsets.symmetric(vertical: 35),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  color: TwitterColor.dodgetBlue,
                  onPressed: () {
                    var state = Provider.of<AuthState>(context, listen: false);
                    if (state.isAppBusy) {
                      return;
                    }
                    loader.showLoader(context);
                    if (validateCredentials(scaffoldKey, emailController.text,
                        passwordController.text)) {
                      state
                          .signIn(emailController.text, passwordController.text,
                              scaffoldKey: scaffoldKey)
                          .then((status) {
                        if (state.firebaseUser != null) {
                          loader.hideLoader();
                          Navigator.pop(context);
                          widget.loginCallback();
                        } else {
                          loader.hideLoader();
                        }
                      });
                    } else {
                      loader.hideLoader();
                    }
                  },
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: TitleText('Submit', color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              SocialButton(
                  label: TitleText('Forget password?'),
                  action: () {
                    Navigator.of(context).pushNamed('/' + page.ForgetPassword);
                  }),
              Divider(
                height: 30,
              ),
              SizedBox(
                height: 30,
              ),
              SocialButton(
                action: () {
                  var state = Provider.of<AuthState>(context, listen: false);
                  loader.showLoader(context);
                  state.handleGoogleSignIn().then((status) {
                    if (state.firebaseUser != null) {
                      loader.hideLoader();
                      Navigator.pop(context);
                    } else {
                      loader.hideLoader();
                      cprint('Unable to login', errorIn: '_googleLoginButton');
                    }
                  });
                },
                label: TitleText(
                  'Continue with Google',
                  color: Colors.black54,
                ),
                imageAsset: Image.asset(
                  'assets/images/google_logo.png',
                  height: 20,
                  width: 20,
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
