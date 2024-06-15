class CommentModel {
  final String userUid;
  final String name;
  final String profilePic;
  final String comment;

  CommentModel({
    required this.userUid,
    required this.name,
    required this.profilePic,
    required this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'name': name,
      'profilePic': profilePic,
      'comment': comment,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      userUid: map['userUid'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      comment: map['comment'] ?? '',
    );
  }
}
