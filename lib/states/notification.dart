import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:twitter/model/feed.dart';
import 'package:twitter/model/notification.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/app.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/enum.dart';

class NotificationState extends AppState {
  String fcmToken;
  NotificationType _notificationType = NotificationType.NOT_DETERMINED;
  String notificationReciverId, notificationTweetId;
  Feed notificationTweetModel;

  NotificationType get notificationType => _notificationType;

  set setNotificationType(NotificationType type) {
    _notificationType = type;
  }

  // FcmNotificationModel notification;
  String notificationSenderId;
  dabase.Query query;
  List<User> userList = [];

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<TwitterNotification> _notificationList;

  List<TwitterNotification> get notificationList => _notificationList;

  /// [Intitilise firebase notification kDatabase]
  Future<bool> databaseInit(String userId) {
    try {
      if (query == null) {
        query = firebaseDatabase.child("notification").child(userId);
        query.onChildAdded.listen(_onNotificationAdded);
        query.onChildChanged.listen(_onNotificationChanged);
        query.onChildRemoved.listen(_onNotificationRemoved);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Notification list] from firebase realtime database
  void getDataFromDatabase(String userId) {
    try {
      loading = true;
      _notificationList = [];
      firebaseDatabase
          .child('notification')
          .child(userId)
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            map.forEach((tweetKey, value) {
              var model = TwitterNotification.fromJson(
                  tweetKey, value["updatedAt"], snapshot.value["type"]);
              _notificationList.add(model);
            });
            _notificationList.sort((x, y) {
              if (x.updatedAt != null && y.updatedAt != null) {
                return DateTime.parse(y.updatedAt)
                    .compareTo(DateTime.parse(x.updatedAt));
              } else if (x.updatedAt != null) {
                return 1;
              } else
                return 0;
            });
          }
        }
        loading = false;
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get `Tweet` present in notification
  Future<Feed> getTweetDetail(String tweetId) async {
    Feed _tweetDetail;
    var snapshot = await firebaseDatabase.child('tweet').child(tweetId).once();
    if (snapshot.value != null) {
      var map = snapshot.value;
      _tweetDetail = Feed.fromJson(map);
      _tweetDetail.key = snapshot.key;
      return _tweetDetail;
    } else {
      return null;
    }
  }

  /// get user who liked your tweet
  Future<User> getuserDetail(String userId) async {
    User user;
    if (userList.length > 0 && userList.any((x) => x.userId == userId)) {
      return Future.value(userList.firstWhere((x) => x.userId == userId));
    }
    var snapshot = await firebaseDatabase.child('profile').child(userId).once();
    if (snapshot.value != null) {
      var map = snapshot.value;
      user = User.fromJson(map);
      user.key = snapshot.key;
      userList.add(user);
      return user;
    } else {
      return null;
    }
  }

  /// Remove notification if related Tweet is not found or deleted
  void removeNotification(String userId, String tweetkey) async {
    firebaseDatabase.child('notification').child(userId)
        .child(tweetkey)
        .remove();
  }

  /// Trigger when somneone like your tweet
  void _onNotificationAdded(Event event) {
    if (event.snapshot.value != null) {
      var model = TwitterNotification.fromJson(
          event.snapshot.key, event.snapshot.value["updatedAt"],
          event.snapshot.value["type"]);
      if (_notificationList == null) {
        _notificationList = List<TwitterNotification>();
      }
      _notificationList.add(model);
      // added notification to list
      print("Notification added");
      notifyListeners();
    }
  }

  /// Trigger when someone changed his like preference
  void _onNotificationChanged(Event event) {
    if (event.snapshot.value != null) {
      var model = TwitterNotification.fromJson(
          event.snapshot.key, event.snapshot.value["updatedAt"],
          event.snapshot.value["type"]);
      //update notification list
      _notificationList
          .firstWhere((x) => x.tweetKey == model.tweetKey)
          .tweetKey = model.tweetKey;
      notifyListeners();
      print("Notification changed");
    }
  }

  /// Trigger when someone undo his like on tweet
  void _onNotificationRemoved(Event event) {
    if (event.snapshot.value != null) {
      var model = TwitterNotification.fromJson(
          event.snapshot.key, event.snapshot.value["updatedAt"],
          event.snapshot.value["type"]);
      // remove notification from list
      _notificationList.removeWhere((x) => x.tweetKey == model.tweetKey);
      notifyListeners();
      print("Notification Removed");
    }
  }

  /// Configure notification services
  void initfirebaseService() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // print("onMessage: $message");
        print(message['data']);
        notifyListeners();
      },
      onLaunch: (Map<String, dynamic> message) async {
        cprint("Notification ", event: "onLaunch");
        var data = message['data'];
        // print(message['data']);
        notificationSenderId = data["senderId"];
        notificationReciverId = data["receiverId"];
        notificationReciverId = data["receiverId"];
        if (data["type"] == "NotificationType.Mention") {
          setNotificationType = NotificationType.Mention;
        } else if (data["type"] == "NotificationType.Message") {
          setNotificationType = NotificationType.Message;
        }
        notifyListeners();
      },
      onResume: (Map<String, dynamic> message) async {
        cprint("Notification ", event: "onResume");
        var data = message['data'];
        // print(message['data']);
        notificationSenderId = data["senderId"];
        notificationReciverId = data["receiverId"];
        if (data["type"] == "NotificationType.Mention") {
          setNotificationType = NotificationType.Mention;
        } else if (data["type"] == "NotificationType.Message") {
          setNotificationType = NotificationType.Message;
        }
        notifyListeners();
      },
    );
    _firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      fcmToken = token;
      print(token);
    });
  }
}
