import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mad_pay/mad_pay.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:puskazz_app/Utils/AnalyticsService/AnalyticsServcie.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:puskazz_app/Utils/EncriptionManager.dart';
import 'package:puskazz_app/Widgets/GrdientButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumPurchased extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PremiumPurchased> {
  int? expiresInDay;

  Offerings? offerings;

  @override
  void initState() {
    super.initState();
  }

  Future<String> getExpirationDate() async {
    final prefs = await SharedPreferences.getInstance();
    String? index = await prefs.getString('purchasedBundleIndex');
    index = EncriptionManager().decrypt(index!).toString();
    DateTime now = DateTime.now();
    DateTime unlockDate =
        DateTime.fromMillisecondsSinceEpoch(prefs.getInt('unlockDate') ?? -1);

    DateFormat formatter = DateFormat('yyyy. MM. dd.');
    String formatted = formatter.format(unlockDate);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      return Future.value(false);
    }, child: Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "\nTe ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GradientText(
                            "Prémium",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 48,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF70d6ff),
                                Color(0xFFff70a6),
                                Color(0xFFff9770),
                                Color.fromARGB(255, 255, 189, 22),
                              ],
                            ),
                          ),
                          Text(
                            "tag vagy",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 48),
                      FutureBuilder(
                          future: getExpirationDate(),
                          builder: (context, snapshot) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    DateFormat('yyyy. MM. dd.').format(
                                                DateTime.now()
                                                    .add(Duration(days: 3))) ==
                                            snapshot.data.toString()
                                        ? "A próbaidőszakod ekkor jár le:"
                                        : Platform.isIOS
                                            ? "A nem megújuló előfizetésed ekkor jár le:"
                                            : "A megújuló előfizetésed ekkor jár le:",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GradientText(
                                  snapshot.data.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 38,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF70d6ff),
                                      Color(0xFFff70a6),
                                      Color(0xFFff9770),
                                      Color.fromARGB(255, 255, 189, 22),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                      SizedBox(height: 64),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/premiumsShowcase", (route) => false,
                              arguments: {
                                "doNotShowFirst": true,
                              });
                          ;
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: MediaQuery.of(context).size.height / 12,
                          decoration: BoxDecoration(
                              color:
                                  Theme.of(context).scaffoldBackgroundColor ==
                                          Colors.black
                                      ? Color(0xFF343434)
                                      : Color(0xFfdedede),
                              borderRadius: BorderRadius.circular(50)),
                          child: Center(
                            child: GradientText(
                              "Mutasd a Prémium funkciókat",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF70d6ff),
                                    Color(0xFFff70a6),
                                    Color(0xFFff9770),
                                    Color.fromARGB(255, 255, 189, 22),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }
}
