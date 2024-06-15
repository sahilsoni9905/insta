import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/features/home/repository/feed_repository.dart';
import 'package:task_project/features/home/screens/another_user_profile_screen.dart';
import 'package:task_project/features/home/widgets/video_playback.dart';
import 'package:task_project/models/follow_models.dart';
import 'package:task_project/models/user_models.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  static const routeName = 'user-profile-screen';

  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    user = await ref.read(FeedRepositoryProvider).getCurrentUserData();
    setState(() {});
  }

  Future<void> showFollowingFollowersDialog(
      BuildContext context, List<FollowModel> peoples, String txt) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print('${peoples.length} sahil sahil sahil sahil');
        return Dialog(
          child: Container(
            height: 400,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    txt,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: peoples.length,
                    itemBuilder: (context, index) {
                      print(peoples[index].profilePic);
                      return ListTile(
                        leading: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, AnotherUserProfileScreen.routeName,
                                arguments: peoples[index].uid);
                          },
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(
                              peoples[index].profilePic.toString(),
                            ),
                          ),
                        ),
                        title: Text(
                          peoples[index].name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return user == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('An error occurred: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text('No data available'),
                );
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;

              // Update the user model with the new data
              user = UserModel.fromMap(userData);

              return Scaffold(
                appBar: AppBar(
                  title: Text('Profile'),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user!.profilePic ??
                            'https://media.istockphoto.com/id/953079238/photo/smiling-man-with-hat-and-sunglasses.jpg?s=1024x1024&w=is&k=20&c=pQQYoyt5ytYtFRhbdVKRqqIfTDEJt6FJ_r-VJ5_fmkU='),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        user!.name ?? 'not found',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${user!.postUploaded.length} Reels Uploaded',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              List<FollowModel> temp = user!.followers;
                              showFollowingFollowersDialog(
                                  context, temp, 'Followers');
                            },
                            child: Column(
                              children: [
                                Text(
                                  user!.followers.length.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Followers',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: () {
                              List<FollowModel> temp = user!.following;

                              showFollowingFollowersDialog(
                                  context, temp, 'Following');
                            },
                            child: Column(
                              children: [
                                Text(
                                  user!.following.length.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Following',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GridView.builder(
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: user!.postUploaded.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    videoUrl:
                                        user!.postUploaded[index].postLink,
                                  ),
                                ),
                              );
                            },
                            child: VideoPlayerCard(
                              videoUrl: user!.postUploaded[index].postLink,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl);

    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: _controller.value.aspectRatio,
      autoPlay: true,
      looping: true,
    );
    setState(() {}); // Ensure the widget tree is updated
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Player"),
      ),
      body: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(
                controller: _chewieController!,
              )
            : CircularProgressIndicator(
                color: Colors.black,
              ),
      ),
    );
  }
}
