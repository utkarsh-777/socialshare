import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> followingUserIds = [];
  List<Post> posts = [];
  bool isLoading = false;

  getFollowingUsersId() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection("userFollowing")
        .getDocuments();
    followingUserIds = snapshot.documents.map((doc) => doc.documentID).toList();
    await getTimelinePosts(followingUserIds);
  }

  getTimelinePosts(List followingUserIds) async {
    if (followingUserIds.length > 0) {
      List<Post> userPosts = [];
      QuerySnapshot snapshot;
      followingUserIds.forEach((id) async {
        snapshot =
            await postsRef.document(id).collection('userPosts').getDocuments();
        snapshot.documents.forEach((doc) {
          userPosts.add(Post.fromDocument(doc));
        });
        setState(() {
          posts = userPosts;
          isLoading = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFollowingUsersId();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
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
