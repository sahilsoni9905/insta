import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/features/auth/repository/auth_repository.dart';

class Optscreen extends ConsumerWidget {
  final String verificationId;
  const Optscreen({super.key , required this.verificationId});
  static const String routeName = 'otp-screen';
   
  @override
  Widget build(BuildContext context  , WidgetRef ref) {
     void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
    ref
        .read(AuthRepositoryProvider)
        .verifyOTP(context: context , userOTP: userOTP , verificationId: verificationId);
  }
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your number'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text('We have sent an SMS with a code '),
            SizedBox(
              width: size.width * 0.5,
              child: TextField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                    hintText: '- - - - - -',
                    hintStyle: TextStyle(fontSize: 30)),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if (val.length == 6) {
                  verifyOTP(ref, context, val.trim());
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
