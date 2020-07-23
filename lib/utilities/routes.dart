import 'package:flutter/material.dart';
import 'package:twitter/page/Auth/selectAuthMethod.dart';
import 'package:twitter/page/Auth/verifyEmail.dart';
import 'package:twitter/page/auth/signin.dart';
import 'package:twitter/page/auth/signup.dart';
import 'package:twitter/page/common/splash.dart';
import 'package:twitter/page/feed/composeTweet.dart';
import 'package:twitter/state/composeTweetState.dart';
import 'package:twitter/page/message/conversationInformation.dart';
import 'package:twitter/page/message/newMessagePage.dart';
import 'package:twitter/page/profile/follow/followerListPage.dart';
import 'package:twitter/page/profile/follow/followingListPage.dart';
import 'package:twitter/page/profile/profileImageView.dart';
import 'package:twitter/page/search/SearchPage.dart';
import 'package:twitter/page/settings/accountSettings/about/aboutTwitter.dart';
import 'package:twitter/page/settings/accountSettings/accessibility/accessibility.dart';
import 'package:twitter/page/settings/accountSettings/accountSettingsPage.dart';
import 'package:twitter/page/settings/accountSettings/contentPrefrences/contentPreference.dart';
import 'package:twitter/page/settings/accountSettings/contentPrefrences/trends/trendsPage.dart';
import 'package:twitter/page/settings/accountSettings/dataUsage/dataUsagePage.dart';
import 'package:twitter/page/settings/accountSettings/displaySettings/displayAndSoundPage.dart';
import 'package:twitter/page/settings/accountSettings/notifications/notificationPage.dart';
import 'package:twitter/page/settings/accountSettings/privacyAndSafety/directMessage/directMessage.dart';
import 'package:twitter/page/settings/accountSettings/privacyAndSafety/privacyAndSafetyPage.dart';
import 'package:twitter/page/settings/accountSettings/proxy/proxyPage.dart';
import 'package:twitter/page/settings/settingsAndPrivacyPage.dart';
import 'package:provider/provider.dart';
import '../page/feed/imageViewPage.dart';
import '../page/Auth/forgetPasswordPage.dart';
import '../page/feed/feedPostDetail.dart';
import '../page/profile/EditProfilePage.dart';
import '../page/message/chatScreenPage.dart';
import '../page/profile/profilePage.dart';
import '../widgets/customWidgets.dart';

class Routes {
  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => SplashPage(),
    };
  }

  static void sendNavigationEventToFirebase(String path) {
    if (path != null && path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "ComposeTweetPage":
        bool isRetweet = false;
        bool isTweet = false;
        if (pathElements.length == 3 && pathElements[2].contains('retweet')) {
          isRetweet = true;
        } else if (pathElements.length == 3 && pathElements[2].contains('tweet')) {
          isTweet = true;
        }
        return CustomRoute<bool>(
            builder: (BuildContext context) => ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child: ComposeTweetPage(isRetweet: isRetweet, isTweet: isTweet),
                ));
      case "FeedPostDetail":
        var postId = pathElements[2];
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => FeedPostDetail(
                  postId: postId,
                ),
            settings: RouteSettings(name: 'FeedPostDetail'));
      case "ProfilePage":
        String profileId;
        if (pathElements.length > 2) {
          profileId = pathElements[2];
        }
        return CustomRoute<bool>(
            builder: (BuildContext context) => ProfilePage(
                  profileId: profileId,
                ));
      case "CreateFeedPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child: ComposeTweetPage(isRetweet: false, isTweet: true),
                ));
      case "WelcomePage":
        return CustomRoute<bool>(builder: (BuildContext context) => WelcomePage());
      case "SignIn":
        return CustomRoute<bool>(builder: (BuildContext context) => SignIn());
      case "SignUp":
        return CustomRoute<bool>(builder: (BuildContext context) => SignUp());
      case "ForgetPasswordPage":
        return CustomRoute<bool>(builder: (BuildContext context) => ForgetPasswordPage());
      case "SearchPage":
        return CustomRoute<bool>(builder: (BuildContext context) => SearchPage());
      case "ImageViewPge":
        return CustomRoute<bool>(builder: (BuildContext context) => ImageViewPge());
      case "EditProfile":
        return CustomRoute<bool>(builder: (BuildContext context) => EditProfilePage());
      case "ProfileImageView":
        return SlideLeftRoute<bool>(builder: (BuildContext context) => ProfileImageView());
      case "ChatScreenPage":
        return CustomRoute<bool>(builder: (BuildContext context) => ChatScreenPage());
      case "NewMessagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => NewMessagePage(),
        );
      case "SettingsAndPrivacyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => SettingsAndPrivacyPage(),
        );
      case "AccountSettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AccountSettingsPage(),
        );
      case "AccountSettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AccountSettingsPage(),
        );
      case "PrivacyAndSaftyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => PrivacyAndSaftyPage(),
        );
      case "NotificationPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => NotificationPage(),
        );
      case "ContentPrefrencePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ContentPrefrencePage(),
        );
      case "DisplayAndSoundPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DisplayAndSoundPage(),
        );
      case "DirectMessagesPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DirectMessagesPage(),
        );
      case "TrendsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => TrendsPage(),
        );
      case "DataUsagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DataUsagePage(),
        );
      case "AccessibilityPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AccessibilityPage(),
        );
      case "ProxyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ProxyPage(),
        );
      case "AboutPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AboutPage(),
        );
      case "ConversationInformation":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ConversationInformation(),
        );
      case "FollowingListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowingListPage(),
        );
      case "FollowerListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowerListPage(),
        );
      case "VerifyEmailPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => VerifyEmailPage(),
        );
      default:
        return onUnknownRoute(RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: customTitleText(settings.name.split('/')[1]),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({WidgetBuilder builder, RouteSettings settings}) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    Routes.sendNavigationEventToFirebase(settings.name);
    if (settings.name == "SplashPage") {
      return child;
    }
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
      child: child,
    );
  }
}

class SlideLeftRoute<T> extends MaterialPageRoute<T> {
  SlideLeftRoute({WidgetBuilder builder, RouteSettings settings}) : super(builder: builder, settings: settings);
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    Routes.sendNavigationEventToFirebase(settings.name);
    if (settings.name == "SplashPage") {
      return child;
    }
    return SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  }
}
