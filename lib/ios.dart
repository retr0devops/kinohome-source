import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:better_player/better_player.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sp_util/sp_util.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx/webviewx.dart';

import 'func.dart' as functions;
import 'globals.dart' as globals;

bool light = false;

class MyApp extends StatelessWidget {
  final List<Color> accentId = [
    CupertinoColors.white,
    CupertinoColors.activeBlue,
    CupertinoColors.systemGreen,
    CupertinoColors.systemIndigo,
    CupertinoColors.systemOrange,
    CupertinoColors.systemPink,
    CupertinoColors.systemPurple,
    CupertinoColors.systemRed,
    CupertinoColors.systemYellow,
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorObservers: [Helper.routeObserver],
      theme: CupertinoThemeData(
          barBackgroundColor: CupertinoColors.black,
          primaryColor: accentId[SpUtil.getInt("accent", defValue: 0)!],
          brightness: Brightness.dark),
      title: 'KinoHomeTest',
      home: TabHomePage(),
    );
  }
}

class TabHomePage extends StatefulWidget {
  @override
  _TabHomePageState createState() => _TabHomePageState();
}

class _TabHomePageState extends State<TabHomePage> {
  List<Widget> _tabs = [
    MyHomePage(title: "KinoHomeTest"),
    SearchRoute(),
    ProfileRoute()
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        resizeToAvoidBottomInset: true,
        tabBar: CupertinoTabBar(
          backgroundColor: CupertinoColors.black.withOpacity(0.7),
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: "Главная"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search), label: "Поиск"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.profile_circled), label: "Профиль"),
          ],
        ),
        tabBuilder: (BuildContext context, index) {
          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                CupertinoSliverNavigationBar(
                  backgroundColor: CupertinoColors.black,
                  largeTitle: Text('KinoHomeTest'),
                )
              ];
            },
            body: _tabs[index],
          );
        });
  }
}

class MyTorrentPage extends StatefulWidget {
  MyTorrentPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyTorrentPageState createState() => _MyTorrentPageState();
}

class _MyTorrentPageState extends State<MyTorrentPage> {
  final String apiUrl = "http://37.1.217.106";

