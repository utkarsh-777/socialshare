import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaURL;
  Comments({
    Key key,
    @required this.postId,
    this.postMediaURL,
    this.postOwnerId,
  }) : super(key: key);
  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaURL: this.postMediaURL,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaURL;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaURL,
  });

  buildComments() {
    return StreamBuilder(
        stream: commentsRef
            .document(postId)
            .collection("comments")
            .orderBy("timeStamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          snapshot.data.documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    commentsRef.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timeStamp": Timestamp.now(),
      "avatarURL": currentUser.photoUrl,
      "userId": currentUser.id,
    });
    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      activityFeedRef.document(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaURL": postMediaURL,
        "commentData": commentController.text,
        "timeStamp": Timestamp.now()
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: [
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Write a comment...'),
            ),
            trailing: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => addComment(),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarURL;
  final String comment;
  final Timestamp timeStamp;

  Comment({
    this.username,
    this.userId,
    this.avatarURL,
    this.comment,
    this.timeStamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarURL: doc['avatarURL'],
      comment: doc['comment'],
      timeStamp: doc['timeStamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarURL),
          ),
          subtitle: Text(timeago.format(timeStamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
