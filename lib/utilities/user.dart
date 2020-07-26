import 'package:flutter/material.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/theme.dart';

/// `Create` and `Update` user
/// IF `newUser` is true new user is created
/// Else existing user will update with new values
User createUser(User user, {bool newUser = false}) {
  if (newUser) {
    // Create username by the combination of name and id
    user.userName = getUserName(id: user.userId, name: user.displayName);
    firebaseAnalytics.logEvent(name: 'create_newUser');

    // Time at which user is created
    user.createdAt = DateTime.now().toUtc().toString();
  }

  firebaseDatabase.child('profile').child(user.userId).set(user.toJson());
  return user;
//  _userModel = user;
//  if (_profileUserModelList != null) {
//    _profileUserModelList.last = _userModel;
//  }
//  loading = false;
}

String getUserName({
  String id,
  String name,
}) {
  String userName = '';
  if (name.length > 15) {
    name = name.substring(0, 6);
  }
  name = name.split(' ')[0];
  id = id.substring(0, 4).toLowerCase();
  userName = '@$name$id';
  return userName;
}

Widget userImage(String path, {double height = 100}) {
  return Container(
    child: Container(
      width: height,
      height: height,
      alignment: FractionalOffset.topCenter,
      decoration: BoxDecoration(
        boxShadow: shadow,
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(height / 2),
        image: DecorationImage(image: NetworkImage(path)),
      ),
    ),
  );
}
