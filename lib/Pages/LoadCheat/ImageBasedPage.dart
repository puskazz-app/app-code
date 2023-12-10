import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alert/alert.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:puskazz_app/Utils/AnalyticsService/AnalyticsServcie.dart';
import 'package:puskazz_app/Utils/EncriptionManager.dart';
import 'package:puskazz_app/Utils/PanicUtil/PanicButtonUtil.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:puskazz_app/Utils/Cheats/DatabaseHelper.dart';
import 'package:puskazz_app/Utils/Cheats/SaveModel.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageBasedPage extends StatefulWidget {
  const ImageBasedPage({super.key});

  @override
  State<ImageBasedPage> createState() => _ImageBasedPageState();
}

class _ImageBasedPageState extends State<ImageBasedPage> {
  List images = [];
  int selectedArrow = 0;
  double zoom = 1;
  bool loadMore = false;
  bool hide = false;
  bool showHint = true;
  bool adLoaded = false;
  bool tooManyImages = false;
  bool loaded = false;
  bool isInitalizedByDev = false;
  String saveBase64String = "";
  double currentvol = 0.5;
  bool enableTouchLock = false;
  bool showPanicHint = false;
  bool showPanicHint2 = false;
  PageController pageController = PageController();

  void loadImage() async {
    await ImagePicker().pickMultiImage(imageQuality: 50).then((value) {
      for (int i = 0; i < images.length + 1; i++) {
        if (File(value[i].path).readAsBytesSync().lengthInBytes < 2500000) {
          if (i <= 4) {
            images.add(base64Encode(File(value[i].path).readAsBytesSync()));
            tooManyImages = false;
          } else {
            images.add(base64Encode(File(value[i].path).readAsBytesSync()));
            tooManyImages = true;
          }
        } else {
          Alert(
                  message:
                      "A betöltött kép túl nagy mértű! A mentés nem lehetséges.")
              .show()
              .then((value) => tooManyImages = true);
          images.add(base64Encode(File(value[i].path).readAsBytesSync()));
          tooManyImages = true;
        }
      }
    }).whenComplete(() {
      if (images.isEmpty) {
        Navigator.pop(context);
        Alert(message: "Nem lett kép kiválasztva!").show();
      } else {
        loaded = true;
        for (int i = 0; i < images.length; i++) {
          setState(() {
            saveBase64String += images[i] + ",,,";
          });
        }

        if (tooManyImages == true) {
          Alert(
                  message:
                      "Maximum 4 képet tudsz elmenteni. A jelenlegi puska mentése nem lehetséges!")
              .show()
              .then((value) => Navigator.pop(context));
        } else {
          saveCheat(saveBase64String);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadImage();
    //checkVolume();
    checkShakePanic();

    AnalyticsService().logEvent('image_loaded');
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

  void saveCheat(String base64Images) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('HH:mm (yyyy. MM. dd.)');
    CheatsDBhelper.instance.add(
      CheatsModel(
          savedCheatTitle: formatter.format(now).toString(),
          savedCheatImages: base64Images),
    );
    setState(() {
      saveBase64String = "";
    });
  }

  @override
  Widget build(BuildContext context) {
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
          body: Stack(
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
                                  ScreenBrightness().resetScreenBrightness();
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
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: Visibility(
                                        visible: hide,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: Image.memory(base64Decode(
                                                      images[i].toString()))
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
                                  image: Image.memory(base64Decode("")).image,
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
                                      child: Text("Pánik gomb aktiválva!",
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
          ),
        ),
      )),
    );
  }
}
