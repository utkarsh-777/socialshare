import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class CategoryFeed extends StatefulWidget {
  final String category;
  CategoryFeed({Key key, @required this.category}) : super(key: key);

  @override
  _CategoryFeedState createState() => _CategoryFeedState(category);
}

class _CategoryFeedState extends State<CategoryFeed> {
  final String category;
  _CategoryFeedState(this.category);

  List<dynamic> followingUserIds = [];
  List<Post> posts = [];
  bool isLoading = false;

  getCategoryPosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await categoricalPostsRef
        .document(category)
        .collection('posts')
        .getDocuments();

    setState(() {
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getCategoryPosts();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, titleText: category),
      body: isLoading
          ? circularProgress()
          : posts.length > 0
              ? ListView(
                  children: [
                    Container(
                      child: Column(
                        children: posts,
                      ),
                    ),
                  ],
                )
              : Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/images/no_content.svg",
                        height: 220,
                      ),
                    ],
                  ),
                ),
    );
  }
}
