import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/models/post_models.dart';
import 'package:task_project/models/user_models.dart';

final FeedRepositoryProvider = Provider((ref) => FeedRepository(ref: ref));

final userDataAuthProvider = FutureProvider((ref) {
  return ref.watch(FeedRepositoryProvider).getCurrentUserData();
});

class FeedRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ProviderRef ref;

  FeedRepository({required this.ref});

  Future<void> likeUpdate(String postUid, bool alreadyLiked) async {
    UserModel? user = await getCurrentUserData();
    if (user != null) {
      var postDoc = firestore.collection('allReels').doc(postUid);

      if (alreadyLiked) {
        await postDoc.update({
          'peopleWhoLiked': FieldValue.arrayRemove([user.uid]),
          'numberOfLikes': FieldValue.increment(-1),
        });
      } else {
        await postDoc.update({
          'peopleWhoLiked': FieldValue.arrayUnion([user.uid]),
          'numberOfLikes': FieldValue.increment(1),
        });
      }
    } else {
      print('Error: No user found.');
    }
  }

  Future<bool> isLiked(String postUid) async {
    UserModel? user = await getCurrentUserData();
    if (user != null) {
      var postDoc = await firestore.collection('allReels').doc(postUid).get();
      if (postDoc.exists) {
        var post = PostModel.fromMap(postDoc.data()!);
        return post.peopleWhoLiked.contains(user.uid);
      } else {
        print('Error: Post not found.');
      }
    } else {
      print('Error: No user found.');
    }
    return false;
  }

  Future<UserModel?> getCurrentUserData() async {
    var currentUser = auth.currentUser;
    if (currentUser != null) {
      var userData =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (userData.exists) {
        return UserModel.fromMap(userData.data()!);
      } else {
        print('Error: User data not found.');
      }
    } else {
      print('Error: No current user.');
    }
    return null;
  }

  Future<void> addComment(String postUid, String comment) async {
    UserModel? user = await getCurrentUserData();
    if (user != null) {
      var postDoc = firestore.collection('allReels').doc(postUid);
      await postDoc.update({
        'comments': FieldValue.arrayUnion([comment]),
      });
    }
  }
}
