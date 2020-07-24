class User {
  String key;
  String email;
  String userId;
  String displayName;
  String userName;
  String webSite;
  String profilePict;
  String contact;
  String bio;
  String location;
  String dateOfBirth;
  String createdAt;
  bool isVerified;
  int followers;
  int following;
  String fcmToken;
  List<String> followersList;
  List<String> followingList;

  User({
    this.email,
    this.userId,
    this.displayName,
    this.profilePict,
    this.key,
    this.contact,
    this.bio,
    this.dateOfBirth,
    this.location,
    this.createdAt,
    this.userName,
    this.followers,
    this.following,
    this.webSite,
    this.isVerified,
    this.fcmToken,
    this.followersList,
  });

  User.fromJson(Map<dynamic, dynamic> map) {
    if (map == null) {
      return;
    }
    if (followersList == null) {
      followersList = [];
    }
    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    profilePict = map['profilePic'];
    key = map['key'];
    dateOfBirth = map['dateOfBirth'];
    bio = map['bio'];
    location = map['location'];
    contact = map['contact'];
    createdAt = map['createdAt'];
    followers = map['followers'];
    following = map['following'];
    userName = map['userName'];
    webSite = map['webSite'];
    fcmToken = map['fcmToken'];
    isVerified = map['isVerified'] ?? false;
    if (map['followerList'] != null) {
      followersList = List<String>();
      map['followerList'].forEach((value) {
        followersList.add(value);
      });
    }
    followers = followersList != null ? followersList.length : null;
    if (map['followingList'] != null) {
      followingList = List<String>();
      map['followingList'].forEach((value) {
        followingList.add(value);
      });
    }
    following = followingList != null ? followingList.length : null;
  }

  toJson() {
    return {
      'key': key,
      "userId": userId,
      "email": email,
      'displayName': displayName,
      'userId': userId,
      'profilePic': profilePict,
      'contact': contact,
      'dateOfBirth': dateOfBirth,
      'bio': bio,
      'location': location,
      'createdAt': createdAt,
      'followers': followersList != null ? followersList.length : null,
      'following': followingList != null ? followingList.length : null,
      'userName': userName,
      'webSite': webSite,
      'isVerified': isVerified ?? false,
      'fcmToken': fcmToken,
      'followerList': followersList,
      'followingList': followingList
    };
  }

  User copyWith({
    String email,
    String userId,
    String displayName,
    String profilePic,
    String key,
    String contact,
    bio,
    String dob,
    String location,
    String createdAt,
    String userName,
    int followers,
    int following,
    String webSite,
    bool isVerified,
    String fcmToken,
    List<String> followingList,
  }) {
    return User(
      email: email ?? this.email,
      bio: bio ?? this.bio,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dob ?? this.dateOfBirth,
      followers: followersList != null ? followersList.length : null,
      following: following ?? this.following,
      isVerified: isVerified ?? this.isVerified,
      key: key ?? this.key,
      location: location ?? this.location,
      profilePict: profilePic ?? this.profilePict,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      webSite: webSite ?? this.webSite,
      fcmToken: fcmToken ?? this.fcmToken,
      followersList: followersList ?? this.followersList,
    );
  }

  String getFollower() {
    return '${this.followers ?? 0}';
  }

  String getFollowing() {
    return '${this.following ?? 0}';
  }
}
