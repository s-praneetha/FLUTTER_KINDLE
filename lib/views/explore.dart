import 'package:flutter/material.dart';
import 'package:FLUTTERKINDLE/components/book_card.dart';
import 'package:FLUTTERKINDLE/models/category.dart';
import 'package:FLUTTERKINDLE/util/api.dart';
import 'package:FLUTTERKINDLE/util/functions.dart';
import 'package:FLUTTERKINDLE/view_models/home_provider.dart';
import 'package:FLUTTERKINDLE/views/genre.dart';
import 'package:provider/provider.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (BuildContext context, HomeProvider homeProvider, Widget child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Explore",
            ),
          ),
          body: homeProvider.loading
              ? _buildProgressIndicator()
              : _buildBodyList(homeProvider),
        );
      },
    );
  }

  _buildBodyList(HomeProvider homeProvider) {
    return ListView.builder(
      itemCount: homeProvider.top.feed.link.length,
      itemBuilder: (BuildContext context, int index) {
        Link link = homeProvider.top.feed.link[index];

        // We don't need the tags from 0-9 because
        // they are not categories
        if (index < 10) {
          return SizedBox();
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: <Widget>[
              _buildSectionHeader(link),
              SizedBox(height: 10),
              _buildSectionBookList(link),
            ],
          ),
        );
      },
    );
  }

  _buildProgressIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  _buildSectionHeader(Link link) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              "${link.title}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              Functions.pushPage(
                context,
                Genre(
                  title: "${link.title}",
                  url: Api.baseURL + link.href,
                ),
              );
            },
            child: Text(
              "See All",
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildSectionBookList(Link link) {
    return FutureBuilder<CategoryFeed>(
      future: Api.getCategory(Api.baseURL + link.href),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          CategoryFeed category = snapshot.data;

          return Container(
            height: 200,
            child: Center(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: category.feed.entry.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  Entry entry = category.feed.entry[index];

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: BookCard(
                      img: entry.link[1].href,
                      entry: entry,
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
