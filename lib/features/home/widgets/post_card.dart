import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/features/home/repository/feed_repository.dart';
import 'package:task_project/features/home/screens/another_user_profile_screen.dart';
import 'package:task_project/features/home/screens/post_details_screen.dart';
import 'package:task_project/models/comment_models.dart';
import 'package:video_player/video_player.dart';

class PostCard extends ConsumerStatefulWidget {
  final dynamic snap;

  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool isLikedThePost = false;
  late VideoPlayerController _controller;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.snap['postLink'])
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
    _initializeLikeStatus();
  }

  Future<void> _initializeLikeStatus() async {
    isLikedThePost =
        await ref.read(FeedRepositoryProvider).isLiked(widget.snap['uid']);
    setState(() {});
  }

  void _likeUpdate() async {
    await ref
        .read(FeedRepositoryProvider)
        .likeUpdate(widget.snap['uid'], isLikedThePost);
    setState(() {
      isLikedThePost = !isLikedThePost;
    });
  }

  void _showCommentInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_commentController.text.isNotEmpty) {
                      await ref.read(FeedRepositoryProvider).addComment(
                            widget.snap['uid'],
                            _commentController.text,
                          );
                      _commentController.clear();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCommentsDialog(BuildContext context, List<CommentModel> comments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 400,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Comments',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AnotherUserProfileScreen.routeName,
                              arguments: widget.snap['ownerUid'],
                            );
                          },
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(
                                comments[index].profilePic.toString()),
                          ),
                        ),
                        title: Text(
                          comments[index].name.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(comments[index].comment.toString()),
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
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    widget.snap['ownerProfilePic'] ??
                        'https://example.com/placeholder.jpg',
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AnotherUserProfileScreen.routeName,
                              arguments: widget.snap['ownerUid'],
                            );
                          },
                          child: Text(
                            widget.snap['ownerUserName'] ?? 'Unknown User',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailsScreen(postDetails: widget.snap),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: Text(
                              'Post Details',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          // Video Section
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          // Actions Section
          Row(
            children: [
              IconButton(
                onPressed: _likeUpdate,
                icon: Icon(
                  Icons.favorite,
                  color: isLikedThePost ? Colors.red : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {
                  _showCommentInputDialog(context);
                },
                icon: Icon(Icons.comment_outlined, color: Colors.red),
              ),
            ],
          ),
          // Likes Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('${widget.snap['numberOfLikes'] ?? '0'} Likes'),
          ),
          // Description Section
          Container(
            padding: const EdgeInsets.all(10),
            child: RichText(
              text: TextSpan(
                text: widget.snap['description'] ?? 'Description',
                style: DefaultTextStyle.of(context).style,
              ),
            ),
          ),
          // View Comments Section
          InkWell(
            onTap: () {
              List<dynamic> commentsDynamic = widget.snap['comments'];
              List<CommentModel> comments = commentsDynamic
                  .map((comment) => CommentModel.fromMap(comment))
                  .toList();
              _showCommentsDialog(context, comments);
            },
            child: Text('View all comments'),
          ),
        ],
      ),
    );
  }
}
