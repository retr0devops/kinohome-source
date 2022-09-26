import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:http/http.dart' as http;
import 'package:sp_util/sp_util.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'firebase_options.dart';
import 'globals.dart' as globals;
import 'ios.dart' as ios;

int id = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isIOS && SpUtil.getString("iosid", defValue: "") == "") {
    await SpUtil.putString("iosid", await FlutterUdid.udid);
  }

  if (Platform.isAndroid) {
    if (FirebaseAuth.instance.currentUser == null) {
      var id = await FlutterUdid.udid;
      var premiumList = await http
          .get(Uri.parse("https://ctwoon.github.io/kinoplus/android.txt"));
      if (premiumList.body.contains(id)) {
        globals.isPremium = true;
      } else {
        globals.isPremium = false;
        initAds();
      }
    } else {
      String? userEmail =
          FirebaseAuth.instance.currentUser?.email.toString().toLowerCase();
      var premiumList = await http
          .get(Uri.parse("https://ctwoon.github.io/kinoplus/premium.txt"));
      if (!premiumList.body.contains(userEmail!)) {
        globals.isPremium = false;
        initAds();
      } else {
        globals.isPremium = true;
      }
    }
  } else if (Platform.isIOS) {
    var premiumListIOS =
        await http.get(Uri.parse("https://ctwoon.github.io/kinoplus/ios.txt"));
    if (!premiumListIOS.body
        .contains(SpUtil.getString("iosid", defValue: "")!)) {
      globals.isPremium = false;
      initAds();
    } else {
      globals.isPremium = true;
    }
  }

  if (globals.isPremium == false) {
    try {
      await http.get(Uri.parse(
          "https://cdn.jsdelivr.net/npm/yandex-metrica-watch/tag.js"));
    } catch (e) {
      globals.adblockNeedKey = true;
    }
  }
  runApp(ios.MyApp());
}

void initAds() {
  if (Platform.isIOS) {
    id = 4710204;
    globals.banner = "Banner_iOS";
    globals.video = "Interstitial_iOS";
  } else {
    id = 4710205;
    globals.banner = "Banner_Android";
    globals.video = "Interstitial_Android";
  }
  UnityAds.init(
    gameId: id.toString(),
    testMode: false,
  );
}
