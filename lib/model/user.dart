class User {
  String key;
  String email;
  String userId;
  String displayName;
  String userName;
  String website;
  String profilePict;
  String contact;
  String bio;
  String location;
  String dateOfBirth;
  String createdAt;
  bool isVerified;
  String fcmToken;
  List<String> followers;
  List<String> following;

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
    this.website,
    this.isVerified,
    this.fcmToken,
    this.followers,
    this.following,
  });

  User.fromJson(Map<dynamic, dynamic> map) {
    if (map == null) {
      return;
    }
    if (followers == null) {
      followers = [];
    }
    email = map['email'];
    userId = map['user_id'];
    displayName = map['display_name'];
    profilePict = map['profile_pict'];
    key = map['key'];
    dateOfBirth = map['date_of_birth'];
    bio = map['bio'];
    location = map['location'];
    contact = map['contact'];
    createdAt = map['created_at'];
    userName = map['user_name'];
    website = map['website'];
    fcmToken = map['fcm_token'];
    isVerified = map['is_verified'] ?? false;
    followers = map['followers'] ?? [];
    following = map['following'] ?? [];
  }

  toJson() {
    return {
      'key': key,
      "user_id": userId,
      "email": email,
      'display_name': displayName,
      'userId': userId,
      'profile_pict': profilePict,
      'contact': contact,
      'date_of_birth': dateOfBirth,
      'bio': bio,
      'location': location,
      'created_at': createdAt,
      'userName': userName,
      'website': website,
      'is_verified': isVerified ?? false,
      'fcm_token': fcmToken,
      'followers': followers,
      'followings': following
    };
  }

  User copyWith({
    String email,
    String userId,
    String displayName,
    String profilePict,
    String key,
    String contact,
    bio,
    String dateOfBirth,
    String location,
    String createdAt,
    String userName,
    String website,
    bool isVerified,
    String fcmToken,
    List<String> followers,
    List<String> following,
  }) {
    return User(
      email: email ?? this.email,
      bio: bio ?? this.bio,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isVerified: isVerified ?? this.isVerified,
      key: key ?? this.key,
      location: location ?? this.location,
      profilePict: profilePict ?? this.profilePict,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      website: website ?? this.website,
      fcmToken: fcmToken ?? this.fcmToken,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
