import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as fbDatabase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as Path;
import 'package:twitter/model/user.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/user.dart';
import 'package:twitter/utilities/widget.dart';

import 'app.dart';

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  FirebaseUser firebaseUser;
  String userId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  fbDatabase.Query profileQuery;
  List<User> profileUsers;
  User _user;

  User get getUser => _user;

  User get profileUser {
    if (profileUsers != null && profileUsers.length > 0) {
      return profileUsers.last;
    } else {
      return null;
    }
  }

  void removeLastUser() {
    profileUsers.removeLast();
  }

  /// Logout from device
  void logoutCallback() {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    _user = null;
    firebaseUser = null;
    profileUsers = null;

    if (isSignInWithGoogle) {
      googleSignIn.signOut();
      logEvent('google_logout');
    }
    FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  /// Alter select auth method, login and sign up page
  void openSignUpPage() {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    notifyListeners();
  }

  databaseInit() {
    try {
      if (profileQuery == null) {
        profileQuery.onValue.listen(_onProfileChanged);
      }
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  /// Verify user's credentials for login
  Future<String> signIn(String email, String password,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      loading = true;
      var result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      firebaseUser = result.user;
      userId = firebaseUser.uid;
      return firebaseUser.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signIn');
      firebaseAnalytics.logLogin(loginMethod: 'email_login');
      customSnackBar(scaffoldKey, error.message);
      // logoutCallback();
      return null;
    }
  }

  /// Create user from `google login`
  /// If user is new then it create a new user
  /// If user is old then it just `authenticate` user and return firebase user data
  Future<FirebaseUser> handleGoogleSignIn() async {
    try {
      /// Record log in firebase kAnalytics about Google login
      firebaseAnalytics.logLogin(loginMethod: 'google_login');
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google login cancelled by user');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      firebaseUser =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      authStatus = AuthStatus.LOGGED_IN;
      userId = firebaseUser.uid;
      isSignInWithGoogle = true;
      createUserFromGoogleSignIn(firebaseUser);
      notifyListeners();
      return firebaseUser;
    } on PlatformException catch (error) {
      firebaseUser = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    } on Exception catch (error) {
      firebaseUser = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    } catch (error) {
      firebaseUser = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    }
  }

  /// Create user profile from google login
  createUserFromGoogleSignIn(FirebaseUser user) {
    var diff = DateTime.now().difference(user.metadata.creationTime);
    // Check if user is new or old
    // If user is new then add new user to firebase realtime kDatabase
    if (diff < Duration(seconds: 15)) {
      User model = User(
        bio: 'Edit profile to update bio',
        dateOfBirth:
        DateTime(1950, DateTime
            .now()
            .month, DateTime
            .now()
            .day + 3)
            .toString(),
        location: 'Somewhere in universe',
        profilePict: user.photoUrl,
        displayName: user.displayName,
        email: user.email,
        key: user.uid,
        userId: user.uid,
        contact: user.phoneNumber,
        isVerified: user.isEmailVerified,
      );
      createUser(model, newUser: true);
    } else {
      cprint('Last login at: ${user.metadata.lastSignInTime}');
    }
  }

  /// Create new user's profile in db
  Future<String> signUp(User userModel,
      {GlobalKey<ScaffoldState> scaffoldKey, String password}) async {
    try {
      loading = true;
      var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );
      firebaseUser = result.user;
      authStatus = AuthStatus.LOGGED_IN;
      firebaseAnalytics.logSignUp(signUpMethod: 'register');
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = userModel.displayName;
      updateInfo.photoUrl = userModel.profilePict;
      await result.user.updateProfile(updateInfo);
      _user = userModel;
      _user.key = firebaseUser.uid;
      _user.userId = firebaseUser.uid;
      createUser(_user, newUser: true);
      return firebaseUser.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signUp');
      customSnackBar(scaffoldKey, error.message);
      return null;
    }
  }

  /// `Create` and `Update` user
  /// IF `newUser` is true new user is created
  /// Else existing user will update with new values
  createUser(User user, {bool newUser = false}) {
    if (newUser) {
      // Create username by the combination of name and id
      user.userName = getUserName(id: user.userId, name: user.displayName);
      firebaseAnalytics.logEvent(name: 'create_newUser');

      // Time at which user is created
      user.createdAt = DateTime.now().toUtc().toString();
    }

    firebaseDatabase.child('profile').child(user.userId).set(user.toJson());
    _user = user;
    if (profileUsers != null) {
      profileUsers.last = _user;
    }
    loading = false;
  }

  /// Fetch current user profile
  Future<FirebaseUser> getCurrentUser() async {
    try {
      loading = true;
      logEvent('get_currentUSer');
      firebaseUser = await FirebaseAuth.instance.currentUser();
      if (firebaseUser != null) {
        authStatus = AuthStatus.LOGGED_IN;
        userId = firebaseUser.uid;
        getProfileUser();
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
      loading = false;
      return firebaseUser;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getCurrentUser');
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    }
  }

  /// Reload user to get refresh user data
  reloadUser() async {
    await firebaseUser.reload();
    firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser.isEmailVerified) {
      getUser.isVerified = true;
      // If user verified his email
      // Update user in firebase realtime kDatabase
      createUser(getUser);
      cprint('User email verification complete');
      logEvent('email_verification_complete',
          parameter: {getUser.userName: firebaseUser.email});
    }
  }

  /// Send email verification link to email2
  Future<void> sendEmailVerification(
      GlobalKey<ScaffoldState> scaffoldKey) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.sendEmailVerification().then((_) {
      logEvent('email_verification_sent',
          parameter: {getUser.displayName: user.email});
      customSnackBar(
        scaffoldKey,
        'An email verification link is send to your email.',
      );
    }).catchError((error) {
      cprint(error.message, errorIn: 'sendEmailVerification');
      logEvent('email_verification_block',
          parameter: {getUser.displayName: user.email});
      customSnackBar(
        scaffoldKey,
        error.message,
      );
    });
  }

  /// Check if user's email is verified
  Future<bool> isEmailVerified() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.isEmailVerified;
  }

  /// Send password reset link to email
  Future<void> forgetPassword(String email,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((
          value) {
        customSnackBar(scaffoldKey,
            'A reset password link is sent yo your mail.You can reset your password from there');
        logEvent('forgot+password');
      }).catchError((error) {
        cprint(error.message);
        return false;
      });
    } catch (error) {
      customSnackBar(scaffoldKey, error.message);
      return Future.value(false);
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfile(User userModel, {File image}) async {
    try {
      if (image == null) {
        createUser(userModel);
      } else {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('user/profile/${Path.basename(image.path)}');
        StorageUploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.onComplete.then((value) {
          storageReference.getDownloadURL().then((fileURL) async {
            print(fileURL);
            UserUpdateInfo updateInfo = UserUpdateInfo();
            updateInfo.displayName =
                userModel?.displayName ?? firebaseUser.displayName;
            updateInfo.photoUrl = fileURL;
            await firebaseUser.updateProfile(updateInfo);
            if (userModel != null) {
              userModel.profilePict = fileURL;
              createUser(userModel);
            } else {
              _user.profilePict = fileURL;
              createUser(_user);
            }
          });
        });
      }
      logEvent('update_user');
    } catch (error) {
      cprint(error, errorIn: 'updateUserProfile');
    }
  }

  /// `Fetch` user `detail` whoose userId is passed
  Future<User> getUserDetail(String userId) async {
    User user;
    var snapshot = await firebaseDatabase.child('profile').child(userId).once();
    if (snapshot.value != null) {
      var map = snapshot.value;
      user = User.fromJson(map);
      user.key = snapshot.key;
      return user;
    } else {
      return null;
    }
  }

  /// Fetch user profile
  /// If `userProfileId` is null then logged in user's profile will fetched
  getProfileUser({String userProfileId}) {
    try {
      loading = true;
      if (profileUsers == null) {
        profileUsers = [];
      }

      userProfileId = userProfileId == null ? firebaseUser.uid : userProfileId;
      firebaseDatabase
          .child("profile")
          .child(userProfileId)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            profileUsers.add(User.fromJson(map));
            if (userProfileId == firebaseUser.uid) {
              _user = profileUsers.last;
              _user.isVerified = firebaseUser.isEmailVerified;
              if (!firebaseUser.isEmailVerified) {
                // Check if logged in user verified his email address or not
                reloadUser();
              }
              if (_user.fcmToken == null) {
                updateFCMToken();
              }
            }

            logEvent('get_profile');
          }
        }
        loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  /// if firebase token not available in profile
  /// Then get token from firebase and save it to profile
  /// When someone sends you a message FCM token is used
  void updateFCMToken() {
    if (_user == null) {
      return;
    }
    getProfileUser();
    firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _user.fcmToken = token;
      createUser(_user);
    });
  }

  /// Follow / Unfollow user
  ///
  /// If `removeFollower` is true then remove user from follower list
  ///
  /// If `removeFollower` is false then add user to follower list
  followUser({bool removeFollower = false}) {
    /// `userModel` is user who is logged-in app.
    /// `profileUserModel` is user whose profile is open in app.
    try {
      if (removeFollower) {
        /// If logged-in user `already follow `profile user then
        /// 1.Remove logged-in user from profile user's `follower` list
        /// 2.Remove profile user from logged-in user's `following` list
        profileUser.followers.remove(getUser.userId);

        /// Remove profile user from logged-in user's following list
        getUser.following.remove(profileUser.userId);
        cprint('user removed from following list', event: 'remove_follow');
      } else {
        /// if logged in user is `not following` profile user then
        /// 1.Add logged in user to profile user's `follower` list
        /// 2. Add profile user to logged in user's `following` list
        if (profileUser.followers == null) {
          profileUser.followers = [];
        }
        profileUser.followers.add(getUser.userId);
        // Adding profile user to logged-in user's following list
        if (getUser.following == null) {
          getUser.following = [];
        }
        getUser.following.add(profileUser.userId);
      }
      // update profile user's user follower count
      profileUser.followers = profileUser.followers;
      // update logged-in user's following count
      getUser.following = getUser.following;
      firebaseDatabase
          .child('profile')
          .child(profileUser.userId)
          .child('followerList')
          .set(profileUser.followers);
      firebaseDatabase
          .child('profile')
          .child(getUser.userId)
          .child('followingList')
          .set(getUser.following);
      cprint('user added to following list', event: 'add_follow');
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }

  /// Trigger when logged-in user's profile change or updated
  /// Firebase event callback for profile update
  void _onProfileChanged(Event event) {
    if (event.snapshot != null) {
      final updatedUser = User.fromJson(event.snapshot.value);
      if (updatedUser.userId == firebaseUser.uid) {
        _user = updatedUser;
      }
      cprint('User Updated');
      notifyListeners();
    }
  }
}
