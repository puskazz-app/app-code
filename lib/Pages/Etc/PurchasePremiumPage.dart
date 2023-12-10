import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mad_pay/mad_pay.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:puskazz_app/Utils/AnalyticsService/AnalyticsServcie.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:puskazz_app/Utils/EncriptionManager.dart';
import 'package:puskazz_app/Widgets/GrdientButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _isPurchasing = false;
  bool _isPurchased = false;
  List prices = [999.0, 2490.0, 4490.0];
  int? expiresInDay;
  List<String> paymentIntentData = [];
  final MadPay pay = MadPay();
  String merchantId = "BCR2DN4T23VK7NJC";
  String gatewayName = "mpgs";
  String gatewayMerchantId = "BCR2DN4T23VK7NJC";
  String merchantName = "Puskázz App";

  Offerings? offerings;

  @override
  void initState() {
    super.initState();
    initPayment();
  }

  Future<bool> isThereTrial() async {
    bool isThereTrial = false;
    final url = Uri.parse(
        'https://szeligbalazs.github.io/shotgunapp-messages/trial.html');
    final response = await http.get(url);
    dom.Document document = dom.Document.html(response.body);

    final text =
        document.querySelectorAll('p').map((e) => e.innerHtml.trim()).toList();
    for (var i = 0; i < text.length; i++) {
      if (text[i].contains("yes")) {
        isThereTrial = true;
      } else {
        isThereTrial = false;
      }
    }

    return isThereTrial;
  }

  void initPayment() async {
    if (Platform.isAndroid) {
      try {
        offerings = await Purchases.getOfferings();
        if (offerings!.current != null) {
          offerings!.current!.availablePackages.forEach((element) {
            setState(() {
              prices.add(element.storeProduct.priceString);
            });
          });
        } else {
          debugPrint("Offerings is null");
        }
      } on PlatformException catch (e) {
        debugPrint("Error: $e");
        debugPrint("Offerings has errors");
      }
    } else if (Platform.isIOS) {
      await pay.checkPayments();
      await pay.setEnvironment(environment: Environment.production);
    }
  }

  DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  DateTime addDays(DateTime date, int days) {
    return DateTime(date.year, date.month, date.day + days);
  }

  void androidPurchase(int index) async {
    try {
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(
          offerings!.current!.availablePackages[index]);
      String entitlementId = "";
      if (index == 0) {
        entitlementId = "Premium_1";
      } else if (index == 1) {
        entitlementId = "Premium_3";
      } else if (index == 2) {
        entitlementId = "Premium_6";
      }
      if (purchaserInfo.entitlements.all[entitlementId]?.isActive == true) {
        setState(() {
          _isPurchased = true;
        });
        print("Purchase successful");

        int? monthsToUnlock;
        if (index == 0) {
          monthsToUnlock = 1;
        } else if (index == 1) {
          monthsToUnlock = 3;
        } else if (index == 2) {
          monthsToUnlock = 6;
        }

        DateTime now = DateTime.now();
        DateTime unlockDate;
        unlockDate = addMonths(now, monthsToUnlock!);
        final prefs = await SharedPreferences.getInstance();

        EncriptionManager encriptionManager = EncriptionManager();
        String? encryptedIndex =
            await encriptionManager.encrypt(index.toString());

        prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
        prefs.setString("purchasedBundleIndex", encryptedIndex.toString());

        Navigator.pushNamed(context, '/thanks');
        AnalyticsService().logEvent("unlocked_premium_by_purchase");
      }
    } on PlatformException catch (e) {
      debugPrint("Error: $e");
      debugPrint("Purchase has errors");
      if (e.toString().contains("no_active_entitlements")) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/errorPurchase', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, '/cancelledPurchase', (route) => false);
      }
    }
  }

  void iosPurchase(int index) async {
    if (index == 0) {
      await pay
          .processingPayment(PaymentRequest(
        google: GoogleParameters(
          gatewayName: gatewayName,
          gatewayMerchantId: gatewayMerchantId,
          merchantId: merchantId,
          merchantName: merchantName,
        ),
        apple: AppleParameters(
          merchantIdentifier: 'merchant.hu.szeligbalazs.puskazzapp',
        ),
        currencyCode: "HUF",
        countryCode: "HU",
        paymentItems: <PaymentItem>[
          PaymentItem(name: 'Puskázz Prémium 1 hónap', price: prices[0]),
        ],
      ))
          .then((value) async {
        print("value: " + value!.rawData.toString());
        if (value.rawData!.isNotEmpty) {
          var data;
          int? monthsToUnlock;
          if (index == 0) {
            monthsToUnlock = 1;
          } else if (index == 1) {
            monthsToUnlock = 3;
          } else if (index == 2) {
            monthsToUnlock = 6;
          }

          DateTime now = DateTime.now();
          DateTime unlockDate;
          unlockDate = addMonths(now, monthsToUnlock!);
          final prefs = await SharedPreferences.getInstance();

          EncriptionManager encriptionManager = EncriptionManager();
          String? encryptedIndex =
              await encriptionManager.encrypt(index.toString());

          prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
          prefs.setString("purchasedBundleIndex", encryptedIndex.toString());

          Navigator.pushNamed(context, '/thanks');
          AnalyticsService().logEvent("unlocked_premium_by_purchase");
        }
      }).catchError((e) {
        debugPrint("alma:" + e);
      });
    } else if (index == 1) {
      await pay
          .processingPayment(PaymentRequest(
        google: GoogleParameters(
          gatewayName: gatewayName,
          gatewayMerchantId: gatewayMerchantId,
          merchantId: merchantId,
          merchantName: merchantName,
        ),
        apple: AppleParameters(
          merchantIdentifier: 'merchant.hu.szeligbalazs.puskazzapp',
        ),
        currencyCode: "HUF",
        countryCode: "HU",
        paymentItems: <PaymentItem>[
          PaymentItem(name: 'Puskázz Prémium 3 hónap', price: prices[1]),
        ],
      ))
          .then((value) async {
        print("value: " + value!.rawData.toString());
        if (value.rawData!.isNotEmpty) {
          var data;
          int monthsToUnlock = 0;
          if (index == 0) {
            monthsToUnlock = 1;
          } else if (index == 1) {
            monthsToUnlock = 3;
          } else if (index == 2) {
            monthsToUnlock = 6;
          }

          DateTime now = DateTime.now();
          DateTime unlockDate;

          final prefs = await SharedPreferences.getInstance();
          unlockDate = addMonths(now, monthsToUnlock);
          EncriptionManager encriptionManager = EncriptionManager();
          String? encryptedIndex =
              await encriptionManager.encrypt(index.toString());

          prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
          prefs.setString("purchasedBundleIndex", encryptedIndex.toString());
          prefs.setBool("isCameraInitailized", true);

          Navigator.pushNamed(context, '/thanks');
          AnalyticsService().logEvent("unlocked_premium_by_purchase");
        }
      }).catchError((e) {
        debugPrint(e);
      });
    } else if (index == 2) {
      await pay
          .processingPayment(PaymentRequest(
        google: GoogleParameters(
          gatewayName: gatewayName,
          gatewayMerchantId: gatewayMerchantId,
          merchantId: merchantId,
          merchantName: merchantName,
        ),
        apple: AppleParameters(
          merchantIdentifier: 'merchant.hu.szeligbalazs.puskazzapp',
        ),
        currencyCode: "HUF",
        countryCode: "HU",
        paymentItems: <PaymentItem>[
          PaymentItem(name: 'Puskázz Prémium 6 hónap', price: prices[2]),
        ],
      ))
          .then((value) async {
        print("value: " + value!.rawData.toString());
        if (value.rawData!.isNotEmpty) {
          var data;
          int monthsToUnlock = 0;
          if (index == 0) {
            monthsToUnlock = 1;
          } else if (index == 1) {
            monthsToUnlock = 3;
          } else if (index == 2) {
            monthsToUnlock = 6;
          }

          DateTime now = DateTime.now();
          DateTime unlockDate;

          final prefs = await SharedPreferences.getInstance();
          unlockDate = addMonths(now, monthsToUnlock);
          EncriptionManager encriptionManager = EncriptionManager();
          String? encryptedIndex =
              await encriptionManager.encrypt(index.toString());

          prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
          prefs.setString("purchasedBundleIndex", encryptedIndex.toString());
          prefs.setBool("isCameraInitailized", true);

          Navigator.pushNamed(context, '/thanks');
          AnalyticsService().logEvent("unlocked_premium_by_purchase");
        }
      }).catchError((e) {
        debugPrint(e);
      });
    }
  }

  Future<void> _restorePurchase() async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      CustomerInfo purchaserInfo = await Purchases.restorePurchases();
      String entitlementId = "";
      for (var index = 0;
          index < purchaserInfo.entitlements.all.length;
          index++) {
        if (Platform.isAndroid) {
          if (index == 0) {
            entitlementId = "Premium_1";
            if (purchaserInfo.entitlements.all[entitlementId]?.isActive ==
                true) {
              setState(() {
                _isPurchased = true;
              });
              print("Purchase successful");

              int monthsToUnlock = 0;
              if (index == 0) {
                monthsToUnlock = 1;
              } else if (index == 1) {
                monthsToUnlock = 3;
              } else if (index == 2) {
                monthsToUnlock = 6;
              }

              DateTime now = DateTime.now();
              DateTime unlockDate;

              final prefs = await SharedPreferences.getInstance();
              unlockDate = addMonths(now, monthsToUnlock);
              prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
              prefs.setString("purchasedBundleIndex", index.toString());

              Navigator.pushNamedAndRemoveUntil(
                  context, '/thanks', (route) => false);
            } else {
              print("Purchase not successful");
            }
          } else if (index == 1) {
            entitlementId = "Premium_3";
            if (purchaserInfo.entitlements.all[entitlementId]?.isActive ==
                true) {
              setState(() {
                _isPurchased = true;
              });
              print("Purchase successful");

              int monthsToUnlock = 0;
              if (index == 0) {
                monthsToUnlock = 1;
              } else if (index == 1) {
                monthsToUnlock = 3;
              } else if (index == 2) {
                monthsToUnlock = 6;
              }

              DateTime now = DateTime.now();
              DateTime unlockDate;

              final prefs = await SharedPreferences.getInstance();
              unlockDate = addMonths(now, monthsToUnlock);
              prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
              prefs.setString("purchasedBundleIndex", index.toString());

              Navigator.pushNamedAndRemoveUntil(
                  context, '/thanks', (route) => false);
            } else {
              print("Purchase not successful");
            }
          } else if (index == 2) {
            entitlementId = "Premium_6";
            if (purchaserInfo.entitlements.all[entitlementId]?.isActive ==
                true) {
              setState(() {
                _isPurchased = true;
              });
              print("Purchase successful");

              int monthsToUnlock = 0;
              if (index == 0) {
                monthsToUnlock = 1;
              } else if (index == 1) {
                monthsToUnlock = 3;
              } else if (index == 2) {
                monthsToUnlock = 6;
              }

              DateTime now = DateTime.now();
              DateTime unlockDate;

              final prefs = await SharedPreferences.getInstance();
              unlockDate = addMonths(now, monthsToUnlock);
              prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
              prefs.setString("purchasedBundleIndex", index.toString());

              Navigator.pushNamedAndRemoveUntil(
                  context, '/thanks', (route) => false);
            } else {
              print("Purchase not successful");
            }
          }
        } else {
          if (index == 0) {
            entitlementId = "puskazz_premium_1";
            if (purchaserInfo.entitlements.all[entitlementId]?.isActive ==
                true) {
              setState(() {
                _isPurchased = true;
              });
              print("Purchase successful");

              int monthsToUnlock = 0;
              if (index == 0) {
                monthsToUnlock = 1;
              } else if (index == 1) {
                monthsToUnlock = 3;
              } else if (index == 2) {
                monthsToUnlock = 6;
              }

              DateTime now = DateTime.now();
              DateTime unlockDate;

              final prefs = await SharedPreferences.getInstance();
              unlockDate = addMonths(now, monthsToUnlock);
              prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
              prefs.setString("purchasedBundleIndex", index.toString());

              Navigator.pushNamedAndRemoveUntil(
                  context, '/thanks', (route) => false);
            } else {
              print("Purchase not successful");
            }
          } else if (index == 1) {
            entitlementId = "puskazz_premium_3m";
            if (purchaserInfo.entitlements.all[entitlementId]?.isActive ==
                true) {
              setState(() {
                _isPurchased = true;
              });
              print("Purchase successful");

              int monthsToUnlock = 0;
              if (index == 0) {
                monthsToUnlock = 1;
              } else if (index == 1) {
                monthsToUnlock = 3;
              } else if (index == 2) {
                monthsToUnlock = 6;
              }

              DateTime now = DateTime.now();
              DateTime unlockDate;

              final prefs = await SharedPreferences.getInstance();
              unlockDate = addMonths(now, monthsToUnlock);
              prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
              prefs.setString("purchasedBundleIndex", index.toString());

              Navigator.pushNamedAndRemoveUntil(
                  context, '/thanks', (route) => false);
            } else {
              print("Purchase not successful");
            }
          } else if (index == 2) {
            entitlementId = "puskazz_premium_6_months";
            if (purchaserInfo.entitlements.all[entitlementId]?.isActive ==
                true) {
              setState(() {
                _isPurchased = true;
              });
              print("Purchase successful");

              int monthsToUnlock = 0;
              if (index == 0) {
                monthsToUnlock = 1;
              } else if (index == 1) {
                monthsToUnlock = 3;
              } else if (index == 2) {
                monthsToUnlock = 6;
              }

              DateTime now = DateTime.now();
              DateTime unlockDate;

              final prefs = await SharedPreferences.getInstance();
              unlockDate = addMonths(now, monthsToUnlock);
              prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
              prefs.setString("purchasedBundleIndex", index.toString());

              Navigator.pushNamedAndRemoveUntil(
                  context, '/thanks', (route) => false);
            } else {
              print("Purchase not successful");
            }
          }
        }
      }
    } catch (e) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/errorPurchase', (route) => false);
    } finally {
      setState(() {
        _isPurchasing = false;
      });
    }
  }

  void _buyProduct(int index) async {
    if (index != 5) {
      if (Platform.isAndroid) {
        androidPurchase(index);
      } else if (Platform.isIOS) {
        iosPurchase(index);
      }
    } else {
      DateTime now = DateTime.now();
      DateTime unlockDate;

      final prefs = await SharedPreferences.getInstance();
      unlockDate = addDays(now, 3);
      prefs.setInt("unlockDate", unlockDate.millisecondsSinceEpoch);
      prefs.setString("purchasedBundleIndex", index.toString());
      AnalyticsService().logEvent("unlocked_premium_by_trial");

      Navigator.pushNamedAndRemoveUntil(context, '/thanks', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
          return Future.value(false);
        },
        child: _isPurchasing == false
            ? Scaffold(
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
                                      "\nVálts",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 48,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
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
                                          "ra!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 48,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(height: 48),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    FutureBuilder(
                                        future: isThereTrial(),
                                        builder: (context, snapshot) {
                                          return Visibility(
                                            visible: snapshot.data == true
                                                ? true
                                                : false,
                                            child: InkWell(
                                              onTap: () {
                                                _buyProduct(5);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(context)
                                                                      .scaffoldBackgroundColor ==
                                                                  Colors.black
                                                              ? Color(
                                                                  0xFF343434)
                                                              : Color(
                                                                  0xFfdedede),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25)),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            child: GradientText(
                                                              "3 nap",
                                                              style: TextStyle(
                                                                  fontSize: 26,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              gradient: LinearGradient(
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                  colors: [
                                                                    Color(
                                                                        0xFF70d6ff),
                                                                    Color(
                                                                        0xFFff70a6),
                                                                    Color(
                                                                        0xFFff9770),
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            189,
                                                                            22),
                                                                  ]),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            "3 nap hozzáférés a Puskázz App összes Prémium funkciójához",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fontSize: 18),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Text(
                                                                "🎉",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        30,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              GradientText(
                                                                "Ingyenes",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        30,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                gradient: LinearGradient(
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    colors: [
                                                                      Color(
                                                                          0xFF70d6ff),
                                                                      Color(
                                                                          0xFFff70a6),
                                                                      Color(
                                                                          0xFFff9770),
                                                                      Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          189,
                                                                          22),
                                                                    ]),
                                                              ),
                                                              Text(
                                                                "🎉",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        30,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    InkWell(
                                      onTap: () {
                                        _buyProduct(0);
                                      },
                                      child: GradientButton(
                                          onPressed: () {
                                            _buyProduct(0);
                                          },
                                          title: "1 hónap",
                                          content:
                                              "1 hónap hozzáférés a Puskázz App összes Prémium funkciójához",
                                          price:
                                              double.parse(prices[0].toString())
                                                      .toStringAsFixed(0) +
                                                  " Ft",
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              5.5),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _buyProduct(1);
                                      },
                                      child: GradientButton(
                                          onPressed: () {
                                            _buyProduct(1);
                                          },
                                          title: "3 hónap",
                                          content:
                                              "3 hónap hozzáférés a Puskázz App összes Prémium funkciójához",
                                          price:
                                              double.parse(prices[1].toString())
                                                      .toStringAsFixed(0) +
                                                  " Ft",
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              5.5),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _buyProduct(2);
                                      },
                                      child: GradientButton(
                                          onPressed: () {
                                            _buyProduct(2);
                                          },
                                          title: "6 hónap",
                                          content:
                                              "6 hónap hozzáférés a Puskázz App összes Prémium funkciójához",
                                          price:
                                              double.parse(prices[2].toString())
                                                      .toStringAsFixed(0) +
                                                  " Ft",
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              5.5),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    Platform.isIOS
                                        ? "Ez egy egyszeri tranzakció! Nem fog megújulni! \n Ha lejárt, akkor újra meg kell vásárolnod, ha úgy döntesz, hogy tovább használod."
                                        : "Megújuló előfizetés! Ha nem mondod le, automatikusan megújul!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Mit tud a",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 28,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GradientText(
                                          "Prémium",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 28,
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
                                          "?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 28,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 24),
                                    GradientText(
                                      "Az összes csomagra vonatkozik",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
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
                                    SizedBox(height: 24),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "A Prémium csomagok között funkcióbeli különbség nincsen. A különbség csa az időtartam.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                                    .scaffoldBackgroundColor ==
                                                Colors.white
                                            ? Colors.grey[200]
                                            : Colors.grey[900],
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GradientText(
                                                      "\nMegváltoztatható app ikon",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 24),
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Color(0xFF70d6ff),
                                                            Color(0xFFff70a6),
                                                            Color(0xFFff9770),
                                                            Color.fromARGB(255,
                                                                255, 189, 22),
                                                          ])),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Text(
                                                      "Rejtsd el az appot! Válassz egy másik ikont, hogy senki se tudja, hogy ez a Puskázz App!",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              GradientText(
                                                  "Továbbküldhető puskák",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFF70d6ff),
                                                        Color(0xFFff70a6),
                                                        Color(0xFFff9770),
                                                        Color.fromARGB(
                                                            255, 255, 189, 22),
                                                      ])),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Text(
                                                  "Küldhetsz puskákat a barátaidnak, hogy ők is használhassák őket!",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GradientText("Elmenthető puskák",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFF70d6ff),
                                                        Color(0xFFff70a6),
                                                        Color(0xFFff9770),
                                                        Color.fromARGB(
                                                            255, 255, 189, 22),
                                                      ])),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Text(
                                                  "Automatikusan mentheted a puskáidat, hogy később is használhasd őket!",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GradientText(
                                                  "Visszakereshető és átnevezhető puskák",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFF70d6ff),
                                                        Color(0xFFff70a6),
                                                        Color(0xFFff9770),
                                                        Color.fromARGB(
                                                            255, 255, 189, 22),
                                                      ])),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Text(
                                                  "Keress az elmentett puskáid között, vagy nevezd át őket, hogy gyorsan megtaláld őket!",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 32.0),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, "/homepage", (route) => false);
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Theme.of(context).primaryColor,
                                )),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )
            : Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ));
  }
}

