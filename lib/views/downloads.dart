import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epub_kitty/epub_kitty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:FLUTTERKINDLE/database/download_helper.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:uuid/uuid.dart';

class Downloads extends StatefulWidget {
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  static const pageChannel =
      const EventChannel('com.xiaofwang.epub_kitty/page');

  bool done = true;
  var db = DownloadsDB();
  static final uuid = Uuid();

  List dls = List();

  getDownloads() async {
    List l = await db.listAll();
    setState(() {
      dls.addAll(l);
    });
  }

  @override
  void initState() {
    super.initState();
    getDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Downloads"),
      ),
      body: dls.isEmpty ? _buildEmptyListView() : _buildBodyList(),
    );
  }

  _buildBodyList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: dls.length,
      itemBuilder: (BuildContext context, int index) {
        Map dl = dls[index];

        return Dismissible(
          key: ObjectKey(uuid.v4()),
          direction: DismissDirection.endToStart,
          background: _dismissibleBackground(),
          onDismissed: (d) => _deleteBook(dl, index),
          child: InkWell(
            onTap: () {
              String path = dl['path'];
              EpubKitty.setConfig("androidBook", "#06d6a7", "vertical", true);
              EpubKitty.open(path);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: dl['image'],
                    placeholder: (context, url) => Container(
                      height: 70,
                      width: 70,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/images/place.png",
                      fit: BoxFit.cover,
                      height: 70,
                      width: 70,
                    ),
                    fit: BoxFit.cover,
                    height: 70,
                    width: 70,
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          dl['name'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "COMPLETED",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).accentColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              dl['size'],
                              style: TextStyle(
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
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

  _dismissibleBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Feather.trash_2,
        color: Colors.white,
      ),
    );
  }

  _deleteBook(Map dl, int index) {
    db.remove({"id": dl['id']}).then((v) async {
      File f = File(dl['path']);
      if (await f.exists()) {
        f.delete();
      }
      setState(() {
        dls.removeAt(index);
      });
      print("done");
    });
  }
}
