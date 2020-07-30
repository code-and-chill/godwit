import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/states/chat.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/utilities/widget.dart';
import 'package:twitter/widgets/button/ripple.dart';

class Avatar extends StatelessWidget {
  final bool isMyProfile;
  final User profileUser;

  const Avatar({this.isMyProfile, this.profileUser});

  isFollower(AuthState authState) {
    if (authState.profileUser.followers != null &&
        authState.profileUser.followers.isNotEmpty) {
      return (authState.profileUser.followers
          .any((x) => x == authState.getUser.userId));
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Container(
      alignment: Alignment.bottomLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 5),
                shape: BoxShape.circle),
            child: RippleButton(
              child: customImage(
                context,
                profileUser.profilePict,
                height: 80,
              ),
              borderRadius: BorderRadius.circular(50),
              onPressed: () {
                Navigator.pushNamed(context, "/ProfileImageView");
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 90, right: 30),
            child: Row(
              children: <Widget>[
                isMyProfile
                    ? Container(height: 40)
                    : RippleButton(
                        splashColor: TwitterColor.dodgetBlue_50.withAlpha(100),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        onPressed: () {
                          if (!isMyProfile) {
                            final chatState =
                                Provider.of<ChatState>(context, listen: false);
                            chatState.setChatUser = profileUser;
                            Navigator.pushNamed(context, '/ChatScreenPage');
                          }
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          padding: EdgeInsets.only(
                              bottom: 5, top: 0, right: 0, left: 0),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: isMyProfile
                                      ? Colors.black87.withAlpha(180)
                                      : Colors.blue,
                                  width: 1),
                              shape: BoxShape.circle),
                          child: Icon(
                            IconData(AppIcon.messageEmpty,
                                fontFamily: 'TwitterIcon'),
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                SizedBox(width: 10),
                RippleButton(
                  splashColor: TwitterColor.dodgetBlue_50.withAlpha(100),
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                  onPressed: () {
                    if (isMyProfile) {
                      Navigator.pushNamed(context, '/EditProfile');
                    } else {
                      authState.followUser(
                        removeFollower: isFollower(authState),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isFollower(authState)
                          ? TwitterColor.dodgetBlue
                          : TwitterColor.white,
                      border: Border.all(
                          color: isMyProfile
                              ? Colors.black87.withAlpha(180)
                              : Colors.blue,
                          width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    /// If [isMyProfile] is true then Edit profile button will display
                    // Otherwise Follow/Following button will be display
                    child: Text(
                      isMyProfile
                          ? 'Edit Profile'
                          : isFollower(authState) ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: isMyProfile
                            ? Colors.black87.withAlpha(180)
                            : isFollower(authState)
                                ? TwitterColor.white
                                : Colors.blue,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