class ThanksForPurchaseScreen extends StatefulWidget {
  const ThanksForPurchaseScreen({super.key});

  @override
  State<ThanksForPurchaseScreen> createState() =>
      _ThanksForPurchaseScreenState();
}

class _ThanksForPurchaseScreenState extends State<ThanksForPurchaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
              child: Icon(Icons.done,
                  size: 100, color: Theme.of(context).scaffoldBackgroundColor),
            ),
            GradientText(
              "Köszönjük a vásárlást!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
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
            InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/premiumsShowcase", (route) => false);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.25,
                height: MediaQuery.of(context).size.height / 12,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor ==
                            Colors.black
                        ? Color(0xFF343434)
                        : Color(0xFfdedede),
                    borderRadius: BorderRadius.circular(50)),
                child: Center(
                  child: GradientText(
                    "Kész!",
                    style: TextStyle(
                        fontSize: 24,
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
    );
  }
}

class ErrorPurchaseScreen extends StatelessWidget {
  const ErrorPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.redAccent,
                    Colors.red,
                  ],
                ),
              ),
              child: Icon(Icons.close_rounded,
                  size: 100, color: Theme.of(context).scaffoldBackgroundColor),
            ),
            GradientText(
              "Valami hiba történt a vásárlás során!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.redAccent,
                  Colors.red,
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (route) => false);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.25,
                height: MediaQuery.of(context).size.height / 12,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor ==
                            Colors.black
                        ? Color(0xFF343434)
                        : Color(0xFfdedede),
                    borderRadius: BorderRadius.circular(50)),
                child: Center(
                  child: GradientText(
                    "Vissza",
                    style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white,
                        ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvalidPremiumScreen extends StatelessWidget {
  const InvalidPremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.redAccent,
                    Colors.red,
                  ],
                ),
              ),
              child: Icon(Icons.close_rounded,
                  size: 100, color: Theme.of(context).scaffoldBackgroundColor),
            ),
            GradientText(
              "A megadott kód érvénytelen, vagy lejárt!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.redAccent,
                  Colors.red,
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/homepage", (route) => false);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.25,
                height: MediaQuery.of(context).size.height / 12,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor ==
                            Colors.black
                        ? Color(0xFF343434)
                        : Color(0xFfdedede),
                    borderRadius: BorderRadius.circular(50)),
                child: Center(
                  child: GradientText(
                    "Vissza",
                    style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white,
                        ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CancelledPremiumScreen extends StatelessWidget {
  const CancelledPremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade400,
                  ],
                ),
              ),
              child: Icon(Icons.close_rounded,
                  size: 100, color: Theme.of(context).scaffoldBackgroundColor),
            ),
            GradientText(
              "A vásárlás meg lett szakítva!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade400,
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/homepage", (route) => false);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.25,
                height: MediaQuery.of(context).size.height / 12,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor ==
                            Colors.black
                        ? Color(0xFF343434)
                        : Color(0xFfdedede),
                    borderRadius: BorderRadius.circular(50)),
                child: Center(
                  child: GradientText(
                    "Vissza",
                    style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white,
                        ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
