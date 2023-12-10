import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:puskazz_app/Pages/Etc/NetworkConnectivityPage.dart';
import 'package:puskazz_app/Pages/Etc/PurchasePremiumPage.dart';
import 'package:puskazz_app/Pages/MorePages/PremiumPurchased.dart';
import 'package:puskazz_app/Pages/MorePages/SavedCheats.dart';
import 'package:puskazz_app/Utils/AnalyticsService/AnalyticsServcie.dart';
import 'package:puskazz_app/Utils/EncriptionManager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widgets/GrdientButton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String welcomeText = 'Üdvözlünk!';
  String message = '';

  bool showContent = false;
  bool isInitalizedByDev = false;
  int pageIndex = 0;
  bool isCameraInitailized = false;
  PageController pageController = PageController();
  Offerings? offerings;
  bool isTransitioned = false;

  @override
  void initState() {
    FullScreenWindow.setFullScreen(true);
    super.initState();
    setState(() {
      showContent = true;
    });
    dateTime();
    getMessage();
    ScreenBrightness().resetScreenBrightness();

    Timer.periodic(Duration(minutes: 30), (timer) {
      dateTime();
    });
  }

  void getMessage() async {
    final url =
        Uri.parse('https://szeligbalazs.github.io/shotgunapp-messages/');
    final response = await http.get(url);
    dom.Document document = dom.Document.html(response.body);

    final text =
        document.querySelectorAll('p').map((e) => e.innerHtml.trim()).toList();
    for (var i = 0; i < text.length; i++) {
      setState(() {
        message = text[i];
      });
    }
  }

  void dateTime() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour < 8) {
      setState(() {
        welcomeText = 'Jó reggelt!';
      });
    } else if (hour < 17) {
      setState(() {
        welcomeText = 'Szép napot!';
      });
    } else {
      setState(() {
        welcomeText = 'Szép estét!';
      });
    }

    if (now.weekday == 6 || now.weekday == 7) {
      setState(() {
        welcomeText = 'Jó hétvégét!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (arguments["initPage"] != null && pageController.hasClients == true) {
      if (arguments["initPage"] == 0 && isTransitioned == false) {
        setState(() {
          pageIndex = 0;
          pageController.jumpToPage(
            pageIndex,
          );
          isTransitioned = true;
        });
      } else if (arguments["initPage"] == 1 && isTransitioned == false) {
        setState(() {
          pageIndex = 1;
          pageController.jumpToPage(
            pageIndex,
          );
          isTransitioned = true;
        });
      }
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return showContent == true
        ? GestureDetector(
            onTap: () {
              ScreenBrightness().resetScreenBrightness();
            },
            onDoubleTap: () {
              ScreenBrightness().resetScreenBrightness();
            },
            onLongPress: () {
              ScreenBrightness().resetScreenBrightness();
            },
            child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      GradientText(
                        "Puskázz App",
                        style: TextStyle(fontWeight: FontWeight.w900),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF70d6ff),
                              Color(0xFFff70a6),
                              Color(0xFFff9770),
                              Color.fromARGB(255, 255, 189, 22),
                            ]),
                      )
                    ],
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  foregroundColor: Theme.of(context).primaryColor,
                  actions: [
                    IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        }),
                  ],
                ),
                body: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    LayoutBuilder(builder: (context, viewportConsts) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewportConsts.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(welcomeText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: width / 8)),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(message,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: width / 20)),
                                    ),
                                    Text('Válassz egy lehetőséget',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16)),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            onTap: () {
                                              if (isCameraInitailized == true) {
                                                Navigator.pushNamed(
                                                    context, '/image');
                                              } else {
                                                Permission.camera
                                                    .request()
                                                    .then((value) =>
                                                        Navigator.pushNamed(
                                                            context, '/image'));
                                              }
                                            },
                                            child: Container(
                                              width: width / 2.5,
                                              height: width / 2.5,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .scaffoldBackgroundColor ==
                                                        Colors.white
                                                    ? Colors.grey[200]
                                                    : Colors.grey[900],
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.image,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: width >= 1200
                                                          ? width / 10
                                                          : width / 8,
                                                    ),
                                                    Text('\nKép betöltése',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => arguments[
                                                                  "isReturnable"] ==
                                                              1
                                                          ? NetworkConnectivity(
                                                              destination:
                                                                  'saved')
                                                          : NetworkConnectivity(
                                                              destination:
                                                                  'qr')));
                                            },
                                            child: Container(
                                              width: width / 2.5,
                                              height: width / 2.5,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .scaffoldBackgroundColor ==
                                                        Colors.white
                                                    ? Colors.grey[200]
                                                    : Colors.grey[900],
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.qr_code,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: width >= 1200
                                                          ? width / 10
                                                          : width / 8,
                                                    ),
                                                    Text('\nPuska fogadása',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/text');
                                          },
                                          child: Container(
                                            width: width / 1.15,
                                            height: width / 2.5,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                          .scaffoldBackgroundColor ==
                                                      Colors.white
                                                  ? Colors.grey[200]
                                                  : Colors.grey[900],
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.text_fields,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: width >= 1200
                                                        ? width / 10
                                                        : width / 8,
                                                  ),
                                                  Text('\nSzöveges puska írása',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                    SavedCheats()
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: Colors.grey,
                  currentIndex: pageIndex,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Kezdőlap',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.save_outlined),
                      label: 'Elmentettek',
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      pageIndex = index;
                      pageController.animateToPage(index,
                          duration: Duration(milliseconds: 150),
                          curve: Curves.easeIn);
                    });
                  },
                )),
          )
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
  }
}
