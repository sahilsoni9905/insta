import 'package:flutter/material.dart';
import 'package:task_project/features/home/screens/add_post_screen.dart';
import 'package:task_project/features/home/screens/feed_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ),
        ),
      ),
      body: FeedScreen(),
      bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () {
            Navigator.pushNamed(context, AddPostScreen.routeName);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
