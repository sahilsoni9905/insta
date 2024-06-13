import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_project/features/auth/screens/optScreen.dart';
import 'package:task_project/features/auth/screens/user_info_screen.dart';
import 'package:task_project/features/home/screens/add_post_screen.dart';
import 'package:task_project/features/home/screens/user_profile_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Optscreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => Optscreen(
                verificationId: verificationId,
              ));
    case UserInfoScreen.routeName:
      return MaterialPageRoute(builder: (context) => UserInfoScreen());
    case AddPostScreen.routeName:
      return MaterialPageRoute(builder: (context) => AddPostScreen());
      case UserProfileScreen.routeName:
      return MaterialPageRoute(builder: (context) => UserProfileScreen());
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Something gone wrong'),
          ),
        ),
      );
  }
}