  Future<List<dynamic>> fetchFileInfo() async {
    var result = [];

    var url = "$apiUrl/search/${globals.title}";

    var response = await http.get(Uri.parse(url));

    var decodedResponse = utf8.decode(response.bodyBytes);

    return functions.fileSizeInfo(result, url, response, decodedResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: CupertinoPageScaffold(
          resizeToAvoidBottomInset: false,
          navigationBar: CupertinoNavigationBar(
            middle: Text("Торрент"),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchFileInfo(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(8),
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  onTap: () {
                                    functions.downloadTorrent(
                                        "http://37.1.217.106" +
                                            snapshot.data[index].split("`")[1]);
                                  },
                                  child: Container(
                                    child: CupertinoListTile(
                                      title: Text(
                                          snapshot.data[index].split("`")[0]),
                                      subtitle: Text(
                                          snapshot.data[index].split("`")[2]),
                                    ),
                                  ));
                            });
                      } else {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height / 1.3,
                          child: Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                ),
                if (globals.isPremium != true)
                  UnityBannerAd(
                    placementId: globals.banner,
                  )
              ],
            ),
          )),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
                future: functions.fetchNPTR(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15.0, bottom: 8.0, right: 15.0),
                                child: GridView(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  shrinkWrap: true,
                                  children: [
                                    CupertinoButton(
                                      child: Container(
                                        height: 170,
                                        width: 170,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                "https://kinopoiskapiunofficial.tech/images/posters/kp/301.jpg"),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 3.5, sigmaY: 3.5),
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  15, 15, 15, 0),
                                              child: AutoSizeText(
                                                "Избранные\nфильмы",
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                    fontSize: 23,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        globals.ids = SpUtil.getStringList(
                                            "fav",
                                            defValue: [])?.join(",");
                                        globals.podbName = "Избранное";
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    PodbRoute()));
                                      },
                                    ),
                                    CupertinoButton(
                                      child: Container(
                                        height: 170,
                                        width: 170,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                "https://kinopoiskapiunofficial.tech/images/posters/kp/394368.jpg"),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          // make sure we apply clip it properly
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 3.5, sigmaY: 3.5),
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  15, 15, 15, 0),
                                              child: AutoSizeText(
                                                "История\nпросмотра",
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                    fontSize: 23,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        globals.ids = SpUtil.getStringList(
                                            "historyy",
                                            defValue: [])?.join(",");
                                        globals.podbName = "История";
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    PodbRoute()));
                                      },
                                    ),
                                    CupertinoButton(
                                      child: Container(
                                        height: 170,
                                        width: 170,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                "https://kinopoiskapiunofficial.tech/images/posters/kp/588.jpg"),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          // make sure we apply clip it properly
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 3.5, sigmaY: 3.5),
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  15, 15, 15, 0),
                                              child: AutoSizeText(
                                                "Личная\nподборка",
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                    fontSize: 23,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (!globals.isPremium) {
                                          showCupertinoSnackBar(
                                              context: context,
                                              message:
                                                  'Доступно только для премиум пользователей');
                                        } else {
                                          globals.ids = SpUtil.getStringList(
                                              "fav",
                                              defValue: [])?.join(",");
                                          globals.podbName =
                                              "Персональная подборка";
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      PersonalRoute()));
                                        }
                                      },
                                    ),
                                    CupertinoButton(
                                      child: Container(
                                        height: 170,
                                        width: 170,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                "https://kinopoiskapiunofficial.tech/images/posters/kp/3793.jpg"),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          // make sure we apply clip it properly
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 3.5, sigmaY: 3.5),
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  15, 15, 15, 0),
                                              child: AutoSizeText(
                                                "Мне\nповезет!",
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                    fontSize: 23,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  RandomRoute()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: 0, bottom: 0, left: 15, right: 0),
                                child: Text("Новинки",
                                    style: TextStyle(fontSize: 23.0))),
                          ),
                          SizedBox(
                            height: 330,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(8),
                                itemCount: snapshot.data[0].length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      functions.pushFromMenu(
                                          snapshot.data[0][index]['ru_name']
                                              .toString(),
                                          snapshot.data[0][index]['id']
                                              .toString(),
                                          snapshot.data[0][index]['is_serial'],
                                          snapshot.data[0][index]['imdb_id'] ==
                                                  false
                                              ? "0"
                                              : snapshot.data[0][index]
                                                  ['imdb_id'],
                                          context);
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      width: 150,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                (SpUtil.getBool("ua",
                                                            defValue: false) ==
                                                        false)
                                                    ? "https://kinopoiskapiunofficial.tech/images/posters/kp/${snapshot.data[0][index]['id']}.jpg"
                                                    : snapshot.data[0][index]
                                                            ['poster']
                                                        .replaceAll(
                                                            "https://int.cocine.me",
                                                            globals.baseUrl),
                                                height: 200,
                                                width: 150,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            AutoSizeText(
                                              snapshot.data[0][index]
                                                  ['ru_name'],
                                              maxLines: 3,
                                              style: TextStyle(fontSize: 17.0),
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            AutoSizeText(
                                              functions.filmInfo(
                                                  snapshot.data[0], index),
                                              maxLines: 5,
                                              style: TextStyle(
                                                  fontSize: 11.0,
                                                  color: !light
                                                      ? CupertinoColors
                                                          .inactiveGray
                                                      : CupertinoColors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: 0, bottom: 0, left: 15, right: 0),
                                child: Text("Популярное",
                                    style: TextStyle(fontSize: 23.0))),
                          ),
                          SizedBox(
                            height: 330,
                            child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data[1].length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      functions.pushFromMenu(
                                          snapshot.data[1][index]['ru_name']
                                              .toString(),
                                          snapshot.data[1][index]['id']
                                              .toString(),
                                          snapshot.data[1][index]['is_serial'],
                                          snapshot.data[1][index]['imdb_id'] ==
                                                  false
                                              ? "0"
                                              : snapshot.data[1][index]
                                                  ['imdb_id'],
                                          context);
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      width: 150,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                (SpUtil.getBool("ua",
                                                            defValue: false) ==
                                                        false)
                                                    ? "https://kinopoiskapiunofficial.tech/images/posters/kp/${snapshot.data[1][index]['id']}.jpg"
                                                    : snapshot.data[1][index]
                                                            ['poster']
                                                        .replaceAll(
                                                            "https://int.cocine.me",
                                                            globals.baseUrl),
                                                height: 200,
                                                width: 150,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            AutoSizeText(
                                              snapshot.data[1][index]
                                                  ['ru_name'],
                                              maxLines: 3,
                                              style: TextStyle(fontSize: 17.0),
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            AutoSizeText(
                                              functions.filmInfo(
                                                  snapshot.data[1], index),
                                              maxLines: 5,
                                              style: TextStyle(
                                                  fontSize: 11.0,
                                                  color: !light
                                                      ? CupertinoColors
                                                          .inactiveGray
                                                      : CupertinoColors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: 0, bottom: 0, left: 15, right: 0),
                                child: Text("Лучшее",
                                    style: TextStyle(fontSize: 23.0))),
                          ),
                          SizedBox(
                            height: 330,
                            child: ListView.builder(
                                padding: const EdgeInsets.all(8),
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data[2].length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      functions.pushFromMenu(
                                          snapshot.data[2][index]['ru_name']
                                              .toString(),
                                          snapshot.data[2][index]['id']
                                              .toString(),
                                          snapshot.data[2][index]['is_serial'],
                                          snapshot.data[2][index]['imdb_id'] ==
                                                  false
                                              ? "0"
                                              : snapshot.data[2][index]
                                                  ['imdb_id'],
                                          context);
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      width: 150,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                (SpUtil.getBool("ua",
                                                            defValue: false) ==
                                                        false)
                                                    ? "https://kinopoiskapiunofficial.tech/images/posters/kp/${snapshot.data[2][index]['id']}.jpg"
                                                    : snapshot.data[2][index]
                                                            ['poster']
                                                        .replaceAll(
                                                            "https://int.cocine.me",
                                                            globals.baseUrl),
                                                height: 200,
                                                width: 150,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            AutoSizeText(
                                              snapshot.data[2][index]
                                                  ['ru_name'],
                                              maxLines: 3,
                                              style: TextStyle(fontSize: 17.0),
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            AutoSizeText(
                                              functions.filmInfo(
                                                  snapshot.data[2], index),
                                              maxLines: 5,
                                              style: TextStyle(
                                                  fontSize: 11.0,
                                                  color: !light
                                                      ? CupertinoColors
                                                          .inactiveGray
                                                      : CupertinoColors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                }),
          ),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Album {
  final String url;

  Album({
    required this.url,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      url: json['iframe_url'],
    );
  }
}

class _GetMovieRouteState extends State<GetMovieRoute> {
  void fromTranslationToWatch(String link) {
    if (SpUtil.getStringList("historyy", defValue: [])?.contains(globals.id) !=
        true) {
      var a = SpUtil.getStringList("historyy", defValue: []);
      a?.add(globals.id);
      SpUtil.putStringList("historyy", a!);
    }

    globals.filmLink = link;

    if (globals.adblockNeedKey != true) {
      globals.watchLink = globals.filmLink;
      if (Platform.isIOS) {
        if (SpUtil.getBool("safari", defValue: false) == false) {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => WatchRoute()),
          );
        } else {
          launchUrl(Uri.parse(globals.watchLink),
              mode: LaunchMode.externalApplication);
        }
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => OpenVideoRoute()),
        );
      }
    } else {
      showCupertinoSnackBar(
          context: context,
          message:
              'Просмотр с включенным AdBlock невозможен. Отключите блокировщик и перезапустите приложение');
    }
  }

  Future<List<dynamic>> fetchNameLink() async {
    var result = [];

    if (SpUtil.getBool("rezka", defValue: true) == true) {
      try {
        var rezkaHeaders = {
          'X-App-Hdrezka-App': '1',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept-Encoding': 'gzip',
        };

        var searchRezka = await http.get(
            Uri.parse(
                "http://hdrzk.org/engine/ajax/search.php?q=" + globals.title),
            headers: rezkaHeaders);
        var rezkaMoviePage = await http.get(
            Uri.parse(searchRezka.body.split('<a href="')[1].split('"')[0]),
            headers: rezkaHeaders);

        var rezkaBody = rezkaMoviePage.body;
        var field = rezkaBody.split('<ul id="translators-list"')[1];
        var movieID = field.split('data-id="')[1].split('"')[0];
        for (int i = 0; i <= 10; i++) {
          try {
            var translatorName =
                field.split('<li title="')[i + 1].split('"')[0];
            var translatorID =
                field.split('data-translator_id="')[i + 1].split('"')[0];
            var data =
                'translator_id=$translatorID&id=$movieID&action=get_movie';
            var url = Uri.parse('http://hdrzk.org/ajax/get_cdn_series/');
            var movieRequest =
                await http.post(url, headers: rezkaHeaders, body: data);
            result.add(translatorName +
                ";" +
                functions
                    .getRezkaStream(json.decode(movieRequest.body)['url']) +
                ";Rezka");
          } catch (e) {}
        }
      } catch (e) {}
    }

    if (SpUtil.getBool("hdvb", defValue: true) == true) {
      try {
        var jsonn = await http.get(Uri.parse(
            "https://apivb.info/api/videos.json?token=5e2fe4c70bafd9a7414c4f170ee1b192&id_kp=${globals.id}"));
        var jsonB = json.decode(jsonn.body)[0];
        var transHName = toBeginningOfSentenceCase(jsonB['translator']);
        var url = await http
            .get(Uri.parse(jsonB["iframe_url"].replaceAll("\\/", "/")));
        var ifr = jsonB["iframe_url"].replaceAll("\\/", "/");
        var ifrt = url.body;
        var lp = ifr.split("/movie")[0] +
            "/playlist/" +
            ifrt.split("\"file\":\"")[1].split('"')[0] +
            ".txt";
        var token = ifrt.split("\"key\":\"")[1].split('"')[0];

        var headers = {
          'authority': '${ifr.split("/")[2].split("/")[0]}',
          'accept': '*/*',
          'accept-language': 'en-US,en;q=0.9,ru;q=0.8,pl;q=0.7',
          'content-length': '0',
          'content-type': 'application/x-www-form-urlencoded',
          'cookie': '_ym_d=1653226698',
          'origin': '${ifr.split("/movie")[0]}',
          'referer': '$ifr',
          'sec-fetch-dest': 'empty',
          'sec-fetch-mode': 'cors',
          'sec-fetch-site': 'same-origin',
          'user-agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/104.0.5112.81',
          'x-csrf-token': '$token',
          'Accept-Encoding': 'gzip',
        };

        var reqHDVB = await http.post(Uri.parse(lp), headers: headers);
        result.add(transHName! + ";" + reqHDVB.body + ";HDVB");
      } catch (e) {}
    }

    if (SpUtil.getBool("collaps", defValue: true) == true) {
      try {
        var response = await http.get(Uri.parse(
            "https://apicollaps.cc/list?token=eedefb541aeba871dcfc756e6b31c02e&kinopoisk_id=" +
                globals.id));
        var info = await http.get(
            Uri.parse(json.decode(response.body)['results'][0]['iframe_url']));
        var cLink = info.body.split("hls: \"")[1].split('"')[0];
        var cName = info.body.split("{\"names\":[\"")[1].split('"')[0];
        result.add(cName + ";" + cLink + ";1080P (Collaps)");
      } catch (e) {}
    }

    if (SpUtil.getBool("nm2", defValue: true) == true) {
      try {
        var nresp = await http.get(Uri.parse(
            "https://nm2.me/movies?utf8=%E2%9C%93&movie_search=" +
                globals.title +
                "&commit=%D0%9D%D0%B0%D0%B9%D1%82%D0%B8"));
        var rbody = await http.get(Uri.parse("https://nm2.me" +
            nresp.body.split("<a href=\"")[1].split("\">")[0]));
        var narray = ("[" +
                rbody.body
                    .split("new Playerjs(")[1]
                    .split("[")[1]
                    .split("],")[0]
                    .trim() +
                "]")
            .replaceAll(",]", "]");
        var nname = json.decode(narray)[0]['title'];
        var nlink = "https://nm2.me" +
            json
                .decode(narray)[0]['file']
                .replaceAll("..", "")
                .replaceAll("-index.m3u8", "-1080-.m3u8");
        result.add(nname + ";" + nlink + ";1080P (Namba)");
      } catch (e) {}
    }

    if (SpUtil.getBool("iframe", defValue: true) == true) {
      try {
        var ireq = await http.get(Uri.parse(
            "https://videoframe.space/frameindex.php?kp=" + globals.id));
        var ibo = ireq.body;

        var headers = {
          'Accept': '*/*',
          'Accept-Language': 'en-US,en;q=0.9,ru;q=0.8,pl;q=0.7',
          'Connection': 'keep-alive',
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Origin': 'https://videoframe.space',
          'P-REF': 'https://videoframe.space',
          'Referer': 'https://videoframe.space/',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36 Edg/103.0.5060.114',
          'X-REF': 'https://videoframe.space',
          'Accept-Encoding': 'gzip',
        };

        for (int i = 0; i < 10; i++) {
          if (ibo
                  .split("<a href='/movie/")
                  .indexOf(ibo.split("<a href='/movie/").last) >
              i) {
            var oneID = ibo.split("<a href='/movie/")[i + 1].split("/")[0];
            var oneLang = ibo.split("'><span title='")[i + 1].split("'")[0];
            var body =
                "token=$oneID&type=movie&season=&episode=&mobile=true&id=2873&qt=" +
                    (SpUtil.getBool("hq", defValue: true) == true
                        ? "1080"
                        : "480");
            var url1 = await http.post(
                Uri.parse("https://videoframe.space/loadvideo"),
                headers: headers,
                body: body);
            var iURL = json.decode(url1.body)['src'].toString();
            result.add(oneLang + ";" + iURL + ";VideoFrame");
          } else {
            break;
          }
        }
      } catch (e) {}
    }

    if (SpUtil.getBool("filmix", defValue: true) == true) {
      try {
        var resultParse = await http.get(Uri.parse(
            "http://filmixapp.cyou/api/v2/search?story=" +
                globals.title.replaceAll("?", "")));

        var response = await http.get(Uri.parse(
            "http://filmixapp.cyou/api/v2/post/" +
                json
                    .decode(utf8.decode(resultParse.bodyBytes))[0]['id']
                    .toString()));

        var decodedResponse = json
            .decode(utf8.decode(response.bodyBytes))['player_links']['movie'];

        for (int i = 0; i < decodedResponse.length; i++) {
          var namef = decodedResponse[i]['translation'];
          if (namef.contains("|")) {
            namef = namef.split("|")[0];
            namef = namef.replaceAll("[", "");
          }
          var flink = decodedResponse[i]['link'].split("[")[0] +
              (SpUtil.getBool("hq", defValue: true) == true ? "720" : "480") +
              ".mp4";
          result.add(namef + ";" + flink + ";Filmix");
        }
      } catch (e) {
        print(e);
      }
    }

    if (SpUtil.getBool("videoapi", defValue: true) == true) {
      try {
        var resultVideocdn = await http.get(Uri.parse(
            "https://videoapi.tv/api/short?api_token=7AgzavEhkBvKvZA0mpcXBdmLm69ZzLVY&imdb_id=" +
                globals.imdb));
        var decodedResult = await http.get(Uri.parse(json
            .decode(resultVideocdn.body)['data'][0]['iframe_src']
            .replaceAll("//", "http://")
            .replaceAll("http:", "")));

        var oneLanguage = "Оригинал";
        var oneUrl = decodedResult.body
            .split((SpUtil.getBool("hq", defValue: true) == true
                ? "[1080p]"
                : "[720p]"))[1]
            .split(" or")[0]
            .replaceAll("\\/", "/")
            .replaceAll("//", "https://");
        result.add(oneLanguage + ";" + oneUrl + ";VideoAPI");
      } catch (e) {}
    }

    // if (SpUtil.getBool("videocdn", defValue: true) == true) {
    //   try {
    //     var resultVideocdn = await http.get(Uri.parse(
    //         "https://videocdn.tv/api/short?api_token=HCOhBXC5UoVeK16hd8F947xID8fvrlck&kinopoisk_id=" +
    //             globals.id));
    //     var decodedResult = await http.get(Uri.parse(json
    //         .decode(resultVideocdn.body)['data'][0]['iframe_src']
    //         .replaceAll("//", "http://")));
    //
    //     var data = [];
    //
    //     if (decodedResult.body.contains('<div class="translations">')) {
    //       data.add(1);
    //
    //       for (int ii = 1; ii <= 10; ii++) {
    //         if (decodedResult.body
    //                 .split("value=")
    //                 .indexOf(decodedResult.body.split("value=").last) >
    //             ii) {
    //           data.add(ii + 1);
    //         }
    //       }
    //
    //       for (var i = 1; i <= data.length; i++) {
    //         var oneId = decodedResult.body.split("value=\"")[i].split('"')[0];
    //         var oneLanguage = decodedResult.body
    //             .split("value=")[i]
    //             .split(">")[1]
    //             .split("<")[0]
    //             .trim();
    //         var oneUrl = decodedResult.body
    //             .split("$oneId&quot;:&quot;")[1]
    //             .split((SpUtil.getBool("hq", defValue: true) == true
    //                 ? "[1080p]"
    //                 : "[720p]"))[1]
    //             .split("?")[0]
    //             .replaceAll("\\/", "/")
    //             .replaceAll("//", "https://");
    //         result.add(oneLanguage + ";" + oneUrl + ";VideoCDN");
    //       }
    //     } else {
    //       var oneLanguage = "Перевод";
    //       var oneUrl = decodedResult.body
    //           .split((SpUtil.getBool("hq", defValue: true) == true
    //               ? "[1080p]"
    //               : "[720p]"))[1]
    //           .split("?")[0]
    //           .replaceAll("\\/", "/")
    //           .replaceAll("//", "https://");
    //       result.add(oneLanguage + ";" + oneUrl + ";VideoCDN");
    //     }
    //   } catch (e) {}
    // }
    return result;
  }

  var favGlobals =
      SpUtil.getStringList("fav", defValue: [])?.contains(globals.id);

  void addToFav() {
    var a = SpUtil.getStringList("fav", defValue: []);
    if (SpUtil.getStringList("fav", defValue: [])?.contains(globals.id) !=
        true) {
      a?.add(globals.id);
    } else {
      a?.remove(globals.id);
    }
    SpUtil.putStringList("fav", a!);
    setState(() {
      favGlobals = a.contains(globals.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
            child: CupertinoPageScaffold(
                resizeToAvoidBottomInset: false,
                navigationBar: CupertinoNavigationBar(
                  middle: Text("Озвучки"),
                ),
                child: SafeArea(
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchNameLink(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData && snapshot.data.length != null) {
                        return ListView.builder(
                            padding: EdgeInsets.all(8),
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                child: GestureDetector(
                                  onTap: () {
                                    fromTranslationToWatch(
                                        snapshot.data[index].split(";")[1]);
                                  },
                                  child: CupertinoListTile(
                                    title: AutoSizeText(
                                      snapshot.data[index].split(";")[0],
                                      maxLines: 1,
                                      minFontSize: 8,
                                    ),
                                    subtitle: AutoSizeText(
                                        snapshot.data[index].split(";")[2],
                                        maxLines: 1),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height / 1.3,
                          child: Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                )),
          ),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class _GetReviewRouteState extends State<GetReviewRoute> {
  Future<List<dynamic>> fetchTrailers() async {
    var headers = {
      'accept': 'application/json',
      'X-API-KEY': '2bf3d1c4-c449-475f-864e-9590928d1a6e',
    };

    var url = Uri.parse('https://kinopoiskapiunofficial.tech/api/v2.2/films/' +
        globals.id +
        "/reviews?page=1&order=DATE_DESC");

    var getTrailer = await http.get(url, headers: headers);

    return json.decode(utf8.decode(getTrailer.bodyBytes))['items'];
  }

  String getTitle(dynamic user) {
    var a = "";
    if (user['author'] != null) {
      a += user['author'];
    }
    if (user['title'] != null) {
      a += "\n${user['title']}";
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar: CupertinoNavigationBar(
              middle: Text("Рецензии"),
            ),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: fetchTrailers(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != null) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  CupertinoListTile(
                                    title: AutoSizeText(
                                        getTitle(snapshot.data[index]),
                                        minFontSize: 10,
                                        style: TextStyle(
                                            color:
                                                CupertinoColors.inactiveGray)),
                                    subtitle: AutoSizeText(
                                      snapshot.data[index]['description'],
                                      minFontSize: 15,
                                      style: TextStyle(
                                          color: CupertinoColors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            Center(
                child: UnityBannerAd(
              placementId: globals.banner,
            )),
        ],
      ),
    );
  }
}

class _GetTrailerRouteState extends State<GetTrailerRoute> {
  void openTrailer(String link) async {
    await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }

  Future<List<dynamic>> fetchTrailers() async {
    var headers = {
      'accept': 'application/json',
      'X-API-KEY': '2bf3d1c4-c449-475f-864e-9590928d1a6e',
    };

    var url = Uri.parse('https://kinopoiskapiunofficial.tech/api/v2.2/films/' +
        globals.id +
        "/videos");

    var getTrailer = await http.get(url, headers: headers);

    return json.decode(utf8.decode(getTrailer.bodyBytes))['items'];
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar: CupertinoNavigationBar(
              middle: Text("Видео"),
            ),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: fetchTrailers(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != null) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              openTrailer(snapshot.data[index]['url']);
                            },
                            child: Container(
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CupertinoListTile(
                                    title: AutoSizeText(
                                      snapshot.data[index]['name'],
                                      maxLines: 1,
                                      minFontSize: 8,
                                    ),
                                    subtitle: AutoSizeText(
                                      snapshot.data[index]['site'],
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            Center(
                child: UnityBannerAd(
              placementId: globals.banner,
            )),
        ],
      ),
    );
  }
}

class _GetDubRouteState extends State<GetDubRoute> {
  void fromTranslationToWatch(String link) {
    globals.lanId = link;

    if (globals.adblockNeedKey != true) {
      globals.watchLink = globals.lanId;
      if (SpUtil.getStringList("historyy", defValue: [])
              ?.contains(globals.id) !=
          true) {
        var a = SpUtil.getStringList("historyy", defValue: []);
        a?.add(globals.id);
        SpUtil.putStringList("historyy", a!);
      }
      var eph = SpUtil.getStringList("w_" + globals.id, defValue: [])!;
      if (eph.contains(
              globals.season.toString() + "_" + globals.episode.toString()) ==
          false) {
        eph.add(globals.season.toString() + "_" + globals.episode.toString());
        SpUtil.putStringList("w_" + globals.id, eph);
      }
      if (Platform.isIOS) {
        if (SpUtil.getBool("safari", defValue: false) == false) {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => WatchRoute()),
          );
        } else {
          launchUrl(Uri.parse(globals.watchLink),
              mode: LaunchMode.externalApplication);
        }
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => OpenVideoRoute()),
        );
      }
    } else {
      showCupertinoSnackBar(
          context: context,
          message:
              'Просмотр с включенным AdBlock невозможен. Отключите блокировщик и перезапустите приложение');
    }
  }

  Future<List<dynamic>> fetchQuality() async {
    var finalResult = [];
    if (SpUtil.getBool("kodik", defValue: true) == true) {
      try {
        var searchKodik = await http.get(Uri.parse("https://kodikapi.com/search?token=694c5bae37d82efc1da0403421851f5d&strict=true&kinopoisk_id=${globals.id}&season=${globals.season}"));
        var seas = "?season=${globals.season}&episode=${globals.episode}";
        var kodikMovie = json.decode(utf8.decode(searchKodik.bodyBytes))['results'];
        for (var i = 0; i <= kodikMovie.length - 1; i++) {
          var translation = kodikMovie[i]['translation']['title'];
          var movieLink = await http.get(Uri.parse(kodikMovie[i]['link'].replaceAll("//", "http://") + seas));
          var epId = movieLink.body.split('<div class="serial-series-box">')[1].split('value="${globals.episode}"')[1].split('data-id="')[1].split('"')[0];
          var hash = movieLink.body.split('<div class="serial-series-box">')[1].split('value="${globals.episode}"')[1].split('data-hash="')[1].split('"')[0];
          var urlParams = json.decode(movieLink.body.split("urlParams = '")[1].split("';")[0]);
          var data = "d=${urlParams['d']}&d_sign=${urlParams['d_sign']}&pd=${urlParams['pd']}&pd_sign=${urlParams['pd_sign']}&ref=&ref_sign=${urlParams['ref_sign']}&bad_user=false&type=seria&hash=$hash&id=$epId";
          var headers = {
            'Host': 'kodik.cc',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:98.0) Gecko/20100101 Firefox/98.0',
            'referer': '${kodikMovie[i]['link'].replaceAll("//", "http://") + seas}',
            'content-type': 'application/x-www-form-urlencoded; charset=utf-8',
            'Accept-Encoding': 'gzip',
          };
          var url = Uri.parse('https://kodik.cc/gvi');
          var res = await http.post(url, headers: headers, body: data);
          print(res.body);
          var link = utf8.decode(base64.decode(json.decode(res.body)['links']['720'][0]['src'].toString().split('').reversed.join(''))).replaceAll("//", "http://");
          finalResult.add(translation + ";" + link + ";Kodik");
        }
      } catch(e) {
        print(e);
      }
    }

    if (SpUtil.getBool("anilibria", defValue: true) == true) {
      try {
        var titleHeaders = {
          'authority': 'dl-20220813-678.anilib.moe',
          'accept': '*/*',
          'accept-language': 'en-US,en;q=0.9',
          'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'origin': 'https://dl-20220813-678.anilib.moe',
          'referer': 'https://dl-20220813-678.anilib.moe/',
          'sec-fetch-dest': 'empty',
          'sec-fetch-mode': 'cors',
          'sec-fetch-site': 'same-origin',
          'user-agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/104.0.5112.81',
          'x-requested-with': 'XMLHttpRequest',
          'Accept-Encoding': 'gzip',
        };
        var titleData = "";
        if (globals.season != 1) {
          titleData = 'search=${globals.title}' +
              " " +
              globals.season.toString() +
              '&small=1';
        } else
          titleData = 'search=${globals.title}&small=1';
        var searchTitle = await http.post(
            Uri.parse("https://dl-20220813-678.anilib.moe/public/search.php"),
            headers: titleHeaders,
            body: titleData);
        var getTitlePage = await http.get(Uri.parse(
            "https://dl-20220813-678.anilib.moe/" +
                searchTitle.body
                    .split("<a href='")[1]
                    .split("'")[0]
                    .replaceAll("\\/", "/")));
        var episodeLink = getTitlePage.body
            .split("file:[{")[1]
            .split("s" + globals.episode.toString())[1]
            .split("[720p]")[1]
            .split(",")[0]
            .replaceAll("\\/", "/");
        finalResult.add("AniLibria" + ";" + episodeLink + ";AniLibria.TV");
      } catch (e) {}
    }

    if (SpUtil.getBool("rezka", defValue: true) == true) {
      try {
        var rezkaHeaders = {
          'X-App-Hdrezka-App': '1',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept-Encoding': 'gzip',
        };

        var searchRezka = await http.get(
            Uri.parse(
                "http://hdrzk.org/engine/ajax/search.php?q=" + globals.title),
            headers: rezkaHeaders);
        var rezkaMoviePage = await http.get(
            Uri.parse(searchRezka.body.split('<a href="')[1].split('"')[0]),
            headers: rezkaHeaders);

        var rezkaBody = rezkaMoviePage.body;
        var field = rezkaBody.split('<ul id="translators-list"')[1];
        var movieID = field.split('data-id="')[1].split('"')[0];
        for (int i = 0; i <= 10; i++) {
          try {
            var translatorName =
                field.split('<li title="')[i + 1].split('"')[0];
            var translatorID =
                field.split('data-translator_id="')[i + 1].split('"')[0];
            var data =
                'translator_id=$translatorID&id=$movieID&action=get_stream&season=${globals.season}&episode=${globals.episode}';
            var url = Uri.parse('http://hdrzk.org/ajax/get_cdn_series/');
            var movieRequest =
                await http.post(url, headers: rezkaHeaders, body: data);
            finalResult.add(translatorName +
                ";" +
                functions
                    .getRezkaStream(json.decode(movieRequest.body)['url']) +
                ";Rezka");
          } catch (e) {}
        }
      } catch (e) {}
    }
    if (SpUtil.getBool("iframe", defValue: true) == true) {
      try {
        var ireq = await http.get(Uri.parse(
            "https://videoframe.space/frameindex.php?kp=" + globals.id));
        var ibo = ireq.body;

        var headers = {
          'Accept': '*/*',
          'Accept-Language': 'en-US,en;q=0.9,ru;q=0.8,pl;q=0.7',
          'Connection': 'keep-alive',
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Origin': 'https://videoframe.space',
          'P-REF': 'https://videoframe.space',
          'Referer': 'https://videoframe.space/',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.91 Mobile Safari/537.36 Edg/103.0.5060.114',
          'X-REF': 'https://videoframe.space',
          'Accept-Encoding': 'gzip',
        };

        for (int i = 0; i < 10; i++) {
          if (ibo
                  .split("<a href='/movie/")
                  .indexOf(ibo.split("<a href='/movie/").last) >
              i) {
            var oneID = ibo.split("<a href='/movie/")[i + 1].split("/")[0];
            var oneLang = ibo.split("'><span title='")[i + 1].split("'")[0];
            var body =
                "token=$oneID&type=serial&season=${globals.season}&episode=${globals.episode}&mobile=true&id=2873&qt=" +
                    (SpUtil.getBool("hq", defValue: true) == true
                        ? "1080"
                        : "480");
            var url1 = await http.post(
                Uri.parse("https://videoframe.space/loadvideo"),
                headers: headers,
                body: body);
            var iURL = json.decode(url1.body)['src'].toString();
            finalResult.add(oneLang + ";" + iURL + ";VideoFrame");
          } else {
            break;
          }
        }
      } catch (e) {}
    }

    try {
      var result = await http.get(Uri.parse(
          "http://filmixapp.cyou/api/v2/search?story=" +
              globals.title.replaceAll("?", "")));

      var response = await http.get(Uri.parse(
          "http://filmixapp.cyou/api/v2/post/" +
              json.decode(utf8.decode(result.bodyBytes))[0]['id'].toString()));

      var decodedResponse =
          (jsonDecode(utf8.decode(response.bodyBytes))['player_links']
                  ['playlist'][globals.season.toString()])
              .toString();

      var list = [];

      // работает имя первого
      list.add(decodedResponse.toString().split("{")[1].split(':')[0]);

      for (int i = 0; i <= 10; i++) {
        if (decodedResponse
                .toString()
                .split('}},')
                .indexOf(decodedResponse.toString().split('}},').last) >
            i) {
          list.add(
              decodedResponse.toString().split('}},')[i + 1].split(':')[0]);
        }
      }

      for (int i = 0; i <= list.length; i++) {
        var link = "http://" +
            decodedResponse
                .toString()
                .split(list[i])[1]
                .split(globals.episode.toString() + ":")[1]
                .split("http://")[1]
                .split(",")[0]
                .replaceAll(
                    "%s",
                    (SpUtil.getBool("hq", defValue: true) == true
                        ? "720"
                        : "480"));
        finalResult.add(list[i] + ";" + link + ";Filmix");
      }
    } catch (e) {}

    try {
      var responseApi = await http.get(Uri.parse(
          "https://apicollaps.cc/list?token=eedefb541aeba871dcfc756e6b31c02e&kinopoisk_id=" +
              globals.id));
      var decodedResponseApi = await http.get(
          Uri.parse(json.decode(responseApi.body)['results'][0]['iframe_url']));
      var seasons = json.decode(
          decodedResponseApi.body.split("seasons:")[1].split("}]}]")[0] +
              "}]}]");
      for (int i = 0; i < seasons.length; i++) {
        if (seasons[i]['season'] == globals.season) {
          var lastEpisode = seasons[i]['episodes']
              [seasons[i]['episodes'].indexOf(seasons[i]['episodes'].last)];
          if (int.parse(lastEpisode['episode']) >= globals.episode) {
            var hls = seasons[i]['episodes'][globals.episode - 1]['hls'];
            var collname = seasons[i]['episodes'][globals.episode - 1]['audio']
                ['names'][0];
            finalResult.add(collname + " (+)" + ";" + hls + ";1080P (Collaps)");
            break;
          } else {
            break;
          }
        } else {
          continue;
        }
      }
    } catch (e) {}

    // if (SpUtil.getBool("videocdn", defValue: true) == true) {
    //   try {
    //     var result = await http.get(Uri.parse(
    //         "https://videocdn.tv/api/short?api_token=HCOhBXC5UoVeK16hd8F947xID8fvrlck&kinopoisk_id=" +
    //             globals.id));
    //     var decodedResult = await http.get(Uri.parse(json
    //         .decode(result.body)['data'][0]['iframe_src']
    //         .replaceAll("//", "http://")));
    //
    //     var splittedResult =
    //         decodedResult.body.split('id="files" value="')[1].split('"')[0];
    //
    //     if (decodedResult.body.contains("</select>")) {
    //       for (int i = 0; i <= 10; i++) {
    //         if (decodedResult.body
    //                 .split("value=")
    //                 .indexOf(decodedResult.body.split("value=").last) >
    //             i) {
    //           var oneId =
    //               decodedResult.body.split("value=\"")[i + 1].split('"')[0];
    //           var oneLanguage = decodedResult.body
    //               .split("value=")[i + 1]
    //               .split(">")[1]
    //               .split("<")[0]
    //               .trim();
    //           var url = splittedResult
    //               .split("quot;" + oneId)[1]
    //               .split(";" +
    //                   globals.season.toString() +
    //                   "_" +
    //                   globals.episode.toString())[1]
    //               .split((SpUtil.getBool("hq", defValue: true) == true
    //                   ? "[1080p]"
    //                   : "[720p]"))[1]
    //               .split("?")[0]
    //               .replaceAll("\\\\\\/", "/")
    //               .replaceAll("//", "https://");
    //           finalResult.add(oneLanguage + ";" + url + ";VideoCDN");
    //         }
    //       }
    //     } else {
    //       var url = splittedResult
    //           .split(";" +
    //               globals.season.toString() +
    //               "_" +
    //               globals.episode.toString())[1]
    //           .split((SpUtil.getBool("hq", defValue: true) == true
    //               ? "[1080p]"
    //               : "[720p]"))[1]
    //           .split("?")[0]
    //           .replaceAll("\\\\\\/", "/")
    //           .replaceAll("//", "https://");
    //       finalResult.add("Оригинал/Озвучка" + ";" + url + ";VideoCDN");
    //     }
    //   } catch (e) {}
    // }

    return finalResult;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar: CupertinoNavigationBar(
              middle: Text("Озвучки"),
            ),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: fetchQuality(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != null) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              fromTranslationToWatch(
                                  snapshot.data[index].split(";")[1]);
                            },
                            onLongPress: () {
                              showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                      title: Text("${globals.season} сезон ${globals.episode} серия\n${snapshot.data[index].split(";")[0]}"),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          child: const Text('Скопировать ссылку на видео/стрим'),
                                          onPressed: () async {
                                              Clipboard.setData(ClipboardData(
                                                  text: snapshot.data[index].split(";")[1]));
                                            Navigator.pop(context);
                                          },
                                        ),
                                        if (SpUtil.getStringList("watching", defValue: [])?.contains("${globals.id}_${globals.title}_${globals.season}_${globals.episode + 1}_${snapshot.data[index].split(";")[2]}_${snapshot.data[index].split(";")[0]}") != true)
                                          CupertinoDialogAction(
                                            child: const Text(
                                                'Ожидать следующий эпизод в этой озвучке'),
                                            onPressed: () {
                                              var wait = SpUtil.getStringList("watching", defValue: [])!;
                                              wait.add("${globals.id}_${globals.title}_${globals.season}_${globals.episode + 1}_${snapshot.data[index].split(";")[2]}_${snapshot.data[index].split(";")[0]}");
                                              SpUtil.putStringList("watching", wait);
                                              Navigator.pop(context);
                                            },
                                          ),
                                      ],
                                    ),
                              );
                            },
                            child: Container(
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CupertinoListTile(
                                    title: AutoSizeText(
                                      snapshot.data[index].split(";")[0],
                                      maxLines: 1,
                                    ),
                                    subtitle: AutoSizeText(
                                      snapshot.data[index].split(";")[2],
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class _GetEpisodeRouteState extends State<GetEpisodeRoute> with RouteAware {
  void fromEpisodeToTranslation(int episode) {
    globals.episode = episode;

    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => GetDubRoute()),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Helper.routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  void didPopNext() {
    setState(() {});
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: Column(children: [
          Expanded(
              child: CupertinoPageScaffold(
                  resizeToAvoidBottomInset: false,
                  navigationBar: CupertinoNavigationBar(
                    middle: Text(globals.title),
                  ),
                  child: ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: int.parse(globals.lastEpisode) + 1,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            fromEpisodeToTranslation(index + 1);
                          },
                          child: CupertinoListTile(
                            title: AutoSizeText(
                              "${index + 1} Серия",
                              maxLines: 1,
                              minFontSize: 20,
                            ),
                            subtitle: AutoSizeText(
                              globals.season.toString() +
                                  " сезон" +
                                  (SpUtil.getStringList("w_" + globals.id,
                                                  defValue: [])
                                              ?.contains(
                                                  globals.season.toString() +
                                                      "_" +
                                                      (index + 1).toString()) ==
                                          true
                                      ? " | просмотрено"
                                      : ""),
                            ),
                          ),
                        );
                      }))),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            ),
        ]));
  }
}

