import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sp_util/sp_util.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'globals.dart' as globals;
import 'ios.dart' as ios;

// google auth
Future<String?> signInwithGoogle(BuildContext context) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  if (FirebaseAuth.instance.currentUser == null) {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      throw e;
    }
  } else {
    var currentUser = FirebaseAuth.instance.currentUser?.email;
    if (currentUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(currentUser),
      ));
    }
  }
  return "";
}

// api film info
String name(dynamic user) {
  return user['ru_name'];
}

String filmInfo(List<dynamic> users, int index) {
  var user = users[index];
  String info =
      "${DateTime.fromMillisecondsSinceEpoch(int.parse(user['premiere'].toString().split(".")[0]) * 1000).year}\n";
  info += user['countries'][0] + ", " + user['genres'][0];
  if (user['genres'].length + 1 > 2) {
    info += ", " + user['genres'][1];
  }
  info += "\n${user['ratings']['kinopoisk']['rating']} KP";
  if (user['duration'] != 0) {
    info += ", ${user['duration'] / 60} мин";
  }
  return info;
}

String filmId(dynamic user) {
  return user['id'].toString();
}

String filmPoster(dynamic user) {
  if (SpUtil.getBool("ua", defValue: false) == false) {
    return "https://kinopoiskapiunofficial.tech/images/posters/kp/" +
        user['id'].toString() +
        ".jpg";
  } else {
    return user['poster']
        .replaceAll("https://int.cocine.me", globals.baseUrl + "/");
  }
}

void pushFromMenu(
    String title, String id, bool isSerial, String imdb, BuildContext context) {
  globals.title = title;
  globals.id = id;
  globals.imdb = imdb;

  if (globals.isPremium != true) {
    if (SpUtil.getInt("vid", defValue: 0) == 0) {
      SpUtil.putInt("vid", SpUtil.getInt("vid", defValue: 0)! + 1);
      UnityAds.load(
        placementId: globals.video,
        onComplete: (placementId) => {
          UnityAds.showVideoAd(
            placementId: placementId,
          )
        },
      );
    } else {
      if (SpUtil.getInt("vid", defValue: 0) == 20) {
        SpUtil.putInt("vid", 0);
      } else {
        SpUtil.putInt("vid", SpUtil.getInt("vid", defValue: 0)! + 1);
      }
    }
  }

  if (SpUtil.getInt("isTV", defValue: 0) != 2) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ios.FilmInfo()),
    );
  } else {
    openMovie(isSerial, context);
  }
}

void openMovie(bool isSerial, BuildContext context) {
  Navigator.push(
    context,
    CupertinoPageRoute(
        builder: (context) =>
            isSerial ? ios.GetSeasonRoute() : ios.GetMovieRoute()),
  );
}

String listFilmInfo(dynamic user) {
  String a = DateTime.fromMillisecondsSinceEpoch(
              int.parse(user['premiere'].toString().split(".")[0]) * 1000)
          .year
          .toString() +
      "\n";
  a += user['countries'][0] + ", " + user['genres'][0];
  if (user['genres'].length + 1 > 2) {
    a += ", " + user['genres'][1];
  }
  a += "\n" + user['ratings']['kinopoisk']['rating'].toString() + " KP";
  if (user['duration'] != 0) {
    a += ", " + (user['duration'] / 60).toString() + " мин";
  }
  if (user['is_serial'] == true &&
      SpUtil.getStringList("w_" + user["id"].toString(), defValue: [])!
          .isNotEmpty) {
    var last =
        SpUtil.getStringList("w_" + user["id"].toString(), defValue: [])!.last;
    a += "\n\nВы остановились:\n" +
        last.split("_")[0] +
        " сезон " +
        last.split("_")[1] +
        " серия";
  }
  return a;
}

List<dynamic> fileSizeInfo(
    var result, var url, var response, var decodedResponse) {
  for (var i = 0; i <= 15; i++) {
    try {
      if (decodedResponse.split("<td>").length > i) {
        var name = decodedResponse
            .split("<td>")[i + 1]
            .split("<a href=\"/torrent/")[1]
            .split(">")[1]
            .split("<")[0];
        var url1 =
            decodedResponse
                .split("<td>")[i + 1]
                .split("href=\"")[1]
                .split("\"")[0].replaceAll("http//", "http://");
        var size = decodedResponse
            .split("<td>")[i + 1]
            .split("<td align=\"right\">")[2]
            .split("&")[0];
        var fileSize = (double.parse(size) >= 100) ? "$size MB" : "$size GB";
        result.add(name + "`" + url1 + "`" + fileSize);
      }
    } catch (e) {}
  }
  return result;
}

void downloadTorrent(String title) {
  launchUrl(Uri.parse(title.toString()), mode: LaunchMode.externalApplication);
}

Future<List<dynamic>> fetchNPTR() async {
  var nResult = await http.get(Uri.parse(globals.newUrl));
  var pResult = await http.get(Uri.parse(globals.popularUrl));
  var tResult = await http.get(Uri.parse(globals.topUrl));
  var resultsList = [
    json.decode(nResult.body)['results'],
    json.decode(pResult.body)['results'],
    json.decode(tResult.body)['results'],
  ];
  return resultsList;
}

