import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:puskazz_app/Utils/AnalyticsService/AnalyticsServcie.dart';
import 'package:puskazz_app/Utils/Cheats/DatabaseHelper.dart';
import 'package:puskazz_app/Utils/Cheats/SaveModel.dart';
import 'package:puskazz_app/Utils/EncriptionManager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TextBasedPage extends StatefulWidget {
  const TextBasedPage({super.key});

  @override
  State<TextBasedPage> createState() => _TextBasedPageState();
}

PageController pageController = PageController();
TextEditingController textEditingController = TextEditingController();
FocusNode focusNode = FocusNode();

class _TextBasedPageState extends State<TextBasedPage> {
  bool hide = true;
  bool showHint = true;
  bool useMarkdownSyntax = false;
  bool enableTouchLock = false;
  bool scrollable = false;
  final ScrollController controller = ScrollController();
  double currentvol = 0.5;
  String textToSave = "";
  bool showPanicHint = false;
  bool showPanicHint2 = false;
  List<String> savedTexts = [];
  bool loaded = false;
  final GlobalKey _key = GlobalKey();
  double _widgetHeight = 0.0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(milliseconds: 250), (timer) {
      checkPage();
    });
    checkShakePanic();
  }

  void panic() async {
    var prefs = await SharedPreferences.getInstance();
    bool? _usePanicButton = await prefs.getBool("usePanicButton") ?? false;
    if (enableTouchLock == false) {
      if (_usePanicButton == true) {
        setState(() {
          hide = true;
          enableTouchLock = true;
          showPanicHint = true;
          showPanicHint2 = false;
          ScreenBrightness().setScreenBrightness(0);
        });
        Future.delayed(Duration(seconds: 1)).then((value) => setState(() {
              showPanicHint = false;
            }));
      }
    } else {
      setState(() {
        hide = false;
        enableTouchLock = false;
        showPanicHint = false;
        showPanicHint2 = true;
        Future.delayed(Duration(seconds: 1)).then((value) => setState(() {
              showPanicHint2 = false;
            }));
        ScreenBrightness().resetScreenBrightness();
      });
    }
  }

  void checkShakePanic() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool usePanicButtonShakeTemp =
        await prefs.getBool('usePanicButtonShake') ?? false;
    if (usePanicButtonShakeTemp == true) {
      ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
        panic();
      });
    }
  }

  void checkPage() {
    if (pageController.page == 0) {
      ScreenBrightness().resetScreenBrightness();
      setState(() {
        scrollable = false;
      });
    } else {
      setState(() {
        scrollable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return WillPopScope(
      onWillPop: () {
        ScreenBrightness().resetScreenBrightness();
        Navigator.pushReplacementNamed(context, '/homepage');
        return Future.value(false);
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 50) {
            Navigator.pushReplacementNamed(context, '/homepage');
          }
        },
        onTap: () {
          setState(() {
            focusNode.unfocus();
          });
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: PageView(
                controller: pageController,
                physics: scrollable == true
                    ? AlwaysScrollableScrollPhysics()
                    : NeverScrollableScrollPhysics(),
                children: [
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Align(
                        child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: TextField(
                            minLines: 22,
                            maxLines: 22,
                            focusNode: focusNode,
                            controller: textEditingController,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                            decoration: InputDecoration(
                              hintText: 'Ide írd a puskád szövegét',
                              hintStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                textEditingController.text =
                                    textEditingController.text;
                              });

                              pageController.nextPage(
                                  duration: Duration(milliseconds: 250),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[300]
                                      : Color(0xFF121212),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          ScreenBrightness()
                                              .resetScreenBrightness();
                                          Navigator.pushNamed(
                                              context, '/homepage');
                                        },
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          focusNode.unfocus();
                                        },
                                        icon: Icon(
                                          Icons.keyboard_hide_rounded,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                  color: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[300]
                                      : Color(0xFF121212),
                                ),
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).primaryColor,
                                      onPrimary: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        textEditingController.text =
                                            textEditingController.text;
                                      });

                                      DateFormat formatter =
                                          DateFormat('HH:mm (yyyy. MM. dd.)');
                                      CheatsDBhelper.instance.add(CheatsModel(
                                          savedCheatTitle:
                                              formatter.format(DateTime.now()),
                                          savedCheatImages:
                                              "txt/md:::${textEditingController.text},,,"));

                                      if (textEditingController
                                          .text.isNotEmpty) {
                                        pageController.nextPage(
                                            duration:
                                                Duration(milliseconds: 250),
                                            curve: Curves.ease);
                                      }
                                    },
                                    child: const Text('Tovább'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                  ),
                  enableTouchLock == false
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Visibility(
                              visible: showHint,
                              child: Icon(Icons.touch_app,
                                  color: Colors.grey, size: 64),
                            ),
                            Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: GestureDetector(
                                      onLongPressDown: (details) {
                                        setState(() {
                                          hide = false;
                                          showHint = false;
                                          ScreenBrightness()
                                              .resetScreenBrightness();
                                        });
                                      },
                                      onLongPressCancel: () => setState(() {
                                        hide = true;
                                        showHint = false;
                                        ScreenBrightness()
                                            .setScreenBrightness(0);
                                      }),
                                      onLongPressUp: () => setState(() {
                                        hide = true;
                                        showHint = false;
                                        ScreenBrightness()
                                            .setScreenBrightness(0);
                                      }),
                                      onForcePressEnd: (details) =>
                                          setState(() {
                                        hide = true;
                                        showHint = false;
                                        ScreenBrightness()
                                            .setScreenBrightness(0);
                                      }),
                                      onDoubleTap: () {
                                        setState(() {
                                          showHint = false;
                                        });
                                        panic();
                                      },
                                      child: SingleChildScrollView(
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: Visibility(
                                            visible: !hide,
                                            child: MarkdownBody(
                                                shrinkWrap: true,
                                                onTapLink:
                                                    (text, href, title) async {
                                                  await launchUrl(
                                                      Uri.parse(href!));
                                                },
                                                data:
                                                    textEditingController.text,
                                                selectable: false,
                                                styleSheet: MarkdownStyleSheet(
                                                  p: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                  blockquote: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                  h1: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 26,
                                                  ),
                                                  h2: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                  ),
                                                  h3: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 24,
                                                  ),
                                                  h4: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 23,
                                                  ),
                                                  h5: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                  ),
                                                  h6: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 21,
                                                  ),
                                                  em: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                  strong: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                  code: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                  ),
                                                  codeblockDecoration:
                                                      BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  codeblockPadding:
                                                      EdgeInsets.all(10),
                                                )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            Visibility(
                              visible: showPanicHint2,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 64.0),
                                  child: Text("Pánik gomb kikapcsolva!",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onDoubleTap: () async {
                            panic();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: Colors.black,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Visibility(
                                  visible: showPanicHint,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 64.0),
                                    child: Text("Pánik gomb bekapcsolva!",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
