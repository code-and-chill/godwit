import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/label/text.dart';
import 'package:twitter/widgets/layout/loader.dart';

class SignUp extends StatefulWidget {
  final VoidCallback loginCallback;

  const SignUp({Key key, this.loginCallback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmController;
  final CustomLoader loader = CustomLoader();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: CustomText(
          'Sign Up',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: TwitterColor.dodgetBlue,
          onPressed: () {
            if (!isFormSubmittedProperly()) return;
            loader.showLoader(context);
            var state = Provider.of<AuthState>(context, listen: false);
            User user = composeUser();
            state
                .signUp(user,
                    password: _passwordController.text,
                    scaffoldKey: _scaffoldKey)
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
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text('Sign up', style: TextStyle(color: Colors.white)),
        ),
      )),
    );
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  User composeUser() {
    Random random = new Random();
    int randomNumber = random.nextInt(8);
    return User(
      email: _emailController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      displayName: _nameController.text,
      dateOfBirth: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
          .toString(),
      location: 'Somewhere in universe',
      profilePict: mockProfilePictures[randomNumber],
      isVerified: false,
    );
  }

  bool isFormSubmittedProperly() {
    if (_emailController.text.isEmpty) {
      customSnackBar(_scaffoldKey, 'Please enter name');
      return false;
    }
    if (_emailController.text.length > 27) {
      customSnackBar(_scaffoldKey, 'Name length cannot exceed 27 character');
      return false;
    }
    if (_emailController.text == null ||
        _emailController.text.isEmpty ||
        _passwordController.text == null ||
        _passwordController.text.isEmpty ||
        _confirmController.text == null) {
      customSnackBar(_scaffoldKey, 'Please fill form carefully');
      return false;
    } else if (_passwordController.text != _confirmController.text) {
      customSnackBar(
          _scaffoldKey, 'Password and confirm password did not match');
      return false;
    }
    return true;
  }
}
