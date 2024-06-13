import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_project/features/home/repository/feed_repository.dart';
import 'package:task_project/features/home/screens/post_details_screen.dart';
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
  TextEditingController _commentController = TextEditingController();

  void showCommentInputDialog(BuildContext context) {
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
                    // Add the comment to the post
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

  void likeUpdate() async {
    await ref
        .read(FeedRepositoryProvider)
        .likeUpdate(widget.snap['uid'], isLikedThePost);
    setState(() {
      isLikedThePost = !isLikedThePost;
    });
  }

  void showCommentsDialog(BuildContext context, List<dynamic> comments) {
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
                        title: Text(comments[index].toString()),
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snap['ownerUserName'] ?? 'Unknown User',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                          child: Container(
                            height: 50,
                            child: Text(
                              'Post Details',
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailsScreen(postDetails: widget.snap),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
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
          Row(
            children: [
              IconButton(
                onPressed: likeUpdate,
                icon: Icon(
                  Icons.favorite,
                  color: isLikedThePost
                      ? Colors.red
                      : Color.fromARGB(255, 155, 150, 150),
                ),
              ),
              IconButton(
                onPressed: () {
                  showCommentInputDialog(context);
                },
                icon: Icon(Icons.comment_outlined, color: Colors.red),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.snap['numberOfLikes'].toString() ?? 'Error'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: RichText(
              text: TextSpan(
                text: widget.snap['description'] ?? 'Description',
                style: DefaultTextStyle.of(context).style,
              ),
            ),
          ),
          InkWell(
            onTap: () => showCommentsDialog(context, widget.snap['comments']),
            child: Text('view all comments'),
          ),
        ],
      ),
    );
  }
}
