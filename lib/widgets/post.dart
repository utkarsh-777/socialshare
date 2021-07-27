import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/pages/home.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaURL;
  final dynamic likes;
  final String category;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaURL,
    this.likes,
    this.category,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['caption'],
      mediaURL: doc['mediaURL'],
      likes: doc['likes'],
      category: doc['category'],
    );
  }

  int getLikeCount(likes) {
    // if no likes return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaURL: this.mediaURL,
        likes: this.likes,
        likesCount: getLikeCount(this.likes),
        category: this.category,
      );
}

class _PostState extends State<Post> {
  final currentUserId = currentUser.id;

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaURL;
  final String category;
  int likesCount;
  Map likes;
  bool isLiked;

  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaURL,
    this.likes,
    this.likesCount,
    this.category,
  });

  deletePost(String postId, BuildContext parentContext) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ?'),
          content: Text('Delete Post $postId'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel')),
            ElevatedButton(
                onPressed: () async {
                  await postsRef
                      .document(currentUserId)
                      .collection('userPosts')
                      .document(postId)
                      .delete();
                  Navigator.pop(context);
                  Navigator.pop(parentContext);
                },
                child: Text('Delete')),
          ],
        );
      },
    );
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: RichText(
              text: TextSpan(
                text: user.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: ' (',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: category != null ? category : "General",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: ')',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => deletePost(postId, context),
            icon: user.id == currentUserId
                ? Icon(
                    Icons.delete,
                    color: Colors.red,
                  )
                : Icon(null),
          ),
        );
      },
    );
  }

  handleLikePost() async {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      await postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      removeLikeToActivityFeed();
      setState(() {
        likesCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      await postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likesCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaURL": mediaURL,
        "timeStamp": Timestamp.now()
      });
    }
  }

  removeLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaURL),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 500),
                  tween: Tween(
                    begin: 0.8,
                    end: 1.5,
                  ),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (anim) => Transform.scale(
                    scale: anim.value,
                    child: Opacity(
                      opacity: 0.7,
                      child: Icon(
                        Icons.favorite,
                        size: 100.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Text("")
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 14.0,
                left: 20.0,
              ),
            ),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 20.0,
              ),
            ),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaURL: mediaURL,
              ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 20.0,
              ),
              child: Text(
                "$likesCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 20.0,
              ),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}

showComments(context, {String postId, String ownerId, String mediaURL}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Comments(
        postId: postId,
        postOwnerId: ownerId,
        postMediaURL: mediaURL,
      ),
    ),
  );
}
