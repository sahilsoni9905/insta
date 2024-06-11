import 'package:task_project/models/post_models.dart';

class UserModel {
  final String name;
  final String uid;
  final String profilePic;
  final List postLiked;
  final List postCommented;
  final String phoneNumber;
  final List<PostModel> postUploaded;

  UserModel({
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.postLiked,
    required this.postCommented,
    required this.phoneNumber,
    required this.postUploaded,
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
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      postLiked: map['postLiked'] ?? [],
      postCommented: map['postCommented'] ?? [],
      phoneNumber: map['phoneNumber'] ?? '',
      postUploaded: List<PostModel>.from(
          map['postUploaded']?.map((post) => PostModel.fromMap(post)) ?? []),
    );
  }
}
