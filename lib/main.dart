import 'package:flutter/material.dart';
// import 'package:music_app/themes/lightmode.dart';
// import 'package:music_app/themes/darkmode.dart';
import 'package:music/pages/home_page.dart';
import 'package:music/themes/theme_provider.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
    ChangeNotifierProvider(create: (context) => PlaylistProvider())
    ], child: const MyAppWithSplash()));
  }

  class MyAppWithSplash extends StatefulWidget {
    const MyAppWithSplash({super.key});

    @override
    MyAppWithSplashState createState() => MyAppWithSplashState();
  }

  class MyAppWithSplashState extends State<MyAppWithSplash> {
    bool _isLoading = true;

    @override
    void initState() {
      super.initState();
      _loadData();
    }

    Future<void> _loadData() async {
      await Future.delayed(const Duration(seconds: 3)); 
      setState(() {
        _isLoading = false;
      });
    }

    @override
    Widget build(BuildContext context) {
      if (_isLoading) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
                child: Image.asset(
                'assets/image/splash3.png',
                width: 200.0,
                height: 200.0,
                ),
            ),
          ),
        );
      } else {
        return const MyApp();
      }
    }
  }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}
 