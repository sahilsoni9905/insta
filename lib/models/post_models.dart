class PostModel {
  final String uid;
  final String ownerUid;
  final String? ownerProfilePic;
  final String ownerUserName;
  final String postLink;
  final int numberOfLikes;
  final List<String> peopleWhoLiked;
  final List<String> comments;
  final String description;
  final DateTime uploadedTime;
  final String? uploadedCity;

  PostModel({
    required this.uid,
    required this.ownerUid,
    this.ownerProfilePic,
    required this.ownerUserName,
    required this.postLink,
    required this.numberOfLikes,
    required this.peopleWhoLiked,
    required this.comments,
    required this.description,
    required this.uploadedTime,
    this.uploadedCity, // Added uploadedCity field
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'ownerUid': ownerUid,
      'ownerProfilePic': ownerProfilePic,
      'ownerUserName': ownerUserName,
      'postLink': postLink,
      'numberOfLikes': numberOfLikes,
      'peopleWhoLiked': peopleWhoLiked,
      'comments': comments,
      'description': description,
      'uploadedTime': uploadedTime.toIso8601String(),
      'uploadedCity': uploadedCity, // Added uploadedCity to the map
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      uid: map['uid'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      ownerProfilePic: map['ownerProfilePic'],
      ownerUserName: map['ownerUserName'] ?? '',
      postLink: map['postLink'] ?? '',
      numberOfLikes: map['numberOfLikes'] ?? 0,
      peopleWhoLiked: List<String>.from(map['peopleWhoLiked'] ?? []),
      comments: List<String>.from(map['comments'] ?? []),
      description: map['description'] ?? '',
      uploadedTime: DateTime.parse(
          map['uploadedTime'] ?? DateTime.now().toIso8601String()),
      uploadedCity: map['uploadedCity'], // Assign uploadedCity from the map
    );
  }
}