class _GetSeasonRouteState extends State<GetSeasonRoute> {
  void fromSeasonToEpisode(int season, int episode) {
    globals.season = season;
    globals.lastEpisode = episode.toString();

    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => GetEpisodeRoute()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar: CupertinoNavigationBar(
              middle: Text("Сезон"),
            ),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: functions.fetchSeasons(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != null) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              fromSeasonToEpisode(
                                  int.parse(
                                      (snapshot.data[index].split(":")[0])),
                                  int.parse(
                                      snapshot.data[index].split(":")[1]));
                            },
                            child: CupertinoListTile(
                              title: AutoSizeText(
                                '${snapshot.data[index].split(":")[0]} Cезон',
                                maxLines: 1,
                                minFontSize: 20,
                              ),
                              subtitle: AutoSizeText(
                                globals.title,
                              ),
                            ),
                          );
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            ),
        ],
      ),
    );
  }
}

class _PersonalRouteState extends State<PersonalRoute> {
  var apiUrl = globals.apiUrl;

  Future<List<dynamic>> fetchKinopoisk() async {
    var fav = SpUtil.getStringList("fav", defValue: []);

    var id = [];

    if (fav != null) {
      try {
        for (int i = 0; i <= fav.length - 1; i++) {
          var response = await http.get(
            Uri.parse("https://kinopoiskapiunofficial.tech/api/v2.2/films/" +
                fav[i] +
                "/similars"),
            headers: {'X-API-KEY': '2bf3d1c4-c449-475f-864e-9590928d1a6e'},
          );
          var decodedResponse = json.decode(response.body)['items'];
          for (int b = 0; b <= decodedResponse.length - 1; b++) {
            var ids = decodedResponse[b]['filmId'].toString();
            if (!SpUtil.getStringList("fav", defValue: [])!.contains(ids) &&
                !SpUtil.getStringList("historyy", defValue: [])!
                    .contains(ids)) {
              id.add(decodedResponse[b]['filmId'].toString());
            }
          }
        }
        globals.ids = id.join(",");
      } catch (e) {}
    }
    var result = await http.get(Uri.parse(
        "http://65.21.93.57:51058/getFilm?api_token=Q2srILqHm5IJUKcfiTh5TURHgy5WJkA9&id=" +
            globals.ids!));
    return json.decode(result.body)['results'];
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar:
                CupertinoNavigationBar(middle: Text(globals.podbName)),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: fetchKinopoisk(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != null) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap: () {
                                functions.pushFromMenu(
                                    functions.name(snapshot.data[index]),
                                    functions.filmId(snapshot.data[index]),
                                    snapshot.data[index]["is_serial"],
                                    snapshot.data[index]['imdb_id'] == false
                                        ? "0"
                                        : snapshot.data[index]['imdb_id'],
                                    context);
                              },
                              child: Container(
                                height: 230,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 0,
                                              left: 16,
                                              right: 0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              functions.filmPoster(
                                                  snapshot.data[index]),
                                              height: 200,
                                              width: 150,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, top: 8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 200,
                                            child: Column(children: [
                                              Align(
                                                child: AutoSizeText(functions
                                                    .name(snapshot.data[index])
                                                    .trim()),
                                                alignment: Alignment.topLeft,
                                              ),
                                              Align(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: AutoSizeText(
                                                    functions.listFilmInfo(
                                                        snapshot.data[index]),
                                                    style: TextStyle(
                                                        color: CupertinoColors
                                                            .inactiveGray),
                                                  ),
                                                ),
                                                alignment: Alignment.topLeft,
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class _PodbRouteState extends State<PodbRoute> {
  var apiUrl = globals.apiUrl;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar:
                CupertinoNavigationBar(middle: Text(globals.podbName)),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: functions.fetchResults(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != null) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap: () {
                                functions.pushFromMenu(
                                    functions.name(snapshot.data[index]),
                                    functions.filmId(snapshot.data[index]),
                                    snapshot.data[index]["is_serial"],
                                    snapshot.data[index]['imdb_id'] == false
                                        ? "0"
                                        : snapshot.data[index]['imdb_id'],
                                    context);
                              },
                              child: Container(
                                height: 230,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 0,
                                              left: 16,
                                              right: 0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              functions.filmPoster(
                                                  snapshot.data[index]),
                                              height: 200,
                                              width: 150,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, top: 8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 200,
                                            child: Column(children: [
                                              Align(
                                                child: AutoSizeText(functions
                                                    .name(snapshot.data[index])
                                                    .trim()),
                                                alignment: Alignment.topLeft,
                                              ),
                                              Align(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: AutoSizeText(
                                                    functions.listFilmInfo(
                                                        snapshot.data[index]),
                                                    style: TextStyle(
                                                        color: CupertinoColors
                                                            .inactiveGray),
                                                  ),
                                                ),
                                                alignment: Alignment.topLeft,
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [],
                                    )
                                  ],
                                ),
                              ));
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class _SearchResultRouteState extends State<SearchResultRoute> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar:
                CupertinoNavigationBar(middle: Text("Результаты поиска")),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: functions.fetchSearch(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != null) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap: () {
                                functions.pushFromMenu(
                                    functions.name(snapshot.data[index]),
                                    functions.filmId(snapshot.data[index]),
                                    snapshot.data[index]["is_serial"],
                                    snapshot.data[index]['imdb_id'] == false
                                        ? "0"
                                        : snapshot.data[index]['imdb_id'],
                                    context);
                              },
                              child: Container(
                                height: 230,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 0,
                                              left: 16,
                                              right: 0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              functions.filmPoster(
                                                  snapshot.data[index]),
                                              height: 200,
                                              width: 150,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, top: 8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 200,
                                            child: Column(children: [
                                              Align(
                                                child: AutoSizeText(functions
                                                    .name(snapshot.data[index])
                                                    .trim()),
                                                alignment: Alignment.topLeft,
                                              ),
                                              Align(
                                                child: AutoSizeText(
                                                  functions.listFilmInfo(
                                                      snapshot.data[index]),
                                                  style: TextStyle(
                                                      color: CupertinoColors
                                                          .inactiveGray),
                                                ),
                                                alignment: Alignment.topLeft,
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class _SettingsRouteState extends State<SettingsRoute> {
  List<Text> accents = [
    Text("Стандартный"),
    Text("Синий"),
    Text("Зеленый"),
    Text("Индиго"),
    Text("Оранжевый"),
    Text("Розовый"),
    Text("Фиолетовый"),
    Text("Красный"),
    Text("Желтый"),
  ];

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Настройки"),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (globals.isPremium)
                // SwitchCupertinoListTile(
                //   title: const Text('Белая тема'),
                //   subtitle:
                //   const Text("перезапустите приложение для применения"),
                //   value: SpUtil.getBool("light", defValue: false)!,
                //   onChanged: (bool value) {
                //     setState(() {
                //       SpUtil.putBool("light", value);
                //     });
                //   },
                // ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: 0, bottom: 0, left: 15, right: 0),
                      child: Text("Интерфейс",
                          style: TextStyle(
                              fontSize: 23.0,
                              color: CupertinoColors.inactiveGray))),
                ),
              GestureDetector(
                onTap: () {
                  if (globals.isPremium == true) {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext builder) {
                          return Container(
                              height: MediaQuery.of(context)
                                      .copyWith()
                                      .size
                                      .height *
                                  0.25,
                              color: CupertinoColors.black,
                              child: CupertinoPicker(
                                children: accents,
                                onSelectedItemChanged: (value) {
                                  SpUtil.putString(
                                      "accent_name", accents[value].data!);
                                  SpUtil.putInt("accent", value);
                                  setState(() {});
                                },
                                itemExtent: 25,
                                diameterRatio: 1,
                                useMagnifier: true,
                                magnification: 1.3,
                                looping: true,
                              ));
                        });
                  } else {
                    showCupertinoSnackBar(
                        context: context,
                        message: 'Доступно только для премиум пользователей');
                  }
                },
                child: CupertinoListTile(
                  title: Text("Акцент приложения"),
                  subtitle: Text(
                      SpUtil.getString("accent_name", defValue: "Стандартный")!,
                      style: TextStyle(
                          fontSize: 15.0, color: CupertinoColors.inactiveGray)),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 0, left: 15, right: 0),
                    child: Text("Поведение",
                        style: TextStyle(
                            fontSize: 23.0,
                            color: CupertinoColors.inactiveGray))),
              ),
              CupertinoFormRow(
                prefix: const Text('Проксирование обложек'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("ua", defValue: false)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("ua", value);
                    });
                  },
                ),
              ),
              if (Platform.isIOS)
                CupertinoFormRow(
                  prefix: const Text('Открытие видео в Safari'),
                  child: CupertinoSwitch(
                    activeColor: CupertinoColors.inactiveGray,
                    value: SpUtil.getBool("safari", defValue: false)!,
                    onChanged: (bool value) {
                      setState(() {
                        SpUtil.putBool("safari", value);
                      });
                    },
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding:
                        EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 0),
                    child: Text("Источники",
                        style: TextStyle(
                            fontSize: 23.0,
                            color: CupertinoColors.inactiveGray))),
              ),
              SizedBox(
                height: 10,
              ),
              CupertinoFormRow(
                prefix: const Text('Collaps'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("collaps", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("collaps", value);
                    });
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('Namba'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("nm2", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("nm2", value);
                    });
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('Filmix'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("filmix", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("filmix", value);
                    });
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('VideoFrame'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("iframe", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("iframe", value);
                    });
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('HDRezka'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("rezka", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("rezka", value);
                    });
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('VideoAPI'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("videoapi", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("videoapi", value);
                    });
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('AniLibria'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("anilibria", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("anilibria", value);
                    });
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('Kodik'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("kodik", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("kodik", value);
                    });
                  },
                ),
              ),
              CupertinoFormRow(
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("hdvb", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("hdvb", value);
                    });
                  },
                ),
                prefix: const Text('HDVB'),
              ),
              CupertinoFormRow(
                prefix: const Text('VideoCDN'),
                child: CupertinoSwitch(
                  activeColor: CupertinoColors.inactiveGray,
                  value: SpUtil.getBool("videocdn", defValue: true)!,
                  onChanged: (bool value) {
                    setState(() {
                      SpUtil.putBool("videocdn", value);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTVRouteState extends State<ProfileTVRoute> {
  void _launchUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void openHistory() {
    globals.ids = SpUtil.getStringList("historyy", defValue: [])?.join(",");
    globals.podbName = "История";
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => PodbRoute()));
  }

  void openFav() {
    globals.ids = SpUtil.getStringList("fav", defValue: [])?.join(",");
    globals.podbName = "Избранное";
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => PodbRoute()));
  }

  void openPersonal() {
    if (!globals.isPremium) {
      showCupertinoSnackBar(
          context: context,
          message: 'Доступно только для премиум пользователей');
    } else {
      globals.ids = SpUtil.getStringList("fav", defValue: [])?.join(",");
      globals.podbName = "Персональная подборка";
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => PersonalRoute()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Профиль"),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("KinoHome"),
                  subtitle: Text("Приятного просмотра!"),
                  onTap: () {},
                ),
              ),
              Container(
                height: 85,
                child: CupertinoListTile(
                  title: Text("Поддержать проект"),
                  subtitle: Text(
                      "При донате от 50 рублей выдается Premium. В комментарии укажите почту/ID!"),
                  onTap: () {
                    _launchUrl("https://new.donatepay.ru/@ctwoon");
                  },
                ),
              ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("Telegram канал"),
                  subtitle: Text("t.me/kinohome_xyz"),
                  onTap: () {
                    _launchUrl("https://t.me/kinohome_xyz");
                  },
                ),
              ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("Telegram чат"),
                  subtitle: Text("задайте любой интересующий вас вопрос!"),
                  onTap: () {
                    _launchUrl("https://t.me/kinohome_chat");
                  },
                ),
              ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("Настройки"),
                  subtitle: Text("обложки, источники..."),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => SettingsRoute()));
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: FirebaseAuth.instance.currentUser == null
                      ? Text("Аноним // нажмите, чтобы войти в профиль")
                      : Text((FirebaseAuth.instance.currentUser?.email)
                          .toString()),
                  subtitle: globals.isPremium
                      ? Text("Premium пользователь")
                      : Text("Премиум не подключен"),
                  onTap: () {
                    functions.signInwithGoogle(context);
                  },
                ),
              ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("История просмотра"),
                  subtitle: Text("Фильмов просмотрено: " +
                      (SpUtil.getStringList("historyy", defValue: [])?.length)
                          .toString()),
                  onTap: () {
                    openHistory();
                  },
                ),
              ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("Избранное"),
                  subtitle: Text("Фильмов добавлено: " +
                      (SpUtil.getStringList("fav", defValue: [])?.length)
                          .toString()),
                  onTap: () {
                    openFav();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRouteState extends State<ProfileRoute> {
  void _launchUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void openHistory() {
    globals.ids = SpUtil.getStringList("historyy", defValue: [])?.join(",");
    globals.podbName = "История";
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => PodbRoute()));
  }

  void openFav() {
    globals.ids = SpUtil.getStringList("fav", defValue: [])?.join(",");
    globals.podbName = "Избранное";
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => PodbRoute()));
  }

  void openPersonal() {
    if (!globals.isPremium) {
      showCupertinoSnackBar(
          context: context,
          message: 'Доступно только для премиум пользователей');
    } else {
      globals.ids = SpUtil.getStringList("fav", defValue: [])?.join(",");
      globals.podbName = "Персональная подборка";
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => PersonalRoute()));
    }
  }

  String getPass() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    var password = "";
    if (Platform.isIOS) {
      password = "\$" +
          base64.encode(utf8.encode(
              SpUtil.getString("iosid", defValue: "")! + "!" + formattedDate));
    } else {
      var firebaseEmail =
          FirebaseAuth.instance.currentUser?.email.toString().toLowerCase();
      if (firebaseEmail != null) {
        password = "#" +
            base64.encode(utf8.encode(firebaseEmail + "!" + formattedDate));
      }
    }

    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: CupertinoPageScaffold(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: GridView(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      shrinkWrap: true,
                      children: [
                        CupertinoButton(
                          child: Container(
                            height: 170,
                            width: 170,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    "https://kinopoiskapiunofficial.tech/images/posters/kp/387477.jpg"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              // make sure we apply clip it properly
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                                  child: Text(
                                    "KinoHome\nPremium",
                                    style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => ShowPremium()),
                            );
                          },
                        ),
                        CupertinoButton(
                          child: Container(
                            height: 170,
                            width: 170,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    "https://kinopoiskapiunofficial.tech/images/posters/kp/77443.jpg"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              // make sure we apply clip it properly
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                                  child: Text(
                                    "Ваш\nпрофиль",
                                    style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (Platform.isIOS) {
                              Clipboard.setData(ClipboardData(
                                  text: SpUtil.getString("iosid",
                                      defValue: "")!));
                              showCupertinoSnackBar(
                                  context: context, message: 'ID скопирован!');
                            } else {
                              var message = FirebaseAuth.instance.currentUser !=
                                      null
                                  ? "Ваша почта\n${FirebaseAuth.instance.currentUser?.email ?? ""}"
                                  : "Аноним. Ваш ID - ${await FlutterUdid.udid}";
                              showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                  title: Text(message),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: const Text('Скопировать почту/ID'),
                                      onPressed: () async {
                                        if (FirebaseAuth.instance.currentUser !=
                                            null) {
                                          Clipboard.setData(ClipboardData(
                                              text: FirebaseAuth.instance.currentUser?.email ?? ""));
                                        } else {
                                          Clipboard.setData(ClipboardData(
                                              text: "${await FlutterUdid.udid}"));
                                        }
                                        Navigator.pop(context);
                                      },
                                    ),
                                    if (FirebaseAuth.instance.currentUser ==
                                        null)
                                      CupertinoDialogAction(
                                        child: const Text(
                                            'Войти с помощью Google'),
                                        onPressed: () {
                                          functions.signInwithGoogle(context);
                                          Navigator.pop(context);
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 85,
                child: CupertinoListTile(
                  title: Text("Поддержать проект"),
                  subtitle: Text("Я буду благодарен!",
                      style: TextStyle(fontSize: 13.0)),
                  onTap: () {
                    _launchUrl("https://new.donatepay.ru/@ctwoon");
                  },
                ),
              ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("Telegram канал"),
                  subtitle:
                      Text("@kinohome_xyz", style: TextStyle(fontSize: 13.0)),
                  onTap: () {
                    _launchUrl("https://t.me/kinohome_xyz");
                  },
                ),
              ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("Telegram чат"),
                  subtitle: Text("задайте любой интересующий вас вопрос!",
                      style: TextStyle(fontSize: 13.0)),
                  onTap: () {
                    _launchUrl("https://t.me/kinohome_chat");
                  },
                ),
              ),
              if (globals.isPremium == true)
                Container(
                  height: 80,
                  child: CupertinoListTile(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: getPass()));
                      showCupertinoSnackBar(
                          context: context, message: 'Скопировано!');
                    },
                    title: Text("Пароль для Windows версии"),
                    subtitle: Text("нажмите, чтобы скопировать",
                        style: TextStyle(fontSize: 13.0)),
                  ),
                ),
              Container(
                height: 80,
                child: CupertinoListTile(
                  title: Text("Настройки"),
                  subtitle: Text("обложки, источники...",
                      style: TextStyle(fontSize: 13.0)),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => SettingsRoute()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileRoute extends StatefulWidget {
  ProfileRoute({Key? key}) : super(key: key);

  @override
  _ProfileRouteState createState() => _ProfileRouteState();
}

class ProfileTVRoute extends StatefulWidget {
  ProfileTVRoute({Key? key}) : super(key: key);

  @override
  _ProfileTVRouteState createState() => _ProfileTVRouteState();
}

class SettingsRoute extends StatefulWidget {
  SettingsRoute({Key? key}) : super(key: key);

  @override
  _SettingsRouteState createState() => _SettingsRouteState();
}

class SelectQuality extends StatefulWidget {
  SelectQuality({Key? key}) : super(key: key);

  @override
  _SelectQualityState createState() => _SelectQualityState();
}

class FilmInfo extends StatefulWidget {
  FilmInfo({Key? key}) : super(key: key);

  @override
  _FilmInfoState createState() => _FilmInfoState();
}

class _FilmInfoState extends State<FilmInfo> {
  var favGlobals =
      SpUtil.getStringList("fav", defValue: [])?.contains(globals.id);

  void addToFav() {
    var a = SpUtil.getStringList("fav", defValue: []);
    if (SpUtil.getStringList("fav", defValue: [])?.contains(globals.id) !=
        true) {
      a?.add(globals.id);
    } else {
      a?.remove(globals.id);
    }
    SpUtil.putStringList("fav", a!);
    setState(() {
      favGlobals = a.contains(globals.id);
    });
  }

  Future<List<dynamic>> fetchApiKey() async {
    var headers = {
      'accept': 'application/json',
      'X-API-KEY': '2bf3d1c4-c449-475f-864e-9590928d1a6e',
    };

    var url = Uri.parse('https://kinopoiskapiunofficial.tech/api/v2.2/films/' +
        globals.id +
        "/images?type=STILL&page=1");
    var resScreen = await http.get(url, headers: headers);
    var resInfo = await http.get(
        Uri.parse(
            'https://kinopoiskapiunofficial.tech/api/v2.2/films/' + globals.id),
        headers: headers);
    var actorsInfo = await http.get(
        Uri.parse('https://kinopoiskapiunofficial.tech/api/v1/staff?filmId=' +
            globals.id),
        headers: headers);
    var simInfo = await http.get(
        Uri.parse(
            'https://kinopoiskapiunofficial.tech/api/v2.2/films/${globals.id}/similars'),
        headers: headers);
    var simList = [];
    try {
      for (int i = 0;
          i <= json.decode(utf8.decode(simInfo.bodyBytes))['items'].length + 2;
          i++) {
        var sixreq = await http.get(Uri.parse(
            "http://65.21.93.57:51058/getFilm?api_token=Q2srILqHm5IJUKcfiTh5TURHgy5WJkA9&id=${json.decode(utf8.decode(simInfo.bodyBytes))['items'][i]['filmId']}"));
        var isSerial = json.decode(sixreq.body)['results'][0]['is_serial'];
        simList.add(isSerial);
      }
    } catch (e) {}
    var relReq = await http.get(
        Uri.parse(
            'https://kinopoiskapiunofficial.tech/api/v2.1/films/${globals.id}/sequels_and_prequels'),
        headers: headers);
    var relList = [];
    try {
      for (int i = 0;
          i < json.decode(utf8.decode(relReq.bodyBytes)).length;
          i++) {
        var sixreq = await http.get(Uri.parse(
            "http://65.21.93.57:51058/getFilm?api_token=Q2srILqHm5IJUKcfiTh5TURHgy5WJkA9&id=${json.decode(utf8.decode(relReq.bodyBytes))[i]['filmId']}"));
        var isSerial = json.decode(sixreq.body)['results'][0]['is_serial'];
        relList.add(isSerial);
      }
    } catch (e) {}
    var uaReq = await http.get(Uri.parse(
        "http://65.21.93.57:51058/getFilm?api_token=Q2srILqHm5IJUKcfiTh5TURHgy5WJkA9&id=" +
            globals.id));
    var jsonList = [
      json.decode(utf8.decode(resInfo.bodyBytes)),
      json.decode(utf8.decode(resScreen.bodyBytes)),
      json.decode(utf8.decode(actorsInfo.bodyBytes)),
      json.decode(utf8.decode(simInfo.bodyBytes)),
      simList
    ];
    jsonList.add(json.decode(uaReq.body)['results'][0]);
    jsonList.add(json.decode(utf8.decode(relReq.bodyBytes)));
    jsonList.add(relList);

    return jsonList;
  }

  String filmInfo(dynamic user) {
    String year = "";
    if (user['nameOriginal'] != null &&
        user['nameOriginal'] != user['nameRu']) {
      year += user['nameOriginal'] + "\n";
    }
    year += user['year'].toString() + ", ";
    year += user['countries'][0]['country'] + ", " + user['genres'][0]['genre'];
    if (user['serial'] == true) year += "\nСериал";
    return year;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.black.withOpacity(0.5),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => GetReviewRoute()));
                  },
                  child: Icon(
                    CupertinoIcons.bubble_left,
                    size: 28,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MyTorrentPage(title: ""),
                      ),
                    );
                  },
                  child: Icon(
                    CupertinoIcons.arrow_uturn_down_square,
                    size: 28,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () {
                    addToFav();
                  },
                  child: Icon(
                    favGlobals != true
                        ? CupertinoIcons.heart
                        : CupertinoIcons.heart_fill,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: FutureBuilder<List<dynamic>>(
                        future: fetchApiKey(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data.length != null) {
                            return Column(children: [
                              Container(
                                height: 300,
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    if (snapshot.data[1]['items'].length > 0 &&
                                        SpUtil.getBool("ua", defValue: false) ==
                                            false)
                                      Container(
                                        height: 300,
                                        width: double.maxFinite,
                                        child: ShaderMask(
                                          shaderCallback: (rect) {
                                            return LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              stops: [0, 0.9],
                                              colors: [
                                                CupertinoColors.black,
                                                CupertinoColors.black
                                                    .withOpacity(0.1)
                                              ],
                                            ).createShader(Rect.fromLTRB(
                                                0, 0, rect.width, rect.height));
                                          },
                                          blendMode: BlendMode.dstIn,
                                          child: ClipRRect(
                                            child: ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                  sigmaX: 2, sigmaY: 2),
                                              child: Image.network(
                                                snapshot.data[1]['items'][0]
                                                    ['previewUrl'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 0,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 0,
                                            bottom: 0,
                                            left: 15,
                                            right: 0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  SpUtil.getBool("ua",
                                                              defValue:
                                                                  false) ==
                                                          false
                                                      ? snapshot.data[0]
                                                          ['posterUrl']
                                                      : snapshot.data[5]
                                                              ['poster']
                                                          .replaceAll(
                                                              "https://int.cocine.me",
                                                              globals.baseUrl +
                                                                  "/"),
                                                  height: 200,
                                                  width: 150,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 2.0,
                                                  right: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  AutoSizeText(snapshot.data[0]
                                                              ['nameRu'] !=
                                                          null
                                                      ? snapshot.data[0]
                                                          ['nameRu']
                                                      : snapshot.data[0]
                                                          ['nameOriginal']),
                                                  AutoSizeText(
                                                      filmInfo(
                                                          snapshot.data[0]),
                                                      style: TextStyle(
                                                          color: CupertinoColors
                                                              .inactiveGray)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 30, right: 30, top: 11),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: snapshot.data[0][
                                                            'ratingKinopoisk'] !=
                                                        null
                                                    ? snapshot.data[0]
                                                            ['ratingKinopoisk']
                                                        .toString()
                                                    : "0",
                                                style: TextStyle(
                                                    color: snapshot.data[0][
                                                                'ratingKinopoisk'] !=
                                                            null
                                                        ? (snapshot.data[0][
                                                                    'ratingKinopoisk'] >=
                                                                6.0
                                                            ? Color(0xff04DE71)
                                                            : CupertinoColors
                                                                .activeOrange)
                                                        : CupertinoColors.white,
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Кинопоиск',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: snapshot.data[0]
                                                            ['ratingImdb'] !=
                                                        null
                                                    ? snapshot.data[0]
                                                            ['ratingImdb']
                                                        .toString()
                                                    : "0",
                                                style: TextStyle(
                                                    color: snapshot.data[0][
                                                                'ratingImdb'] !=
                                                            null
                                                        ? (snapshot.data[0][
                                                                    'ratingImdb'] >=
                                                                6.0
                                                            ? Color(0xff04DE71)
                                                            : CupertinoColors
                                                                .activeOrange)
                                                        : CupertinoColors.white,
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'IMDB',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: snapshot.data[0]
                                                            ['filmLength'] !=
                                                        null
                                                    ? snapshot.data[0]
                                                            ['filmLength']
                                                        .toString()
                                                    : "0",
                                                style: TextStyle(
                                                    color: light
                                                        ? CupertinoColors.black
                                                        : CupertinoColors.white,
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Минут',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: (snapshot.data[0][
                                                                'ratingAgeLimits'] !=
                                                            null
                                                        ? snapshot.data[0][
                                                                'ratingAgeLimits']
                                                            .split("age")[1]
                                                        : "0") +
                                                    "+",
                                                style: TextStyle(
                                                    color: light
                                                        ? CupertinoColors.black
                                                        : CupertinoColors.white,
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Ограничение',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 55,
                                padding: EdgeInsets.only(
                                    top: 8, left: 15, right: 15),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 60,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: CupertinoButton(
                                          color: CupertinoColors.white,
                                          padding: EdgeInsets.all(0),
                                          child: AutoSizeText('Смотреть'),
                                          onPressed: () {
                                            functions.openMovie(
                                                snapshot.data[0]['serial'],
                                                context);
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 60,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        child: CupertinoButton(
                                          color: CupertinoColors.white,
                                          padding: EdgeInsets.all(0),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        GetTrailerRoute()));
                                          },
                                          child: AutoSizeText('Трейлер'),
                                        ),
                                      ),
                                    ]),
                              ),
                              if (snapshot.data[0]['shortDescription'] != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 0, left: 15, right: 15),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, top: 8, bottom: 8),
                                      child: Text(
                                        snapshot.data[0]['shortDescription'],
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ),
                                ),
                              if (snapshot.data[0]['shortDescription'] != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0,
                                          bottom: 0,
                                          left: 15,
                                          right: 0),
                                      child: Text("Описание",
                                          style: TextStyle(
                                              fontSize: 23.0,
                                              color: CupertinoColors
                                                  .inactiveGray))),
                                ),
                              if (snapshot.data[0]['description'] != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 0, bottom: 0, left: 15, right: 15),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, top: 8, bottom: 8),
                                      child: Text(
                                        snapshot.data[0]['description'],
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ),
                                ),
                              if (snapshot.data[1]['total'] != 0 &&
                                  SpUtil.getBool("ua", defValue: false) ==
                                      false)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0,
                                          bottom: 0,
                                          left: 15,
                                          right: 0),
                                      child: Text("Кадры",
                                          style: TextStyle(
                                              fontSize: 23.0,
                                              color: CupertinoColors
                                                  .inactiveGray))),
                                ),
                              if (snapshot.data[1]['total'] != 0 &&
                                  SpUtil.getBool("ua", defValue: false) ==
                                      false)
                                Container(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.only(
                                        top: 8, left: 8, right: 8, bottom: 8),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data[1]['items'].length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                          child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Align(
                                          child: Container(
                                            height: 250,
                                            width: 300,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                  snapshot.data[1]['items']
                                                      [index]['previewUrl'],
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                      ));
                                    },
                                  ),
                                ),
                              if (snapshot.data[0]['description'] != null)
                                SizedBox(
                                  height: 5.0,
                                ),
                              if (snapshot.data[2] != 0 &&
                                  SpUtil.getBool("ua", defValue: false) ==
                                      false)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0,
                                          bottom: 0,
                                          left: 15,
                                          right: 0),
                                      child: Text("Актеры",
                                          style: TextStyle(
                                              fontSize: 23.0,
                                              color: CupertinoColors
                                                  .inactiveGray))),
                                ),
                              if (snapshot.data[2] != null &&
                                  SpUtil.getBool("ua", defValue: false) ==
                                      false)
                                Container(
                                  height: 250,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.only(
                                          top: 8, left: 8, right: 8, bottom: 0),
                                      itemCount: snapshot.data[2].length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                            onTap: () {
                                              globals.podbName = snapshot
                                                  .data[2][index]['nameRu'];
                                              globals.actorID = snapshot.data[2]
                                                      [index]['staffId']
                                                  .toString();
                                              Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                      builder: (context) =>
                                                          ActorRoute()));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: SizedBox(
                                                height: 50,
                                                width: 125,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          snapshot.data[2]
                                                                  [index]
                                                              ['posterUrl'],
                                                          height: 150,
                                                          width: 100,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15.0,
                                                      ),
                                                      AutoSizeText(
                                                        snapshot.data[2][index]
                                                            ['nameRu'],
                                                        style: TextStyle(
                                                            fontSize: 15.0),
                                                        maxLines: 2,
                                                      ),
                                                      AutoSizeText(
                                                        snapshot.data[2][index][
                                                                    'description'] ==
                                                                null
                                                            ? snapshot.data[2]
                                                                    [index][
                                                                'professionText']
                                                            : snapshot.data[2]
                                                                    [index]
                                                                ['description'],
                                                        style: TextStyle(
                                                            fontSize: 11.0,
                                                            color: !light
                                                                ? CupertinoColors
                                                                    .inactiveGray
                                                                : CupertinoColors
                                                                    .black),
                                                        minFontSize: 8.0,
                                                        maxLines: 3,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                      }),
                                ),
                              if (snapshot.data[6].isNotEmpty &&
                                  SpUtil.getBool("ua", defValue: false) ==
                                      false)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0,
                                          bottom: 0,
                                          left: 15,
                                          right: 0),
                                      child: Text("Связанные фильмы",
                                          style: TextStyle(
                                              fontSize: 23.0,
                                              color: CupertinoColors
                                                  .inactiveGray))),
                                ),
                              if (snapshot.data[6].isNotEmpty &&
                                  SpUtil.getBool("ua", defValue: false) ==
                                      false)
                                Container(
                                  height: 300,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.only(
                                          top: 8, left: 8, right: 8, bottom: 8),
                                      itemCount: snapshot.data[6].length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                            onTap: () {
                                              functions.pushFromMenu(
                                                  snapshot.data[6][index]
                                                      ['nameRu'],
                                                  snapshot.data[6][index]
                                                          ['filmId']
                                                      .toString(),
                                                  snapshot.data[7][index],
                                                  "",
                                                  context);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: SizedBox(
                                                height: 50,
                                                width: 125,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          snapshot.data[6]
                                                                  [index]
                                                              ['posterUrl'],
                                                          height: 150,
                                                          width: 100,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15.0,
                                                      ),
                                                      AutoSizeText(
                                                        snapshot.data[6][index]
                                                            ['nameRu'],
                                                        style: TextStyle(
                                                            fontSize: 15.0),
                                                        maxLines: 2,
                                                      ),
                                                      AutoSizeText(
                                                          snapshot.data[6][
                                                                          index]
                                                                      [
                                                                      'nameEn'] !=
                                                                  null
                                                              ? snapshot.data[6]
                                                                      [index]
                                                                  ['nameEn']
                                                              : "",
                                                          minFontSize: 8.0,
                                                          maxLines: 3,
                                                          style: TextStyle(
                                                            color: CupertinoColors
                                                                .inactiveGray,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                      }),
                                ),
                              if (snapshot.data[3]['total'] != 0 &&
                                  SpUtil.getBool("ua", defValue: false) ==
                                      false)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 0,
                                          bottom: 0,
                                          left: 15,
                                          right: 0),
                                      child: Text("Похожие фильмы",
                                          style: TextStyle(
                                              fontSize: 23.0,
                                              color: CupertinoColors
                                                  .inactiveGray))),
                                ),
                              if (snapshot.data[3]['total'] != 0 &&
                                  SpUtil.getBool("ua", defValue: false) ==
                                      false)
                                Container(
                                  height: 300,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.only(
                                          top: 8, left: 8, right: 8, bottom: 8),
                                      itemCount:
                                          snapshot.data[3]['items'].length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                            onTap: () {
                                              functions.pushFromMenu(
                                                  snapshot.data[3]['items']
                                                      [index]['nameRu'],
                                                  snapshot.data[3]['items']
                                                          [index]['filmId']
                                                      .toString(),
                                                  snapshot.data[4][index],
                                                  "",
                                                  context);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: SizedBox(
                                                height: 50,
                                                width: 125,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          snapshot.data[3]
                                                                      ['items']
                                                                  [index]
                                                              ['posterUrl'],
                                                          height: 150,
                                                          width: 100,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15.0,
                                                      ),
                                                      AutoSizeText(
                                                        snapshot.data[3]
                                                                ['items'][index]
                                                            ['nameRu'],
                                                        style: TextStyle(
                                                            fontSize: 15.0),
                                                        maxLines: 2,
                                                      ),
                                                      AutoSizeText(
                                                          snapshot.data[3]['items']
                                                                          [
                                                                          index]
                                                                      [
                                                                      'nameEn'] !=
                                                                  null
                                                              ? snapshot.data[3]
                                                                      ['items'][
                                                                  index]['nameEn']
                                                              : "",
                                                          minFontSize: 8.0,
                                                          maxLines: 3,
                                                          style: TextStyle(
                                                            color: CupertinoColors
                                                                .inactiveGray,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                      }),
                                ),
                            ]);
                          } else {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height / 1.3,
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          }
                        }),
                  ),
                ),
                if (globals.isPremium != true)
                  UnityBannerAd(
                    placementId: globals.banner,
                  )
              ],
            ),
          ),
        ));
  }
}

