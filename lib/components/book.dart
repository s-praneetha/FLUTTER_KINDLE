import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:FLUTTERKINDLE/models/category.dart';
import 'package:FLUTTERKINDLE/util/functions.dart';
import 'package:FLUTTERKINDLE/views/details.dart';
import 'package:uuid/uuid.dart';

class BookItem extends StatelessWidget {
  final String img;
  final String title;
  final Entry entry;

  BookItem({
    Key key,
    @required this.img,
    @required this.title,
    @required this.entry,
  }) : super(key: key);

  static final uuid = Uuid();
  final String imgTag = uuid.v4();
  final String titleTag = uuid.v4();
  final String authorTag = uuid.v4();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Functions.pushPage(
          context,
          Details(
            entry: entry,
            imgTag: imgTag,
            titleTag: titleTag,
            authorTag: authorTag,
          ),
        );
      },
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            child: Hero(
              tag: imgTag,
              child: CachedNetworkImage(
                imageUrl: "$img",
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/images/place.png",
                  fit: BoxFit.cover,
                ),
                fit: BoxFit.cover,
                height: 150,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Hero(
            tag: titleTag,
            child: Text(
              "${title.replaceAll(r"\", "")}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
