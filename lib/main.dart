import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/features/auth/repository/auth_repository.dart';

import 'package:task_project/features/auth/screens/phoneNumberScreen.dart';
import 'package:task_project/features/home/screens/home_page.dart';
import 'package:task_project/firebase_options.dart';
import 'package:task_project/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
      child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(
            data: (user) {
              if (user == null) {
                return const LoginScreen();
              }
              return const HomePage();
            },
            error: (err, trace) {
              return Center(
                child: Text('something went wrong'),
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(),
            ),
          ), // Add const constructor
    );
  }
}