Future<List<dynamic>> fetchResults() async {
  var result = await http.get(Uri.parse(
      "http://65.21.93.57:51058/getFilm?api_token=Q2srILqHm5IJUKcfiTh5TURHgy5WJkA9&id=" +
          globals.ids!));
  return json.decode(result.body)['results'];
}

Future<List<dynamic>> fetchActor() async {
  try {
    var headers = {
      'accept': 'application/json',
      'X-API-KEY': '2bf3d1c4-c449-475f-864e-9590928d1a6e',
    };

    var getActor = await http.get(
        Uri.parse(
            "https://kinopoiskapiunofficial.tech/api/v1/staff/${globals.actorID}"),
        headers: headers);
    var actorRes = json.decode(getActor.body)['films'];
    var l = [];
    for (int i = 0; i <= actorRes.length - 1; i++) {
      l.add(actorRes[i]['filmId'].toString());
    }
    var result = await http.get(Uri.parse(
        "http://65.21.93.57:51058/getFilm?api_token=Q2srILqHm5IJUKcfiTh5TURHgy5WJkA9&id=" +
            l.join(",")));
    return json.decode(result.body)['results'];
  } catch (e) {
    print(e);
    return [];
  }
}

Future<List<dynamic>> fetchApiResults(String url) async {
  var result = await http.get(Uri.parse(url));
  return json.decode(result.body)['results'];
}

Future<List<dynamic>> fetchPoster() async {
  var l = [];
  var headers = {
    'Host': 'apir1.mzona.net',
    'user-agent': 'Zona/2.0.88 (samsung/SM-G965N/Android 5.1.1)',
    'Accept-Encoding': 'gzip',
  };

  var params = {
    'movie_source_types': '1,2,3,5,6,7,8,9,10,12',
  };
  var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');

  var url = Uri.parse('https://apir1.mzona.net/getRecommendations?$query');
  var res = await http.get(url, headers: headers);

  var resBody = json.decode(res.body)['collections'];
  for (int i = 0; i <= 3; i++) {
    var b = resBody[i];
    var ids = [];
    for (int intt = 0; intt < b['data'].length; intt++) {
      ids.add(b['data'][intt]['id']);
    }
    l.add(b['title'] +
        ";" +
        ids.join(",") +
        ";" +
        "https://kinopoiskapiunofficial.tech/images/posters/kp/" +
        ids[0].toString() +
        ".jpg");
  }
  return l;
}

String getRezkaStream(String replace) {
  var url = "";
  if (SpUtil.getBool("hq", defValue: true) == true) {
    url = replace
        .split("[")
        .last
        .split("or ")
        .last
        .replaceAll(",", "")
        .replaceAll("\\/", "/");
  } else {
    url = replace
        .split("[")[2]
        .split("or ")[1]
        .replaceAll(",", "")
        .replaceAll("\\/", "/");
  }
  return url;
}

Future<List<dynamic>> fetchSearchInfo() async {
  var headers = {
    'accept': 'application/json',
    'X-API-KEY': '2bf3d1c4-c449-475f-864e-9590928d1a6e',
  };

  var url =
      Uri.parse('https://kinopoiskapiunofficial.tech/api/v2.2/films/filters');
  var res = await http.get(url, headers: headers);
  return json.decode(utf8.decode(res.bodyBytes))['genres'];
}

Future<List<dynamic>> fetchSearch() async {
  try {
    var headers = {
      'accept': 'application/json',
      'X-API-KEY': '2bf3d1c4-c449-475f-864e-9590928d1a6e',
    };
    var reqString = 'https://kinopoiskapiunofficial.tech/api/v2.2/films?';
    if (globals.selectedGenreID != "0") {
      reqString += 'genres=${globals.selectedGenreID}&';
    }
    reqString +=
    'order=RATING&type=ALL&ratingFrom=${globals.minRating}&ratingTo=${globals
        .maxRating}&yearFrom=${globals.minYear}&yearTo=${globals
        .maxYear}';
    if (globals.title != "") {
      reqString += "&keyword=${globals.title}";
    }
    var req = await http.get(Uri.parse(reqString), headers: headers);
    var reqBody = json.decode(utf8.decode(req.bodyBytes))['items'];
    var l = [];
    for (int i = 0; i <= reqBody.length - 1; i++) {
      l.add(reqBody[i]['kinopoiskId'].toString());
    }
    var result = await http.get(Uri.parse(
        "http://65.21.93.57:51058/getFilm?api_token=Q2srILqHm5IJUKcfiTh5TURHgy5WJkA9&id=" +
            l.join(",")));
    return json.decode(result.body)['results'];
  } catch(e) {
    print(e);
    return [];
  }
}

Future<List<dynamic>> fetchSeasons() async {
  var headers = {
    'accept': 'application/json',
    'X-API-KEY': '2bf3d1c4-c449-475f-864e-9590928d1a6e',
  };
  var req = await http.get(Uri.parse("https://kinopoiskapiunofficial.tech/api/v2.2/films/${globals.id}/seasons"), headers: headers);
  var reqBody = json.decode(utf8.decode(req.bodyBytes))['items'];
  var l = [];
  for (int i = 0; i <= reqBody.length - 1; i++) {
    var seasonNumber = reqBody[i]['number'];
    if (seasonNumber > 0) {
      l.add("$seasonNumber:${reqBody[i]['episodes'].last['episodeNumber']}");
    }
  }
  return l;
}