class TwitterNotification {
  String tweetKey;
  String updatedAt;
  String type;

  TwitterNotification({
    this.tweetKey,
  });

  TwitterNotification.fromJson(String tweetId, String updatedAt, String type) {
    tweetKey = tweetId;
    this.updatedAt = updatedAt;
    this.type = type;
  }

  Map<String, dynamic> toJson() => {
        "tweet_key": tweetKey,
        "updated_at": updatedAt,
        "type": type,
      };
}
