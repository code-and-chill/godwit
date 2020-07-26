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
      this.parentKey,
      this.childRetweetKey,
      this.description,
      this.userId,
      this.likeCount,
      this.likes,
      this.commentCount,
      this.retweetCount,
      this.createdAt,
      this.imagePath,
      this.tags,
      this.replyTweetKeys,
      this.user});

  toJson() {
    return {
      "key": key,
      "parent_key": parentKey,
      "child_retweet_key": childRetweetKey,
      "description": description,
      "user_id": userId,
      "like_count": likeCount,
      "likes": likes,
      "comment_count": commentCount ?? 0,
      "retweet_count": retweetCount ?? 0,
      "created_at": createdAt,
      "image_path": imagePath,
      "tags": tags,
      "reply_tweet_keys": replyTweetKeys,
      "user": user == null ? null : user.toJson(),
    };
  }

  Feed.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    parentKey = map['parent_key'];
    childRetweetKey = map['child_retweet_key'];
    description = map['description'];
    likeCount = map['like_count'] ?? 0;
    likes = map['likes'] ?? [];
    commentCount = map['comment_count'];
    retweetCount = map["retweet_count"] ?? 0;
    imagePath = map['image_path'];
    createdAt = map['created_at'];
    imagePath = map['imagePath'];
    tags = map['tags'] ?? [];
    user = User.fromJson(map['user']);
    replyTweetKeys = map['reply_tweet_keys'] ?? [];
  }
}
