import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:FLUTTERKINDLE/models/category.dart';
import 'package:FLUTTERKINDLE/util/functions.dart';
import 'package:FLUTTERKINDLE/views/details.dart';
import 'package:uuid/uuid.dart';

class BookCard extends StatelessWidget {
  final String img;
  final Entry entry;

  BookCard({
    Key key,
    @required this.img,
    @required this.entry,
  }) : super(key: key);

  static final uuid = Uuid();
  final String imgTag = uuid.v4();
  final String titleTag = uuid.v4();
  final String authorTag = uuid.v4();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
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
          child: ClipRRect(
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
