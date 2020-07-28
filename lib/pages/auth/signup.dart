import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/button/social.dart';
import 'package:twitter/widgets/input/text_field.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/label/title.dart';
import 'package:twitter/widgets/layout/loader.dart';

class SignUp extends StatefulWidget {
  final VoidCallback loginCallback;

  const SignUp({Key key, this.loginCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  TextEditingController nameController;
  TextEditingController emailController;
  TextEditingController passwordController;
  TextEditingController confirmController;
  final CustomLoader loader = CustomLoader();
  final formKey = new GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuthState>(context);
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: CustomText(
            'Sign Up',
            style: TextStyle(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: fullHeight(context) - 88,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CustomTextField(
                    hint: 'name',
                    controller: nameController,
                  ),
                  CustomTextField(
                    hint: 'enter email',
                    controller: emailController,
                    isEmail: true,
                  ),
                  CustomTextField(
                    hint: 'enter password',
                    controller: passwordController,
                    isNeedToBeObscured: true,
                  ),
                  CustomTextField(
                    hint: 'confirm password',
                    controller: confirmController,
                    isNeedToBeObscured: true,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      color: TwitterColor.dodgetBlue,
                      onPressed: () {
                        if (!isFormSubmittedProperly()) {
                          return;
                        }

                        loader.showLoader(context);

                        User user = composeUser();
                        state
                            .signUp(user,
                                password: passwordController.text,
                                scaffoldKey: scaffoldKey)
                            .then((status) {})
                            .whenComplete(
                          () {
                            loader.hideLoader();
                            if (state.authStatus == AuthStatus.LOGGED_IN) {
                              Navigator.pop(context);
                              widget.loginCallback();
                            }
                          },
                        );
                      },
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Text('Sign up',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Divider(height: 30),
                  SizedBox(height: 30),
                  SocialButton(
                    action: () {
                      loader.showLoader(context);
                      state.handleGoogleSignIn().then((status) {
                        // print(status)
                        if (state.firebaseUser != null) {
                          loader.hideLoader();
                          Navigator.pop(context);
                          widget.loginCallback();
                        } else {
                          loader.hideLoader();
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
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ));
  }

  User composeUser() {
    Random random = new Random();
    int randomNumber = random.nextInt(8);
    return User(
      email: emailController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      displayName: nameController.text,
      dateOfBirth: DateTime(1950, DateTime
          .now()
          .month, DateTime
          .now()
          .day + 3)
          .toString(),
      location: 'Somewhere in universe',
      profilePict: mockProfilePictures[randomNumber],
      isVerified: false,
    );
  }

  bool isFormSubmittedProperly() {
    if (emailController.text.isEmpty) {
      customSnackBar(scaffoldKey, 'Please enter name');
      return false;
    }
    if (emailController.text.length > 27) {
      customSnackBar(scaffoldKey, 'Name length cannot exceed 27 character');
      return false;
    }
    if (emailController.text == null ||
        emailController.text.isEmpty ||
        passwordController.text == null ||
        passwordController.text.isEmpty ||
        confirmController.text == null) {
      customSnackBar(scaffoldKey, 'Please fill form carefully');
      return false;
    } else if (passwordController.text != confirmController.text) {
      customSnackBar(
          scaffoldKey, 'Password and confirm password did not match');
      return false;
    }
    return true;
  }
}
