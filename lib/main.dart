import 'package:flutter/material.dart';
import 'package:FLUTTERKINDLE/util/consts.dart';
import 'package:FLUTTERKINDLE/util/theme_config.dart';
import 'package:FLUTTERKINDLE/view_models/app_provider.dart';
import 'package:FLUTTERKINDLE/view_models/details_provider.dart';
import 'package:FLUTTERKINDLE/view_models/favorites_provider.dart';
import 'package:FLUTTERKINDLE/view_models/genre_provider.dart';
import 'package:FLUTTERKINDLE/view_models/home_provider.dart';
import 'package:FLUTTERKINDLE/views/splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DetailsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget child) {
        return MaterialApp(
          key: appProvider.key,
          debugShowCheckedModeBanner: false,
          navigatorKey: appProvider.navigatorKey,
          title: Constants.appName,
          theme: appProvider.theme.copyWith(
            textTheme: GoogleFonts.sourceSansProTextTheme(
              appProvider.theme.textTheme,
            ),
          ),
          darkTheme: ThemeConfig.darkTheme.copyWith(
            textTheme: GoogleFonts.sourceSansProTextTheme(
              ThemeConfig.darkTheme.textTheme,
            ),
          ),
          home: Splash(),
        );
      },
    );
  }
}
