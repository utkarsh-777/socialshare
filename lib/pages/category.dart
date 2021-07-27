import 'package:flutter/material.dart';
import 'package:fluttershare/pages/category_feed.dart';
import 'package:fluttershare/widgets/header.dart';

class Category extends StatefulWidget {
  Category({Key key}) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  navigateToCategoryFeed(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFeed(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: header(
          context,
          titleText: 'Category',
        ),
        body: Container(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => navigateToCategoryFeed('General'),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(
                          Icons.analytics,
                          size: 30,
                        ),
                        title: Text('General'),
                        subtitle:
                            Text('Find the general/random collection of posts'),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToCategoryFeed('Sports'),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(
                          Icons.sports,
                          size: 30,
                        ),
                        title: Text('Sports'),
                        subtitle: Text(
                          'Posts on sports',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToCategoryFeed('Health'),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(
                          Icons.health_and_safety,
                          size: 30,
                        ),
                        title: Text(
                          'Health and Safety',
                        ),
                        subtitle: Text(
                          'Posts on health and safety',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToCategoryFeed('News'),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(
                          Icons.tv_rounded,
                          size: 30,
                        ),
                        title: Text('News'),
                        subtitle: Text(
                          'Posts on news',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToCategoryFeed('Politics'),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(
                          Icons.policy_sharp,
                          size: 30,
                        ),
                        title: Text('Politics'),
                        subtitle:
                            Text('Posts about politics and current affairs'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