class _WatchRouteState extends State<WatchRoute> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(globals.title),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  child: WebViewX(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      initialContent:
                          "https://ctwoon.github.io/kinoplus/kodik.html?" +
                              globals.watchLink,
                      initialMediaPlaybackPolicy:
                          AutoMediaPlaybackPolicy.alwaysAllow),
                ),
              ),
            )
          ],
        ));
  }
}

class WatchRoute extends StatefulWidget {
  WatchRoute({Key? key}) : super(key: key);

  @override
  _WatchRouteState createState() => _WatchRouteState();
}

class _SearchRouteState extends State<SearchRoute> {
  TextEditingController txt = TextEditingController();

  void pushToCatalogue(int i, String gId, String podbname) {
    globals.podbName = podbname;
    globals.ids = gId;
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => PodbRoute()));
  }

  void start() {
    globals.title = txt.text;
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SearchResultRoute()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    autofocus: true,
                    suffixIcon: Icon(CupertinoIcons.settings),
                    suffixMode: OverlayVisibilityMode.always,
                    onSuffixTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => SearchSettingsRoute()));
                    },
                    controller: txt,
                    onSubmitted: (text) {
                      setState(() {});
                      start();
                    },
                    onChanged: (text) {
                      setState(() {});
                    },
                    placeholder: "Поиск фильмов и сериалов",
                  ),
                ),
                CupertinoButton(
                    onPressed: () {
                      txt.clear();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Text("Отмена"))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Container(
              height: 260,
              child: FutureBuilder<List<dynamic>>(
                future: functions.fetchPoster(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return GridView(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 3 / 2,
                        crossAxisCount: 2,
                      ),
                      shrinkWrap: true,
                      children: [
                        for (int i = 0; i < snapshot.data.length; i++)
                          CupertinoButton(
                            child: Container(
                              height: 100,
                              width: 210,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      snapshot.data[i].split(";")[2]),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                color: CupertinoColors.black.withOpacity(0.1),
                                child: ClipRRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 3.5, sigmaY: 3.5),
                                    child: Container(
                                      margin:
                                          EdgeInsets.fromLTRB(15, 15, 15, 15),
                                      child: AutoSizeText(
                                        snapshot.data[i].split(";")[0],
                                        maxLines: 3,
                                        style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () {
                              globals.ids = snapshot.data[i].split(";")[1];
                              globals.podbName = snapshot.data[i].split(";")[0];
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => PodbRoute()));
                            },
                          )
                      ],
                    );
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class SearchRoute extends StatefulWidget {
  SearchRoute({Key? key}) : super(key: key);

  @override
  _SearchRouteState createState() => _SearchRouteState();
}

class SearchResultRoute extends StatefulWidget {
  SearchResultRoute({Key? key}) : super(key: key);

  @override
  _SearchResultRouteState createState() => _SearchResultRouteState();
}

class PodbRoute extends StatefulWidget {
  PodbRoute({Key? key}) : super(key: key);

  @override
  _PodbRouteState createState() => _PodbRouteState();
}

class PersonalRoute extends StatefulWidget {
  PersonalRoute({Key? key}) : super(key: key);

  @override
  _PersonalRouteState createState() => _PersonalRouteState();
}

class GetMovieRoute extends StatefulWidget {
  GetMovieRoute({Key? key}) : super(key: key);

  @override
  _GetMovieRouteState createState() => _GetMovieRouteState();
}

class GetSeasonRoute extends StatefulWidget {
  GetSeasonRoute({Key? key}) : super(key: key);

  @override
  _GetSeasonRouteState createState() => _GetSeasonRouteState();
}

class GetEpisodeRoute extends StatefulWidget {
  GetEpisodeRoute({Key? key}) : super(key: key);

  @override
  _GetEpisodeRouteState createState() => _GetEpisodeRouteState();
}

class GetDubRoute extends StatefulWidget {
  GetDubRoute({Key? key}) : super(key: key);

  @override
  _GetDubRouteState createState() => _GetDubRouteState();
}

class GetTrailerRoute extends StatefulWidget {
  GetTrailerRoute({Key? key}) : super(key: key);

  @override
  _GetTrailerRouteState createState() => _GetTrailerRouteState();
}

class GetReviewRoute extends StatefulWidget {
  GetReviewRoute({Key? key}) : super(key: key);

  @override
  _GetReviewRouteState createState() => _GetReviewRouteState();
}

class PopularRoute extends StatefulWidget {
  _PopularRouteState createState() => _PopularRouteState();
}

class _PopularRouteState extends State<PopularRoute> {
  Future<List<dynamic>> fetchPopularResults() async {
    var result = await http.get(Uri.parse(globals.popularUrl));
    return json.decode(result.body)['results'];
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar: CupertinoNavigationBar(
              middle: Text("Популярное"),
            ),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: fetchPopularResults(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap: () {
                                functions.pushFromMenu(
                                    functions.name(snapshot.data[index]),
                                    functions.filmId(snapshot.data[index]),
                                    snapshot.data[index]["is_serial"],
                                    snapshot.data[index]['imdb_id'] == false
                                        ? "0"
                                        : snapshot.data[index]['imdb_id'],
                                    context);
                              },
                              child: Container(
                                height: 240,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 0,
                                              left: 16,
                                              right: 0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              functions.filmPoster(
                                                  snapshot.data[index]),
                                              height: 200,
                                              width: 150,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          height: 200,
                                          child: CupertinoListTile(
                                            title: Text(functions
                                                .name(snapshot.data[index])),
                                            subtitle: Text(
                                                functions.listFilmInfo(
                                                    snapshot.data[index])),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class TopRoute extends StatefulWidget {
  _TopRouteState createState() => _TopRouteState();
}

class _TopRouteState extends State<TopRoute> {
  Future<List<dynamic>> fetchTopResults() async {
    var result = await http.get(Uri.parse(globals.topUrl));
    return json.decode(result.body)['results'];
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar: CupertinoNavigationBar(
              middle: Text("Лучшее"),
            ),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: fetchTopResults(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap: () {
                                functions.pushFromMenu(
                                    functions.name(snapshot.data[index]),
                                    functions.filmId(snapshot.data[index]),
                                    snapshot.data[index]["is_serial"],
                                    snapshot.data[index]['imdb_id'] == false
                                        ? "0"
                                        : snapshot.data[index]['imdb_id'],
                                    context);
                              },
                              child: Container(
                                height: 230,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 0,
                                              left: 16,
                                              right: 0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              functions.filmPoster(
                                                  snapshot.data[index]),
                                              height: 200,
                                              width: 150,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          height: 200,
                                          child: CupertinoListTile(
                                            title: Text(functions
                                                .name(snapshot.data[index])),
                                            subtitle: Text(
                                                functions.listFilmInfo(
                                                    snapshot.data[index])),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class RandomRoute extends StatefulWidget {
  _RandomRouteState createState() => _RandomRouteState();
}

class _RandomRouteState extends State<RandomRoute> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar: CupertinoNavigationBar(
              middle: Text("Случайное"),
            ),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: functions.fetchApiResults(
                    "http://65.21.93.57:51058/getRandom?api_token=Q2srILqHm5IJUKcfiTh5TURHgy5WJkA9"),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap: () {
                                functions.pushFromMenu(
                                    functions.name(snapshot.data[index]),
                                    functions.filmId(snapshot.data[index]),
                                    snapshot.data[index]["is_serial"],
                                    snapshot.data[index]['imdb_id'] == false
                                        ? "0"
                                        : snapshot.data[index]['imdb_id'],
                                    context);
                              },
                              child: Container(
                                height: 230,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 0,
                                              left: 16,
                                              right: 0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              functions.filmPoster(
                                                  snapshot.data[index]),
                                              height: 200,
                                              width: 150,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, top: 8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 200,
                                            child: Column(children: [
                                              Align(
                                                child: AutoSizeText(functions
                                                    .name(snapshot.data[index])
                                                    .trim()),
                                                alignment: Alignment.topLeft,
                                              ),
                                              Align(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: AutoSizeText(
                                                    functions.listFilmInfo(
                                                        snapshot.data[index]),
                                                    style: TextStyle(
                                                        color: CupertinoColors
                                                            .inactiveGray),
                                                  ),
                                                ),
                                                alignment: Alignment.topLeft,
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class _SelectQualityState extends State<SelectQuality> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Качество"),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CupertinoListTile(
                onTap: () {
                  SpUtil.putBool("hq", true);
                  Navigator.pop(context);
                },
                title: Center(child: Text("HQ")),
                subtitle: Center(
                    child: Text(("720-1080P" +
                        (SpUtil.getBool("hq", defValue: true) == true
                            ? " (выбрано)"
                            : "")))),
              ),
              CupertinoListTile(
                onTap: () {
                  SpUtil.putBool("hq", false);
                  Navigator.pop(context);
                },
                title: Center(child: Text("LQ")),
                subtitle: Center(
                    child: Text(("360-480P" +
                        (SpUtil.getBool("hq", defValue: true) == false
                            ? " (выбрано)"
                            : "")))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showCupertinoSnackBar({
  required BuildContext context,
  required String message,
}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(message),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

class ShowPremium extends StatefulWidget {
  ShowPremium({Key? key}) : super(key: key);

  @override
  _ShowPremiumState createState() => _ShowPremiumState();
}

class _ShowPremiumState extends State<ShowPremium> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            CupertinoSliverNavigationBar(
              backgroundColor: CupertinoColors.black,
              largeTitle: Text('KinoHome Premium'),
            )
          ];
        },
        body: CupertinoPageScaffold(
          child: Column(children: [
            GridView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              shrinkWrap: true,
              children: [
                CupertinoButton(
                  child: Container(
                    height: 170,
                    width: 170,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://kinopoiskapiunofficial.tech/images/posters/kp/662359.jpg"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      color: CupertinoColors.black.withOpacity(0.1),
                      child: ClipRRect(
                        // make sure we apply clip it properly
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: AutoSizeText(
                              "Без\nрекламы",
                              minFontSize: 23,
                              style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {},
                ),
                CupertinoButton(
                  onPressed: () {
                    if (!globals.isPremium) {
                      showCupertinoSnackBar(
                          context: context,
                          message: 'Доступно только для премиум пользователей');
                    } else {
                      globals.ids =
                          SpUtil.getStringList("fav", defValue: [])?.join(",");
                      globals.podbName = "Персональная подборка";
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => PersonalRoute()));
                    }
                  },
                  child: Container(
                    height: 170,
                    width: 170,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://kinopoiskapiunofficial.tech/images/posters/kp/196707.jpg"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      color: CupertinoColors.black.withOpacity(0.1),
                      child: ClipRRect(
                        // make sure we apply clip it properly
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: AutoSizeText(
                              "Личная\nподборка",
                              maxLines: 2,
                              minFontSize: 23,
                              style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                CupertinoButton(
                  child: Container(
                    height: 170,
                    width: 170,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://kinopoiskapiunofficial.tech/images/posters/kp/453544.jpg"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      color: CupertinoColors.black.withOpacity(0.1),
                      child: ClipRRect(
                        // make sure we apply clip it properly
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: AutoSizeText(
                              "Настройка\nинтерфейса",
                              minFontSize: 22,
                              style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {},
                ),
                CupertinoButton(
                  child: Container(
                    height: 170,
                    width: 170,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://kinopoiskapiunofficial.tech/images/posters/kp/712639.jpg"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      color: CupertinoColors.black.withOpacity(0.1),
                      child: ClipRRect(
                        // make sure we apply clip it properly
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: AutoSizeText(
                              "Поддержка\nпроекта",
                              minFontSize: 23,
                              style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            Container(
              height: 80,
              child: CupertinoListTile(
                title: Text(globals.isPremium != true
                    ? "Премиум не подключен"
                    : "Премиум подключен"),
                subtitle: Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                        globals.isPremium != true
                            ? "Поддержите проект и пользуйтесь приложением на полную!\n\nнажмите, чтобы узнать всю информацию"
                            : "Приятного просмотра!",
                        style: TextStyle(fontSize: 11))),
                onTap: () {},
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class ActorRoute extends StatefulWidget {
  ActorRoute({Key? key}) : super(key: key);

  @override
  _ActorRouteState createState() => _ActorRouteState();
}

class _ActorRouteState extends State<ActorRoute> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar:
                CupertinoNavigationBar(middle: Text(globals.podbName)),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: functions.fetchActor(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != null) {
                    return ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap: () {
                                functions.pushFromMenu(
                                    functions.name(snapshot.data[index]),
                                    functions.filmId(snapshot.data[index]),
                                    snapshot.data[index]["is_serial"],
                                    snapshot.data[index]['imdb_id'] == false
                                        ? "0"
                                        : snapshot.data[index]['imdb_id'],
                                    context);
                              },
                              child: Container(
                                height: 230,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 8,
                                              bottom: 0,
                                              left: 16,
                                              right: 0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              functions.filmPoster(
                                                  snapshot.data[index]),
                                              height: 200,
                                              width: 150,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, top: 8.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 200,
                                            child: Column(children: [
                                              Align(
                                                child: AutoSizeText(functions
                                                    .name(snapshot.data[index])
                                                    .trim()),
                                                alignment: Alignment.topLeft,
                                              ),
                                              Align(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: AutoSizeText(
                                                    functions.listFilmInfo(
                                                        snapshot.data[index]),
                                                    style: TextStyle(
                                                        color: CupertinoColors
                                                            .inactiveGray),
                                                  ),
                                                ),
                                                alignment: Alignment.topLeft,
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [],
                                    )
                                  ],
                                ),
                              ));
                        });
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class SearchSettingsRoute extends StatefulWidget {
  SearchSettingsRoute({Key? key}) : super(key: key);

  @override
  _SearchSettingsRouteState createState() => _SearchSettingsRouteState();
}

class _SearchSettingsRouteState extends State<SearchSettingsRoute> {
  TextEditingController minRating = TextEditingController();
  TextEditingController maxRating = TextEditingController();
  TextEditingController minYear = TextEditingController();
  TextEditingController maxYear = TextEditingController();

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  List<Widget> getGenre(dynamic user) {
    List<Widget> l = [];
    l.add(Text("Не используется (0)"));
    for (int i = 0; i <= user.length - 1; i++) {
      l.add(Text(user[i]['genre'] + " (" + user[i]['id'].toString() + ")"));
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Column(
        children: [
          Expanded(
              child: CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar:
                CupertinoNavigationBar(middle: Text("Настройки поиска")),
            child: SafeArea(
                child: Container(
              child: FutureBuilder<List<dynamic>>(
                future: functions.fetchSearchInfo(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15.0),
                          child: CupertinoSearchTextField(
                            prefixIcon: Icon(CupertinoIcons.minus_circle),
                            autofocus: false,
                            controller: minRating,
                            onSubmitted: (text) {
                              setState(() {});
                            },
                            onChanged: (text) {
                              setState(() {});
                              if (isNumeric(text) == true) {
                                globals.minRating = text;
                              } else {
                                minRating.clear();
                              }
                            },
                            placeholder: globals.minRating == "0"
                                ? "Минимальный рейтинг (стандарт - 0)"
                                : "Текущее значение - ${globals.minRating}",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15.0),
                          child: CupertinoSearchTextField(
                            prefixIcon: Icon(CupertinoIcons.plus_circle),
                            autofocus: false,
                            controller: maxRating,
                            onChanged: (text) {
                              setState(() {});
                              if (isNumeric(text) == true) {
                                globals.maxRating = text;
                              } else {
                                maxRating.clear();
                              }
                            },
                            placeholder: globals.maxRating == "10"
                                ? "Максимальный рейтинг (стандарт - 10)"
                                : "Текущее значение - ${globals.maxRating}",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15.0),
                          child: CupertinoSearchTextField(
                            prefixIcon: Icon(CupertinoIcons.globe),
                            autofocus: false,
                            controller: minYear,
                            onChanged: (text) {
                              setState(() {});
                              if (isNumeric(text) == true) {
                                globals.minYear = text;
                              } else {
                                minYear.clear();
                              }
                            },
                            placeholder: globals.minYear == "1000"
                                ? "Минимальный год (стандарт - 1000)"
                                : "Текущее значение - ${globals.minYear}",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15.0),
                          child: CupertinoSearchTextField(
                            prefixIcon: Icon(CupertinoIcons.light_max),
                            autofocus: false,
                            controller: maxYear,
                            onChanged: (text) {
                              setState(() {});
                              if (isNumeric(text) == true) {
                                globals.maxYear = text;
                              } else {
                                maxYear.clear();
                              }
                            },
                            placeholder: globals.maxYear == "3000"
                                ? "Максимальный год (стандарт - 3000)"
                                : "Текущее значение - ${globals.maxYear}",
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext builder) {
                                  return Container(
                                      height: MediaQuery.of(context)
                                              .copyWith()
                                              .size
                                              .height *
                                          0.25,
                                      color: CupertinoColors.black,
                                      child: CupertinoPicker(
                                        children: getGenre(snapshot.data),
                                        onSelectedItemChanged: (value) {
                                          String text = value == 0
                                              ? "Не используется (0)"
                                              : snapshot.data[value - 1]
                                                  ['genre'];
                                          globals.selectedGenre = text;
                                          globals.selectedGenreID = value == 0
                                              ? "0"
                                              : snapshot.data[value - 1]['id']
                                                  .toString();
                                          setState(() {});
                                        },
                                        itemExtent: 25,
                                        diameterRatio: 1,
                                        useMagnifier: true,
                                        magnification: 1.3,
                                        looping: true,
                                      ));
                                });
                          },
                          child: CupertinoListTile(
                            title: Text("Жанр"),
                            subtitle: globals.selectedGenreID == "0"
                                ? Text("Не используется",
                                    style: TextStyle(fontSize: 15.0))
                                : Text(globals.selectedGenre,
                                    style: TextStyle(fontSize: 15.0)),
                          ),
                        ),
                        // CupertinoListTile(
                        //   title: Text("Страна"),
                        //   subtitle: globals.selectedCountry == ""
                        //       ? Text("Не используется",
                        //           style: TextStyle(fontSize: 15.0))
                        //       : Text(globals.selectedCountry,
                        //           style: TextStyle(fontSize: 15.0)),
                        // )
                      ],
                    );
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                },
              ),
            )),
          )),
          if (globals.isPremium != true)
            UnityBannerAd(
              placementId: globals.banner,
            )
        ],
      ),
    );
  }
}

class OpenVideoRoute extends StatefulWidget {
  OpenVideoRoute({Key? key}) : super(key: key);

  @override
  _OpenVideoRouteState createState() => _OpenVideoRouteState();
}

class _OpenVideoRouteState extends State<OpenVideoRoute> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Выберите плеер"),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              AndroidIntent intent = AndroidIntent(
                action: 'action_view',
                type: "video/*",
                data: Uri.parse(globals.watchLink).toString(),
              );
              intent.launch();
            },
            child: CupertinoListTile(
                title: Text("Сторонний плеер"),
                subtitle: Text("Установленный в вашем телефоне плеер")),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => PlayerRoute()));
            },
            child: CupertinoListTile(
                title: Text("Внутренний плеер"),
                subtitle: Text("Смотрите внутри приложения")),
          ),
          GestureDetector(
            onTap: () {
              launchUrl(
                  Uri.parse(
                      "http://kinohome.space/watch.html?${globals.watchLink}"),
                  mode: LaunchMode.inAppWebView);
            },
            child: CupertinoListTile(
                title: Text("WEB плеер"), subtitle: Text("Внутри приложения")),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: globals.watchLink));
              showCupertinoSnackBar(context: context, message: 'Скопировано!');
            },
            child: CupertinoListTile(
                title: Text("Скопировать ссылку"), subtitle: Text("На видео")),
          ),
        ],
      ),
    );
  }
}

class PlayerRoute extends StatefulWidget {
  PlayerRoute({Key? key}) : super(key: key);

  @override
  _PlayerRouteState createState() => _PlayerRouteState();
}

class _PlayerRouteState extends State<PlayerRoute> {
  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();

  var betterPlayerConfiguration = BetterPlayerConfiguration(
    autoPlay: true,
    looping: false,
    fullScreenByDefault: true,
    controlsConfiguration: BetterPlayerControlsConfiguration(
      playerTheme: BetterPlayerTheme.cupertino,
      enableAudioTracks: true,
      enableSubtitles: false,
      enableQualities: false,
    ),
    allowedScreenSleep: false,
  );

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, globals.watchLink);
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration,
        betterPlayerDataSource: betterPlayerDataSource);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(globals.title),
        ),
        child: BetterPlayer(
          controller: _betterPlayerController,
          key: _betterPlayerKey,
        ));
  }
}

class Helper {
  static final RouteObserver<ModalRoute> routeObserver = RouteObserver();
}

class WaitRoute extends StatefulWidget {
  WaitRoute({Key? key}) : super(key: key);

  @override
  _WaitRouteState createState() => _WaitRouteState();
}

class _WaitRouteState extends State<WaitRoute> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          middle: Text("Ожидание")
    ),
      child: Column(
        children: [
          Container(
            child: FutureBuilder<List<dynamic>>(
              future: functions.fetchResults(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data.length != null) {
                  return ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onTap: () {
                              functions.pushFromMenu(
                                  functions.name(snapshot.data[index]),
                                  functions.filmId(snapshot.data[index]),
                                  snapshot.data[index]["is_serial"],
                                  snapshot.data[index]['imdb_id'] == false
                                      ? "0"
                                      : snapshot.data[index]['imdb_id'],
                                  context);
                            },
                            child: Container(
                              height: 230,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 0,
                                            left: 16,
                                            right: 0),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                          child: Image.network(
                                            functions.filmPoster(
                                                snapshot.data[index]),
                                            height: 200,
                                            width: 150,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 8.0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.5,
                                          height: 200,
                                          child: Column(children: [
                                            Align(
                                              child: AutoSizeText(functions
                                                  .name(snapshot.data[index])
                                                  .trim()),
                                              alignment: Alignment.topLeft,
                                            ),
                                            Align(
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    top: 5.0),
                                                child: AutoSizeText(
                                                  functions.listFilmInfo(
                                                      snapshot.data[index]),
                                                  style: TextStyle(
                                                      color: CupertinoColors
                                                          .inactiveGray),
                                                ),
                                              ),
                                              alignment: Alignment.topLeft,
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [],
                                  )
                                ],
                              ),
                            ));
                      });
                } else {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 1.3,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

