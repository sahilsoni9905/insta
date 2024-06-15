import 'package:task_project/models/follow_models.dart';
import 'package:task_project/models/post_models.dart';

class UserModel {
  final String name;
  final String uid;
  final String profilePic;
  final List<String> postLiked;
  final List<String> postCommented;
  final String phoneNumber;
  final List<PostModel> postUploaded;
  final List<FollowModel> followers;
  final List<FollowModel> following;

  UserModel({
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.postLiked,
    required this.postCommented,
    required this.phoneNumber,
    required this.postUploaded,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
      'postLiked': postLiked,
      'postCommented': postCommented,
      'phoneNumber': phoneNumber,
      'postUploaded': postUploaded.map((post) => post.toMap()).toList(),
      'followers': followers.map((user) => user.toMap()).toList(),
      'following': following.map((user) => user.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      postLiked: List<String>.from(map['postLiked'] ?? []),
      postCommented: List<String>.from(map['postCommented'] ?? []),
      phoneNumber: map['phoneNumber'] ?? '',
      postUploaded: List<PostModel>.from(
          map['postUploaded']?.map((post) => PostModel.fromMap(post)) ?? []),
      followers: List<FollowModel>.from(
          map['followers']?.map((user) => FollowModel.fromMap(user)) ?? []),
      following: List<FollowModel>.from(
          map['following']?.map((user) => FollowModel.fromMap(user)) ?? []),
    );
  }
}
