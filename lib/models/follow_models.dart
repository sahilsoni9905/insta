class FollowModel {
  final String uid;
  final String name;
  final String profilePic;

  FollowModel({
    required this.uid,
    required this.name,
    required this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profilePic': profilePic,
    };
  }

  factory FollowModel.fromMap(Map<String, dynamic> map) {
    return FollowModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }
}
