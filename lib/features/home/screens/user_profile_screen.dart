import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/features/home/repository/feed_repository.dart';
import 'package:task_project/features/home/widgets/video_playback.dart';
import 'package:task_project/models/user_models.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  static const routeName = 'user-profile-screen';
  const UserProfileScreen({super.key});

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
                        backgroundImage: NetworkImage(user!.profilePic) ??
                            NetworkImage(
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
                      SizedBox(
                        height: 20,
                      ),
                      GridView.builder(
                          padding: EdgeInsets.all(10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                        videoUrl: user!
                                            .postUploaded[index].postLink
                                            .toString(),
                                      ),
                                    ),
                                  );
                                },
                                //here add a controller whose link will be that in videoUrl
                                child: VideoPlayerCard(
                                    videoUrl:
                                        user!.postUploaded[index].postLink));
                          }),
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
