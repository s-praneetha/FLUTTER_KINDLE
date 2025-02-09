import 'package:cached_network_image/cached_network_image.dart';
import 'package:epub_kitty/epub_kitty.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:FLUTTERKINDLE/components/book_list_item.dart';
import 'package:FLUTTERKINDLE/components/description_text.dart';
import 'package:FLUTTERKINDLE/models/category.dart';
import 'package:FLUTTERKINDLE/view_models/details_provider.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class Details extends StatefulWidget {
  final Entry entry;
  final String imgTag;
  final String titleTag;
  final String authorTag;

  Details({
    Key key,
    @required this.entry,
    @required this.imgTag,
    @required this.titleTag,
    @required this.authorTag,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  static const pageChannel = EventChannel('com.xiaofwang.epub_kitty/page');

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        Provider.of<DetailsProvider>(context, listen: false)
            .setEntry(widget.entry);
        Provider.of<DetailsProvider>(context, listen: false)
            .getFeed(widget.entry.author.uri.t.replaceAll(r"\&lang=en", ""));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailsProvider>(
      builder: (BuildContext context, DetailsProvider detailsProvider,
          Widget child) {
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  if (detailsProvider.faved) {
                    detailsProvider.removeFav();
                  } else {
                    detailsProvider.addFav();
                  }
                },
                icon: Icon(
                  detailsProvider.faved ? Icons.favorite : Feather.heart,
                  color: detailsProvider.faved
                      ? Colors.red
                      : Theme.of(context).iconTheme.color,
                ),
              ),
              IconButton(
                onPressed: () => _share(),
                icon: Icon(
                  Feather.share,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              SizedBox(height: 10),
              _buildImageTitleSection(detailsProvider),
              SizedBox(height: 30),
              _buildSectionTitle("Book Description"),
              _buildDivider(),
              SizedBox(height: 10),
              DescriptionTextWidget(
                text: "${widget.entry.summary.t}",
              ),
              SizedBox(height: 30),
              _buildSectionTitle("More from Author"),
              _buildDivider(),
              SizedBox(height: 10),
              _buildMoreBook(detailsProvider),
            ],
          ),
        );
      },
    );
  }

  _buildDivider() {
    return Divider(
      color: Theme.of(context).textTheme.caption.color,
    );
  }

  _buildImageTitleSection(DetailsProvider detailsProvider) {
    return Container(
      height: 200,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: widget.imgTag,
            child: CachedNetworkImage(
              imageUrl: "${widget.entry.link[1].href}",
              placeholder: (context, url) => Container(
                height: 200,
                width: 130,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Icon(Feather.x),
              fit: BoxFit.cover,
              height: 200,
              width: 130,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                Hero(
                  tag: widget.titleTag,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      "${widget.entry.title.t.replaceAll(r"\", "")}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Hero(
                  tag: widget.authorTag,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      "${widget.entry.author.name.t}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                _buildCategory(widget.entry, context),
                Center(
                  child: Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width,
                    child: _buildDownloadReadButton(detailsProvider, context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildSectionTitle(String title) {
    return Text(
      "$title",
      style: TextStyle(
        color: Theme.of(context).accentColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  _buildMoreBook(DetailsProvider provider) {
    if (provider.loading) {
      return Container(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: provider.related.feed.entry.length,
        itemBuilder: (BuildContext context, int index) {
          Entry entry = provider.related.feed.entry[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: BookListItem(
              img: entry.link[1].href,
              title: entry.title.t,
              author: entry.author.name.t,
              desc: entry.summary.t,
              entry: entry,
            ),
          );
        },
      );
    }
  }

  _buildDownloadReadButton(DetailsProvider provider, BuildContext context) {
    if (provider.downloaded) {
      return FlatButton(
        onPressed: () {
          provider.getDownload().then((dlList) {
            if (dlList.isNotEmpty) {
              // dlList is a list of the downloads relating to this Book's id.
              // The list will only contain one item since we can only
              // download a book once. Then we use `dlList[0]` to choose the
              // first value from the string as out local book path
              Map dl = dlList[0];
              String path = dl['path'];
              EpubKitty.setConfig("androidBook", "#06d6a7", "vertical", true);
              EpubKitty.open(path);
            }
          });
        },
        child: Text(
          "Read Book",
        ),
      );
    } else {
      return FlatButton(
        onPressed: () => provider.downloadFile(
          context,
          widget.entry.link[3].href,
          widget.entry.title.t.replaceAll(" ", "_").replaceAll(r"\'", ""),
        ),
        child: Text(
          "Download",
        ),
      );
    }
  }

  _buildCategory(Entry entry, BuildContext context) {
    if (entry.category == null) {
      return SizedBox();
    } else {
      return Container(
        height: entry.category.length < 3 ? 55 : 95,
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: entry.category.length > 4 ? 4 : entry.category.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 210 / 80,
          ),
          itemBuilder: (BuildContext context, int index) {
            Category cat = entry.category[index];
            return Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      "${cat.label}",
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: cat.label.length > 18 ? 6 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  _share() {
    Share.text(
      "${widget.entry.title.t} by ${widget.entry.author.name.t}",
      "Read/Download ${widget.entry.title.t} from ${widget.entry.link[3].href}.",
      "text/plain",
    );
  }
}
