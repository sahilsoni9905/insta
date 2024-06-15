import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/common/common_firebase_storage.dart';
import 'package:task_project/common/utils.dart';
import 'package:task_project/features/auth/screens/optScreen.dart';
import 'package:task_project/features/auth/screens/user_info_screen.dart';
import 'package:task_project/features/home/screens/home_page.dart';
import 'package:task_project/models/post_models.dart';
import 'package:task_project/models/user_models.dart';
import 'package:uuid/uuid.dart';

final AuthRepositoryProvider = Provider(
  (ref) => AuthRepository(ref: ref),
);
final userDataAuthProvider = FutureProvider((ref) {
  return ref.watch(AuthRepositoryProvider).getCurrentUserData();
});

class AuthRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ProviderRef ref;
  UserModel? userDetails;
  UserModel? user;
  AuthRepository({required this.ref});

  void signInwithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          Navigator.pushNamed(context, Optscreen.routeName,
              arguments: verificationId);
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
          context, UserInfoScreen.routeName, (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required BuildContext context,
  }) async {
    String res = 'some error occured';
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      if (profilePic != null) {
        photoUrl = await ref
            .read(CommonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePic/$uid',
              profilePic,
            );
      }

      var user = UserModel(
        name: name,
        uid: uid,
        profilePic: photoUrl,
        postCommented: [],
        postLiked: [],
        phoneNumber: auth.currentUser!.phoneNumber!,
        postUploaded: [],
        followers: [],
        following: [],
      );
      userDetails = user;
      await firestore.collection('users').doc(uid).set(user.toMap());

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void saveUserPostToFirebase({
    required String description,
    required String category,
    required File videoFile,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;

      var uuid = const Uuid();
      String uniqueFileId = uuid.v4(); // Generates a unique ID

      var link = await ref
          .read(CommonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'videoFile/$uid/$uniqueFileId',
            videoFile,
          );
      userDetails = await getCurrentUserData();
      print('post saved in firebase storage');
      String reelUid = Uuid().v4();
      var postModel = PostModel(
          ownerProfilePic: userDetails!.profilePic,
          ownerUserName: userDetails!.name,
          uid: reelUid,
          ownerUid: userDetails!.uid,
          postLink: link,
          numberOfLikes: 0,
          comments: [],
          peopleWhoLiked: [],
          description: description,
          uploadedTime: DateTime.now());
      var userDoc = await firestore.collection('users').doc(uid);
      userDoc.update({
        'postUploaded': FieldValue.arrayUnion([postModel.toMap()]),
      });

      await firestore
          .collection('allReels')
          .doc(reelUid)
          .set(postModel.toMap());
      showSnackBar(context: context, content: 'Post Uploaded Successfully');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

 

  Stream<UserModel> userData(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();

    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }
}
