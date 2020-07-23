import 'package:twitter/model/user.dart';

class Feed {
  String key;
  String parentKey;
  String childRetweetKey;
  String description;
  String userId;
  int likeCount;
  List<String> likes;
  int commentCount;
  int retweetCount;
  String createdAt;
  String imagePath;
  List<String> tags;
  List<String> replyTweetKeys;
  User user;
  Feed(
      {this.key,
      this.description,
      this.userId,
      this.likeCount,
      this.commentCount,
      this.retweetCount,
      this.createdAt,
      this.imagePath,
      this.likes,
      this.tags,
      this.user,
      this.replyTweetKeys,
      this.parentKey,
      this.childRetweetKey});
  toJson() {
    return {
      "userId": userId,
      "description": description,
      "likeCount": likeCount,
      "commentCount": commentCount ?? 0,
      "retweetCount": retweetCount ?? 0,
      "createdAt": createdAt,
      "imagePath": imagePath,
      "likeList": likes,
      "tags": tags,
      "replyTweetKeyList": replyTweetKeys,
      "user": user == null ? null : user.toJson(),
      "parentKey": parentKey,
      "childRetwetkey": childRetweetKey
    };
  }

  Feed.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    description = map['description'];
    userId = map['userId'];
    //  name = map['name'];
    //  profilePic = map['profilePic'];
    likeCount = map['likeCount'] ?? 0;
    commentCount = map['commentCount'];
    retweetCount = map["retweetCount"] ?? 0;
    imagePath = map['imagePath'];
    createdAt = map['createdAt'];
    imagePath = map['imagePath'];
    //  username = map['username'];
    user = User.fromJson(map['user']);
    parentKey = map['parentKey'];
    childRetweetKey = map['childRetwetkey'];
    if (map['tags'] != null) {
      tags = List<String>();
      map['tags'].forEach((value) {
        tags.add(value);
      });
    }
    if (map["likeList"] != null) {
      likes = List<String>();

      final list = map['likeList'];

      /// In new tweet db schema likeList is stored as a List<String>()
      ///
      if (list is List) {
        map['likeList'].forEach((value) {
          if (value is String) {
            likes.add(value);
          }
        });
        likeCount = likes.length ?? 0;
      }

      /// In old database tweet db schema likeList is saved in the form of map
      /// like list map is removed from latest code but to support old schema below code is required
      /// Once all user migrated to new version like list map support will be removed
      else if (list is Map) {
        list.forEach((key, value) {
          likes.add(value["userId"]);
        });
        likeCount = list.length;
      }
    } else {
      likes = [];
      likeCount = 0;
    }
    if (map['replyTweetKeyList'] != null) {
      map['replyTweetKeyList'].forEach((value) {
        replyTweetKeys = List<String>();
        map['replyTweetKeyList'].forEach((value) {
          replyTweetKeys.add(value);
        });
      });
      commentCount = replyTweetKeys.length;
    } else {
      replyTweetKeys = [];
      commentCount = 0;
    }
  }

  bool get isValidTweet {
    bool isValid = false;
    if (description != null && description.isNotEmpty && this.user != null && this.user.userName != null && this.user.userName.isNotEmpty) {
      isValid = true;
    } else {
      print("Invalid Tweet found. Id:- $key");
    }
    return isValid;
  }
}
