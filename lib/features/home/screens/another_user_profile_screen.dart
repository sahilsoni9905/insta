import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/features/home/repository/feed_repository.dart';
import 'package:task_project/features/home/widgets/video_playback.dart';
import 'package:task_project/models/user_models.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class AnotherUserProfileScreen extends ConsumerStatefulWidget {
  static const routeName = 'another-user-profile-screen';
  final String userUid;

  const AnotherUserProfileScreen({Key? key, required this.userUid})
      : super(key: key);

  @override
  ConsumerState<AnotherUserProfileScreen> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<AnotherUserProfileScreen> {
  UserModel? user;
  bool followStatus = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkFollowStatus();
  }

  Future<void> _loadUserData() async {
    user = await ref
        .read(FeedRepositoryProvider)
        .getAnotherUserData(widget.userUid);
    setState(() {});
  }

  Future<bool> _checkFollowStatus() async {
    followStatus =
        await ref.read(FeedRepositoryProvider).isFollowing(widget.userUid);
    return followStatus;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return FutureBuilder<bool>(
      future: _checkFollowStatus(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
          ),
          body: StreamBuilder<DocumentSnapshot>(
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
              user = UserModel.fromMap(userData);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user!.profilePic) ??
                              const NetworkImage(
                                  'https://media.istockphoto.com/id/953079238/photo/smiling-man-with-hat-and-sunglasses.jpg?s=1024x1024&w=is&k=20&c=pQQYoyt5ytYtFRhbdVKRqqIfTDEJt6FJ_r-VJ5_fmkU='),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (followStatus == false) {
                              await ref
                                  .read(FeedRepositoryProvider)
                                  .addFollowing(widget.userUid.toString());
                            } else {
                              await ref
                                  .read(FeedRepositoryProvider)
                                  .removeFollowing(widget.userUid.toString());
                            }
                            setState(() {
                              followStatus = !followStatus;
                            });
                          },
                          child: followStatus == false
                              ? const Text('Follow')
                              : const Text('Following ✔️✔️'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user!.name ?? 'Not found',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${user!.postUploaded.length} Reels Uploaded',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      padding: const EdgeInsets.all(10),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  videoUrl: user!.postUploaded[index].postLink
                                      .toString(),
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
              );
            },
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
    setState(() {});
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
            : const CircularProgressIndicator(
                color: Colors.black,
              ),
      ),
    );
  }
}
