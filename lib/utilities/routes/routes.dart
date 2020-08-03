import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/pages/Auth/verify_email.dart';
import 'package:twitter/pages/Auth/welcome.dart';
import 'package:twitter/pages/auth/signin.dart';
import 'package:twitter/pages/auth/signup.dart';
import 'package:twitter/pages/feed/compose_tweet.dart';
import 'package:twitter/pages/message/conversation.dart';
import 'package:twitter/pages/message/new_message.dart';
import 'package:twitter/pages/profile/follower_list.dart';
import 'package:twitter/pages/profile/profile_image.dart';
import 'package:twitter/pages/search/search.dart';
import 'package:twitter/pages/settings/account/about.dart';
import 'package:twitter/pages/settings/account/accessibility/accessibility.dart';
import 'package:twitter/pages/settings/account/account.dart';
import 'package:twitter/pages/settings/account/content_preferences/content_preference.dart';
import 'package:twitter/pages/settings/account/content_preferences/trends.dart';
import 'package:twitter/pages/settings/account/data_usage.dart';
import 'package:twitter/pages/settings/account/notification.dart';
import 'package:twitter/pages/settings/account/privacy_and_safety/direct_message.dart';
import 'package:twitter/pages/settings/account/privacy_and_safety/safety.dart';
import 'package:twitter/pages/settings/account/sound_page.dart';
import 'package:twitter/pages/settings/privacy.dart';
import 'package:twitter/pages/settings/proxy.dart';
import 'package:twitter/pages/splash.dart';
import 'package:twitter/states/tweet.dart';
import 'package:twitter/utilities/enum.dart';
import 'package:twitter/utilities/page.dart' as page;
import 'package:twitter/utilities/routes/slide_left_route.dart';

import '../../pages/auth/forgot_password.dart';
import '../../pages/feed/feed_post_detail.dart';
import '../../pages/feed/image_view.dart';
import '../../pages/message/chat_screen.dart';
import '../../pages/profile/edit_profile.dart';
import '../../pages/profile/profile.dart';
import '../widget.dart';
import 'custom_route.dart';

class Routes {
  static dynamic route() {
    return {
      page.Splash: (BuildContext context) => SplashPage(),
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
      case page.ComposeTweet:
        bool isRetweet =
            pathElements.length == 3 && pathElements[2].contains('retweet');
        bool isTweet =
            pathElements.length == 3 && pathElements[2].contains('tweet');
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<TweetState>(
                    create: (_) => TweetState(),
                    child: ComposeTweetPage(
                        isRetweet: isRetweet, isTweet: isTweet)));
      case page.FeedPostDetail:
        var postId = pathElements[2];
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => FeedPostDetail(postId: postId),
            settings: RouteSettings(name: page.FeedPostDetail));
      case page.Profile:
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ProfilePage(profileId: pathElements[2]));
      case page.CreateFeed:
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<TweetState>(
                    create: (_) => TweetState(),
                    child: ComposeTweetPage(isRetweet: false, isTweet: true)));
      case page.Welcome:
        return CustomRoute<bool>(
            builder: (BuildContext context) => WelcomePage());
      case page.SignIn:
        return CustomRoute<bool>(builder: (BuildContext context) => SignIn());
      case page.SignUp:
        return CustomRoute<bool>(builder: (BuildContext context) => SignUp());
      case page.ForgotPassword:
        return CustomRoute<bool>(
            builder: (BuildContext context) => ForgetPasswordPage());
      case page.Search:
        return CustomRoute<bool>(
            builder: (BuildContext context) => SearchPage());
      case page.ImageView:
        return CustomRoute<bool>(
            builder: (BuildContext context) => ImageViewPge());
      case page.EditProfile:
        return CustomRoute<bool>(
            builder: (BuildContext context) => EditProfilePage());
      case page.ProfileImageView:
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => ProfileImageView());
      case page.ChatScreen:
        return CustomRoute<bool>(
            builder: (BuildContext context) => ChatScreenPage());
      case page.NewMessage:
        return CustomRoute<bool>(
            builder: (BuildContext context) => NewMessagePage());
      case page.SettingsAndPrivacy:
        return CustomRoute<bool>(
            builder: (BuildContext context) => SettingsAndPrivacyPage());
      case page.Account:
        return CustomRoute<bool>(
            builder: (BuildContext context) => AccountSettingsPage());
      case page.Account:
        return CustomRoute<bool>(
            builder: (BuildContext context) => AccountSettingsPage());
      case page.PrivacyAndSafety:
        return CustomRoute<bool>(
            builder: (BuildContext context) => PrivacyAndSaftyPage());
      case page.Notification:
        return CustomRoute<bool>(
            builder: (BuildContext context) => NotificationPage());
      case page.ContentPreference:
        return CustomRoute<bool>(
            builder: (BuildContext context) => ContentPreferencePage());
      case page.DisplayAndSound:
        return CustomRoute<bool>(
            builder: (BuildContext context) => DisplayAndSoundPage());
      case page.DirectMessages:
        return CustomRoute<bool>(
            builder: (BuildContext context) => DirectMessagesPage());
      case page.Trends:
        return CustomRoute<bool>(
            builder: (BuildContext context) => TrendsPage());
      case page.DataUsage:
        return CustomRoute<bool>(
            builder: (BuildContext context) => DataUsagePage());
      case page.Accessibility:
        return CustomRoute<bool>(
            builder: (BuildContext context) => AccessibilityPage());
      case page.Proxy:
        return CustomRoute<bool>(
            builder: (BuildContext context) => ProxyPage());
      case page.About:
        return CustomRoute<bool>(
            builder: (BuildContext context) => AboutPage());
      case page.ConversationInformation:
        return CustomRoute<bool>(
            builder: (BuildContext context) => ConversationInformation());
      case page.FollowingList:
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                FollowListPage(
                  FollowType.Following,
                  pageTitle: "following",
                ));
      case page.FollowerList:
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                FollowListPage(
                  FollowType.Followers,
                  pageTitle: "followers",
                ));
      case page.VerifyEmail:
        return CustomRoute<bool>(
            builder: (BuildContext context) => VerifyEmailPage());
      default:
        return onUnknownRoute(RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: customText(settings.name.split('/')[1]),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name.split('/')[1]} Coming soon..'),
        ),
      ),
    );
  }
}
