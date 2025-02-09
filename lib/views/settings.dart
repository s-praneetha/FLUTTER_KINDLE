import 'package:flutter/material.dart';
import 'package:FLUTTERKINDLE/util/functions.dart';
import 'package:FLUTTERKINDLE/util/theme_config.dart';
import 'package:FLUTTERKINDLE/view_models/app_provider.dart';
import 'package:FLUTTERKINDLE/views/downloads.dart';
import 'package:FLUTTERKINDLE/views/favorites.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List items;

  @override
  void initState() {
    super.initState();
    items = [
      {
        "icon": Feather.heart,
        "title": "Favorites",
        "function": () => _pushPage(Favorites()),
      },
      {
        "icon": Feather.download,
        "title": "Downloads",
        "function": () => _pushPage(Downloads()),
      },
      {
        "icon": Feather.moon,
        "title": "Dark Mode",
        "function": () => _pushPage(Downloads()),
      },
      {
        "icon": Feather.info,
        "title": "About",
        "function": () => showAbout(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Remove Dark Switch if Device has Dark mode enabled
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      items.removeWhere((item) => item['title'] == "Dark Mode");
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Settings",
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          if (items[index]['title'] == "Dark Mode") {
            return _buildThemeSwitch(items[index]);
          }

          return ListTile(
            onTap: items[index]['function'],
            leading: Icon(
              items[index]['icon'],
            ),
            title: Text(
              items[index]['title'],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }

  Widget _buildThemeSwitch(Map item) {
    return SwitchListTile(
      secondary: Icon(
        item['icon'],
      ),
      title: Text(
        item['title'],
      ),
      value: Provider.of<AppProvider>(context).theme == ThemeConfig.lightTheme
          ? false
          : true,
      onChanged: (v) {
        if (v) {
          Provider.of<AppProvider>(context, listen: false)
              .setTheme(ThemeConfig.darkTheme, "dark");
        } else {
          Provider.of<AppProvider>(context, listen: false)
              .setTheme(ThemeConfig.lightTheme, "light");
        }
      },
    );
  }

  _pushPage(Widget page) {
    Functions.pushPage(
      context,
      page,
    );
  }

  _pushPageDialog(Widget page) {
    Functions.pushPageDialog(
      context,
      page,
    );
  }

  showAbout() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            "About",
          ),
          content: Text(
            "Simple KINDLE Application by S.Praneetha",
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).accentColor,
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
              ),
            ),
          ],
        );
      },
    );
  }
}
