import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class PostDetailsScreen extends StatefulWidget {
  final dynamic postDetails;

  const PostDetailsScreen({Key? key, required this.postDetails})
      : super(key: key);

  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.postDetails['postLink'],
    )..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatDateTime(String uploadedTime) {
    // Assuming uploadedTime is a string representation of a timestamp
    final dateTime = DateTime.parse(uploadedTime);
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Content
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    // Add your video player controls here if needed
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Post Content
              Text(
                widget.postDetails['description'] ?? 'No description provided',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              // Owner's Information
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.postDetails['ownerProfilePic'] ??
                          'https://example.com/placeholder.jpg',
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posted by: ${widget.postDetails['ownerUserName'] ?? 'Unknown User'}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Posted on: ${formatDateTime(widget.postDetails['uploadedTime'])}',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Location :  ${widget.postDetails['uploadedCity']}',
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Likes and Comments Count
              Text(
                '${widget.postDetails['numberOfLikes'] ?? 0} Likes',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${widget.postDetails['comments'].length} Comments',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
