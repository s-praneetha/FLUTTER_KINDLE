import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:FLUTTERKINDLE/components/book_list_item.dart';
import 'package:FLUTTERKINDLE/models/category.dart';
import 'package:FLUTTERKINDLE/view_models/genre_provider.dart';
import 'package:provider/provider.dart';

class Genre extends StatefulWidget {
  final String title;
  final String url;

  Genre({
    Key key,
    @required this.title,
    @required this.url,
  }) : super(key: key);

  @override
  _GenreState createState() => _GenreState();
}

class _GenreState extends State<Genre> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => Provider.of<GenreProvider>(context, listen: false)
          .getFeed(widget.url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, GenreProvider provider, Widget child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("${widget.title}"),
          ),
          body: provider.loading
              ? _buildProgressIndicator()
              : _buildBodyList(provider),
        );
      },
    );
  }

  _buildBodyList(GenreProvider provider) {
    return ListView(
      controller: provider.controller,
      children: <Widget>[
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 10),
          shrinkWrap: true,
          itemCount: provider.items.length,
          itemBuilder: (BuildContext context, int index) {
            Entry entry = provider.items[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5.0),
              child: BookListItem(
                img: entry.link[1].href,
                title: entry.title.t,
                author: entry.author.name.t,
                desc: entry.summary.t,
                entry: entry,
              ),
            );
          },
        ),
        SizedBox(height: 10),
        provider.loadingMore
            ? Container(
                height: 80,
                child: _buildProgressIndicator(),
              )
            : SizedBox(),
      ],
    );
  }

  _buildProgressIndicator() {
    return Center(child: CircularProgressIndicator());
  }
}
