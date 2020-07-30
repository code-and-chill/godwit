import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as fbDatabase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:twitter/model/feed.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/app.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/validator.dart';

class FeedState extends AppState {
  bool isBusy = false;

  List<Feed> feeds;

  List<Feed> get getFeeds {
    if (feeds == null) {
      return null;
    } else {
      return List.from(feeds.reversed);
    }
  }

  fbDatabase.Query feedQuery;

  List<Feed> comments;

  Feed tweetToReply;

  Feed get getTweetToReply => tweetToReply;

  set setTweetToReply(Feed feed) {
    tweetToReply = feed;
  }

  List<Feed> tweetDetails;

  List<Feed> get getTweetDetails => tweetDetails;

  List<String> userFollowings;

  List<String> get getFollowings => userFollowings;

  Map<String, List<Feed>> tweetReplyMap = {};

  Future<bool> databaseInit() {
    try {
      if (feedQuery == null) {
        feedQuery = firebaseDatabase.child("tweet");
        feedQuery.onChildAdded.listen(onTweetAdded);
        feedQuery.onValue.listen(_onTweetChanged);
        feedQuery.onChildRemoved.listen(onTweetRemoved);
      }

      return Future.value(true);
    } catch (error) {
      return Future.value(false);
    }
  }

  void getDataFromDatabase() {
    try {
      isBusy = true;
      feeds = null;
      notifyListeners();
      firebaseDatabase.child('tweet').once().then((DataSnapshot snapshot) {
        feeds = List<Feed>();
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            map.forEach((key, value) {
              var feed = Feed.fromJson(value);
              feed.key = key;
              if (isValidTweet(feed)) {
                feeds.add(feed);
              }
            });

            feeds.sort((x, y) => DateTime.parse(x.createdAt)
                .compareTo(DateTime.parse(y.createdAt)));
          }
        } else {
          feeds = null;
        }
        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  List<Feed> getTweetList(User user) {
    if (user == null) {
      return null;
    }

    List<Feed> list;

    if (!isBusy && getFeeds != null && getFeeds.isNotEmpty) {
      list = getFeeds.where((x) {
        if (x.parentKey != null &&
            x.childRetweetKey == null &&
            x.user.userId != user.userId) {
          return false;
        }
        if (x.user.userId == user.userId ||
            (user?.following != null &&
                user.following.contains(x.user.userId))) {
          return true;
        } else {
          return false;
        }
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }
    return list;
  }

  set setFeed(Feed feed) {
    if (tweetDetails == null) {
      tweetDetails = [];
    }
    if (tweetDetails.length >= 0) {
      tweetDetails.add(feed);
      cprint("Detail Tweet added. Total Tweet: ${tweetDetails.length}");
      notifyListeners();
    }
  }

  void removeLastTweetDetail(String tweetKey) {
    if (tweetDetails != null && tweetDetails.length > 0) {
      Feed removeTweet = tweetDetails.lastWhere((x) => x.key == tweetKey);
      tweetDetails.remove(removeTweet);
      tweetReplyMap.removeWhere((key, value) => key == tweetKey);
    }
  }

  void clearAllDetailAndReplyTweetStack() {
    if (tweetDetails != null) {
      tweetDetails.clear();
    }
    if (tweetReplyMap != null) {
      tweetReplyMap.clear();
    }
    cprint('Empty tweets from stack');
  }

  void getPostDetailFromDatabase(String postID, {Feed feed}) async {
    try {
      Feed tweetDetail;
      if (feed != null) {
        tweetDetail = feed;
        setFeed = tweetDetail;
        postID = feed.key;
      } else {
        // Fetch tweet data from firebase
        firebaseDatabase
            .child('tweet')
            .child(postID)
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            var map = snapshot.value;
            tweetDetail = Feed.fromJson(map);
            tweetDetail.key = snapshot.key;
            setFeed = tweetDetail;
          }
        });
      }

      if (tweetDetail != null) {
        comments = List<Feed>();
        if (tweetDetail.replyTweetKeys != null &&
            tweetDetail.replyTweetKeys.length > 0) {
          tweetDetail.replyTweetKeys.forEach((x) {
            if (x == null) {
              return;
            }
            firebaseDatabase
                .child('tweet')
                .child(x)
                .once()
                .then((DataSnapshot snapshot) {
              if (snapshot.value != null) {
                var comment = Feed.fromJson(snapshot.value);
                var key = snapshot.key;
                comment.key = key;
                if (!comments.any((x) => x.key == key)) {
                  comments.add(comment);
                }
              } else {}
              if (x == tweetDetail.replyTweetKeys.last) {
                comments.sort((x, y) =>
                    DateTime.parse(y.createdAt)
                        .compareTo(DateTime.parse(x.createdAt)));
                tweetReplyMap.putIfAbsent(postID, () => comments);
                notifyListeners();
              }
            });
          });
        } else {
          tweetReplyMap.putIfAbsent(postID, () => comments);
          notifyListeners();
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'getPostDetailFromDatabase');
    }
  }

  Future<Feed> fetchTweet(String postID) async {
    Feed _tweetDetail;
    if (getFeeds.any((x) => x.key == postID)) {
      _tweetDetail = getFeeds.firstWhere((x) => x.key == postID);
    }

    /// If tweet is not available in feeds then need to fetch it from firebase
    else {
      cprint("Fetched from DB: " + postID);
      var model =
      await firebaseDatabase.child('tweet').child(postID).once().then(
            (DataSnapshot snapshot) {
          if (snapshot.value != null) {
            var map = snapshot.value;
            _tweetDetail = Feed.fromJson(map);
            _tweetDetail.key = snapshot.key;
            print(_tweetDetail.description);
          }
        },
      );
      if (model != null) {
        _tweetDetail = model;
      } else {
        cprint("Fetched null value from  DB");
      }
    }
    return _tweetDetail;
  }

  createTweet(Feed feed) {
    isBusy = true;
    notifyListeners();
    try {
      firebaseDatabase.child('tweet').push().set(feed.toJson());
    } catch (error) {
      cprint(error, errorIn: 'createTweet');
    }
    isBusy = false;
    notifyListeners();
  }

  createReTweet(Feed feed) {
    try {
      createTweet(feed);
      tweetToReply.retweetCount += 1;
      updateTweet(tweetToReply);
    } catch (error) {
      cprint(error, errorIn: 'createReTweet');
    }
  }

  deleteTweet(String tweetId, TweetType type, {String parentKey}) {
    try {
      firebaseDatabase.child('tweet').child(tweetId).remove().then((_) {
        if (type == TweetType.Detail &&
            tweetDetails != null &&
            tweetDetails.length > 0) {
          tweetDetails.remove(tweetDetails);
          if (tweetDetails.length == 0) {
            tweetDetails = null;
          }
        }
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteTweet');
    }
  }

  /// upload [file] to firebase storage and return its  path url
  Future<String> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('tweetImage${Path.basename(file.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(file);
      var snapshot = await uploadTask.onComplete;
      if (snapshot != null) {
        var url = await storageReference.getDownloadURL();
        if (url != null) {
          return url;
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'uploadFile');
      return null;
    }
  }

  /// [Delete file] from firebase storage
  Future<void> deleteFile(String url, String baseUrl) async {
    try {
      String filePath = url.replaceAll(
          new RegExp(
              r'https://firebasestorage.googleapis.com/v0/b/twitter-fx81029.appspot.com/o/'),
          '');
      filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');
      filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
      StorageReference storageReference = FirebaseStorage.instance.ref();
      await storageReference.child(filePath).delete().catchError((val) {
        cprint('[Error]' + val);
      }).then((_) {
        cprint('[Success] Image deleted');
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteFile');
    }
  }

  updateTweet(Feed model) async {
    await firebaseDatabase.child('tweet').child(model.key).set(model.toJson());
  }

  addLikeToTweet(Feed tweet, String userId) {
    try {
      if (tweet.likes != null &&
          tweet.likes.length > 0 &&
          tweet.likes.any((id) => id == userId)) {
        tweet.likes.removeWhere((id) => id == userId);
        tweet.likeCount -= 1;
      } else {
        // If user like Tweet
        if (tweet.likes == null) {
          tweet.likes = [];
        }
        tweet.likes.add(userId);
        tweet.likeCount += 1;
      }

      firebaseDatabase
          .child('tweet')
          .child(tweet.key)
          .child('likeList')
          .set(tweet.likes);

      firebaseDatabase
          .child('notification')
          .child(tweet.userId)
          .child(tweet.key)
          .set({
        'type':
        tweet.likes.length == 0 ? null : NotificationType.Like.toString(),
        'updatedAt':
        tweet.likes.length == 0 ? null : DateTime.now().toUtc().toString(),
      });
    } catch (error) {
      cprint(error, errorIn: 'addLikeToTweet');
    }
  }

  /// Add [new comment tweet] to any tweet
  /// Comment is a Tweet itself
  addCommentToPost(Feed replyTweet) {
    try {
      isBusy = true;
      notifyListeners();
      if (tweetToReply != null) {
        Feed tweet = feeds.firstWhere((x) => x.key == tweetToReply.key);
        var json = replyTweet.toJson();
        firebaseDatabase.child('tweet').push().set(json).then((value) {
          tweet.replyTweetKeys.add(feeds.last.key);
          updateTweet(tweet);
        });
      }
    } catch (error) {
      cprint(error, errorIn: 'addCommentToPost');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when any tweet changes or update
  /// When any tweet changes it update it in UI
  /// No matter if Tweet is in home page or in detail page or in comment section.
  _onTweetChanged(Event event) {
    var model = Feed.fromJson(event.snapshot.value);
    model.key = event.snapshot.key;
    if (feeds.any((x) => x.key == model.key)) {
      var oldEntry = feeds.lastWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      feeds[feeds.indexOf(oldEntry)] = model;
    }

    if (tweetDetails != null && tweetDetails.length > 0) {
      if (tweetDetails.any((x) => x.key == model.key)) {
        var oldEntry = tweetDetails.lastWhere((entry) {
          return entry.key == event.snapshot.key;
        });
        tweetDetails[tweetDetails.indexOf(oldEntry)] = model;
      }
      if (tweetReplyMap != null && tweetReplyMap.length > 0) {
        if (true) {
          var list = tweetReplyMap[model.parentKey];
          //  var list = tweetReplyMap.values.firstWhere((x) => x.any((y) => y.key == model.key));
          if (list != null && list.length > 0) {
            var index =
            list.indexOf(list.firstWhere((x) => x.key == model.key));
            list[index] = model;
          } else {
            list = [];
            list.add(model);
          }
        }
      }
    }
    if (event.snapshot != null) {
      cprint('Tweet updated');
      isBusy = false;
      notifyListeners();
    }
  }

  // listener

  onTweetAdded(Event event) {
    Feed tweet = Feed.fromJson(event.snapshot.value);
    tweet.key = event.snapshot.key;

    /// Check if Tweet is a comment
    onCommentAdded(tweet);
    tweet.key = event.snapshot.key;
    if (feeds == null) {
      feeds = List<Feed>();
    }
    if ((feeds.length == 0 || feeds.any((x) => x.key != tweet.key)) &&
        isValidTweet(tweet)) {
      feeds.add(tweet);
      cprint('Tweet Added');
    }
    isBusy = false;
    notifyListeners();
  }

  onCommentAdded(Feed tweet) {
    if (tweet.childRetweetKey != null) {
      return;
    }
    if (tweetReplyMap != null && tweetReplyMap.length > 0) {
      if (tweetReplyMap[tweet.parentKey] != null) {
        tweetReplyMap[tweet.parentKey].add(tweet);
      } else {
        tweetReplyMap[tweet.parentKey] = [tweet];
      }
    }
    isBusy = false;
    notifyListeners();
  }

  onTweetRemoved(Event event) async {
    Feed tweet = Feed.fromJson(event.snapshot.value);
    tweet.key = event.snapshot.key;
    var tweetId = tweet.key;
    var parentKey = tweet.parentKey;

    ///  Delete tweet in [Home Page]
    try {
      Feed deletedTweet;
      if (feeds.any((x) => x.key == tweetId)) {
        /// Delete tweet if it is in home page tweet.
        deletedTweet = feeds.firstWhere((x) => x.key == tweetId);
        feeds.remove(deletedTweet);

        if (deletedTweet.parentKey != null &&
            feeds.isNotEmpty &&
            feeds.any((x) => x.key == deletedTweet.parentKey)) {
          // Decrease parent Tweet comment count and update
          var parentModel =
          feeds.firstWhere((x) => x.key == deletedTweet.parentKey);
          parentModel.replyTweetKeys.remove(deletedTweet.key);
          parentModel.commentCount = parentModel.replyTweetKeys.length;
          updateTweet(parentModel);
        }
        if (feeds.length == 0) {
          feeds = null;
        }
        cprint('Tweet deleted from home page tweet list');
      }

      /// [Delete tweet] if it is in nested tweet detail comment section page
      if (parentKey != null &&
          parentKey.isNotEmpty &&
          tweetReplyMap != null &&
          tweetReplyMap.length > 0 &&
          tweetReplyMap.keys.any((x) => x == parentKey)) {
        // (type == TweetType.Reply || tweetReplyMap.length > 1) &&
        deletedTweet =
            tweetReplyMap[parentKey].firstWhere((x) => x.key == tweetId);
        tweetReplyMap[parentKey].remove(deletedTweet);
        if (tweetReplyMap[parentKey].length == 0) {
          tweetReplyMap[parentKey] = null;
        }

        if (tweetDetails != null &&
            tweetDetails.isNotEmpty &&
            tweetDetails.any((x) => x.key == parentKey)) {
          var parentModel = tweetDetails.firstWhere((x) => x.key == parentKey);
          parentModel.replyTweetKeys.remove(deletedTweet.key);
          parentModel.commentCount = parentModel.replyTweetKeys.length;
          cprint('Parent tweet comment count updated on child tweet removal');
          updateTweet(parentModel);
        }

        cprint('Tweet deleted from nested tweet detail comment section');
      }

      /// Delete tweet image from firebase storage if exist.
      if (deletedTweet.imagePath != null && deletedTweet.imagePath.length > 0) {
        deleteFile(deletedTweet.imagePath, 'tweetImage');
      }

      /// If a retweet is deleted then retweetCount of original tweet should be decrease by 1.
      if (deletedTweet.childRetweetKey != null) {
        await fetchTweet(deletedTweet.childRetweetKey).then((retweetModel) {
          if (retweetModel == null) {
            return;
          }
          if (retweetModel.retweetCount > 0) {
            retweetModel.retweetCount -= 1;
          }
          updateTweet(retweetModel);
        });
      }

      /// Delete notification related to deleted Tweet.
      if (deletedTweet.likeCount > 0) {
        firebaseDatabase
            .child('notification')
            .child(tweet.userId)
            .child(tweet.key)
            .remove();
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onTweetRemoved');
    }
  }
}
