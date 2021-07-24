import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection("userFollowing")
        .getDocuments();
    followingUserIds = snapshot.documents.map((doc) => doc.documentID).toList();
    //followingUserIds.add(currentUser.id);
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
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: posts,
                  ),
                ),
              ],
            ),
    );
  }
}
