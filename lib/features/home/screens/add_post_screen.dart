import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_project/common/utils.dart';
import 'package:task_project/features/auth/repository/auth_repository.dart';
import 'package:task_project/models/user_models.dart';
import 'package:video_player/video_player.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  static const String routeName = 'add-post-screen';
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  File? _file;
  final TextEditingController _descriptionController = TextEditingController();
  UserModel? userDetails;
  VideoPlayerController? _videoPlayerController;
  bool _isLoading = false; // Add this state variable

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  File? file = await pickVideo(context, ImageSource.camera);
                  if (file != null) {
                    _videoPlayerController = VideoPlayerController.file(file)
                      ..initialize().then((_) {
                        setState(() {
                          _file = file;
                        });
                        _videoPlayerController?.play();
                      });
                  }
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  File? file = await pickVideo(context, ImageSource.gallery);
                  if (file != null) {
                    _videoPlayerController = VideoPlayerController.file(file)
                      ..initialize().then((_) {
                        setState(() {
                          _file = file;
                        });
                        _videoPlayerController?.play();
                      });
                  }
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  _uploadPost(BuildContext context, String description, String category) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      ref.read(AuthRepositoryProvider).saveUserPostToFirebase(
            description: description,
            category: category,
            videoFile: _file!,
            context: context,
          );
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Text(
                    'Uploading ...',
                    style: TextStyle(fontSize: 40),
                  ),
                )
              ],
            );
          });
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    userDetails = await ref.read(AuthRepositoryProvider).getCurrentUserData();
    setState(() {});
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _file == null
        ? Center(
            child: IconButton(
                onPressed: () => _selectImage(context),
                icon: const Icon(
                  Icons.upload,
                  size: 100,
                )),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back
                  },
                  icon: const Icon(Icons.arrow_back)),
              title: const Text('Post to'),
              centerTitle: false,
              actions: [
                TextButton(
                    onPressed: () {
                      _uploadPost(context, _descriptionController.text, '');
                    },
                    child: const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
              ],
            ),
            body: Stack(
              // Use Stack to show loading indicator over the content
              children: [
                Column(
                  children: <Widget>[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        userDetails != null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userDetails!.profilePic),
                              )
                            : const CircleAvatar(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                                hintText: "Write a caption...",
                                border: InputBorder.none),
                            maxLines: 8,
                          ),
                        ),
                        SizedBox(
                          height: 45.0,
                          width: 45.0,
                          child: _videoPlayerController != null &&
                                  _videoPlayerController!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _videoPlayerController!.value.aspectRatio,
                                  child: VideoPlayer(_videoPlayerController!),
                                )
                              : Container(),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
                if (_isLoading) // Show loading indicator when loading
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
  }
}
