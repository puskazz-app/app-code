import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:puskazz_app/Utils/Cheats/DatabaseHelper.dart';
import 'package:puskazz_app/Utils/Cheats/SaveModel.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadTextCheat extends StatefulWidget {
  const LoadTextCheat({super.key});

  @override
  State<LoadTextCheat> createState() => _LoadTextCheatState();
}

class _LoadTextCheatState extends State<LoadTextCheat> {
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
  String text = "";

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

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (loaded == false) {
      if (arguments["data"] != null) {
        setState(() {
          text = arguments["data"].toString();
        });
      } else if (arguments["save"] != null) {
        if (arguments["save"] == true) {
          setState(() {
            DateFormat formatter = DateFormat('HH:mm (yyyy. MM. dd.)');
            CheatsDBhelper.instance.add(CheatsModel(
                savedCheatTitle: formatter.format(DateTime.now()),
                savedCheatImages: "txt/md:::${arguments["save"]},,,"));
          });
        }
      }
    }
    return WillPopScope(
        onWillPop: () {
          ScreenBrightness().resetScreenBrightness();
          Navigator.pushReplacementNamed(context, '/homepage');
          return Future.value(false);
        },
        child: SafeArea(
            child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 50) {
                    Navigator.pushReplacementNamed(context, '/homepage');
                  }
                },
                child: Scaffold(
                  body: SafeArea(
                    child: enableTouchLock == false
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Visibility(
                                visible: showHint,
                                child: Icon(Icons.touch_app,
                                    color: Colors.grey, size: 64),
                              ),
                              SingleChildScrollView(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
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
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: SingleChildScrollView(
                                            child: Visibility(
                                              visible: !hide,
                                              child: SingleChildScrollView(
                                                child: MarkdownBody(
                                                    shrinkWrap: true,
                                                    onTapLink: (text, href,
                                                        title) async {
                                                      await launchUrl(
                                                          Uri.parse(href!));
                                                    },
                                                    data: text,
                                                    selectable: false,
                                                    styleSheet:
                                                        MarkdownStyleSheet(
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 26,
                                                      ),
                                                      h2: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 25,
                                                      ),
                                                      h3: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      codeblockPadding:
                                                          EdgeInsets.all(10),
                                                    )),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                              ),
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
                  ),
                ))));
  }
}
