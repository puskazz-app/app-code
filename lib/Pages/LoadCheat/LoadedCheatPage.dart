import 'dart:async';
import 'dart:convert';
import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:intl/intl.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:puskazz_app/Utils/Cheats/DatabaseHelper.dart';
import 'package:puskazz_app/Utils/Cheats/SaveModel.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/PanicUtil/PanicButtonUtil.dart';

class LoadedCheatsPage extends StatefulWidget {
  const LoadedCheatsPage({super.key});

  @override
  State<LoadedCheatsPage> createState() => _LoadedCheatsPageState();
}

class _LoadedCheatsPageState extends State<LoadedCheatsPage> {
  List images = [];
  int selectedArrow = 0;
  double zoom = 1;
  bool loadMore = false;
  bool hide = false;
  bool showHint = true;
  bool loaded = false;
  bool enableTouchLock = false;
  double currentvol = 0.5;
  PageController pageController = PageController();
  bool showPanicHint = false;
  bool showPanicHint2 = false;
  int times = 0;

  @override
  void initState() {
    super.initState();
    loaded = false;

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (loaded == false) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });

    //checkVolume();
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

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (arguments["data"] != null) {
      debugPrint("data: " + arguments["data"].toString());

      if (loaded == false) {
        setState(() {
          images = arguments["data"].toString().split(",,,");
          images.removeLast();
          loaded = true;
          debugPrint("images: " + arguments["data"].toString());
        });
      }
    } else {
      Navigator.pushReplacementNamed(context, "/homepage");
      Alert(message: "Hiba történt").show();
    }

    if (arguments["save"] == true) {
      String dateFormat = DateFormat("HH:mm").format(DateTime.now());

      if (times <= 0) {
        CheatsDBhelper.instance.add(
          CheatsModel(
            savedCheatTitle: "Áthozva ekkor: ${dateFormat}",
            savedCheatImages: arguments["data"].toString(),
          ),
        );
        times++;
      }
    } else if (arguments["save"] == null || arguments["save"] == false) {}

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
          backgroundColor: Colors.black,
          body: images.isNotEmpty
              ? Stack(
                  children: [
                    PageView(
                      controller: pageController,
                      scrollDirection: Axis.vertical,
                      children: [
                        for (int i = 0; i < images.length; i++)
                          enableTouchLock == false
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: GestureDetector(
                                    onLongPressDown: (details) {
                                      setState(() {
                                        hide = true;
                                        showHint = false;
                                        loaded = true;
                                        ScreenBrightness()
                                            .resetScreenBrightness();
                                      });
                                    },
                                    onLongPressCancel: () => setState(() {
                                      hide = false;
                                      showHint = false;
                                      loaded = true;
                                      ScreenBrightness().setScreenBrightness(0);
                                    }),
                                    onTapUp: (details) {
                                      hide = false;
                                      showHint = false;
                                      loaded = true;
                                      ScreenBrightness().setScreenBrightness(0);
                                    },
                                    onLongPressUp: () => setState(() {
                                      hide = false;
                                      showHint = false;
                                      loaded = true;
                                      ScreenBrightness().setScreenBrightness(0);
                                    }),
                                    onForcePressEnd: (details) => setState(() {
                                      hide = false;
                                      showHint = false;
                                      loaded = true;
                                      ScreenBrightness().setScreenBrightness(0);
                                    }),
                                    onDoubleTap: () async {
                                      panic();
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Visibility(
                                          visible: showHint,
                                          child: Icon(Icons.touch_app,
                                              color: Colors.grey, size: 64),
                                        ),
                                        InteractiveViewer(
                                          panEnabled: true,
                                          minScale: 1,
                                          maxScale: 5,
                                          onInteractionEnd: (details) {
                                            setState(() {
                                              hide = false;
                                            });
                                          },
                                          onInteractionStart: (details) {
                                            setState(() {
                                              hide = true;
                                            });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Visibility(
                                              visible: hide,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: Image.memory(
                                                            base64Decode(images[
                                                                    i]
                                                                .toString()))
                                                        .image,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              : GestureDetector(
                                  onDoubleTap: () async {
                                    panic();
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: Image.memory(base64Decode(""))
                                            .image,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Visibility(
                                          visible: showPanicHint,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 64.0),
                                            child: Text(
                                                "Pánik gomb bekapcsolva!",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                      ],
                    ),
                    Visibility(
                      visible: showPanicHint2,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64.0),
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
              : Center(
                  child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                )),
        ),
      )),
    );
  }
}
