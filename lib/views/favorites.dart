import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:FLUTTERKINDLE/components/book.dart';
import 'package:FLUTTERKINDLE/models/category.dart';
import 'package:FLUTTERKINDLE/view_models/favorites_provider.dart';
import 'package:provider/provider.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => Provider.of<FavoritesProvider>(context, listen: false).getFeed(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (BuildContext context, FavoritesProvider favoritesProvider,
          Widget child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Favorites",
            ),
          ),
          body: favoritesProvider.posts.isEmpty
              ? _buildEmptyListView()
              : _buildGridView(favoritesProvider),
        );
      },
    );
  }

  _buildEmptyListView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Nothing is here",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _buildGridView(FavoritesProvider favoritesProvider) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
      shrinkWrap: true,
      itemCount: favoritesProvider.posts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 200 / 340,
      ),
      itemBuilder: (BuildContext context, int index) {
        Entry entry = Entry.fromJson(favoritesProvider.posts[index]["item"]);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: BookItem(
            img: entry.link[1].href,
            title: entry.title.t,
            entry: entry,
          ),
        );
      },
    );
  }
}
