import 'dart:async';
import 'dart:io';
import 'package:alert/alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:power_file_view/power_file_view.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentViewerPage extends StatefulWidget {
  const DocumentViewerPage({super.key});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  File file = File('');
  bool loaded = false;
  bool hide = true;
  bool showHint = true;
  bool enableTouchLock = false;
  bool showPanicHint = false;

  void loadFiles() async {
    final _directory = await getTemporaryDirectory();
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.any);

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
        loaded = true;
      });
    } else {
      Alert(message: "Nem lett dokumentum kiválasztva").show();
      setState(() {
        loaded = false;
      });
      Navigator.pop(context);
    }
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
        Future.delayed(Duration(seconds: 1)).then((value) => setState(() {}));
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
  void initState() {
    super.initState();
    loadFiles();
    checkShakePanic();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (file == File('')) {
        loadFiles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loaded == true
          ? Stack(
              alignment: Alignment.center,
              children: [
                Visibility(
                  visible: showHint,
                  child: Icon(Icons.touch_app, color: Colors.grey, size: 64),
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
                                    ScreenBrightness().resetScreenBrightness();
                                  });
                                },
                                onLongPressCancel: () => setState(() {
                                      hide = true;
                                      showHint = false;
                                      ScreenBrightness().setScreenBrightness(0);
                                    }),
                                onLongPressUp: () => setState(() {
                                      hide = true;
                                      showHint = false;
                                      ScreenBrightness().setScreenBrightness(0);
                                    }),
                                onForcePressEnd: (details) => setState(() {
                                      hide = true;
                                      showHint = false;
                                      ScreenBrightness().setScreenBrightness(0);
                                    }),
                                onDoubleTap: () {
                                  setState(() {
                                    showHint = false;
                                  });
                                  panic();
                                },
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: PowerFileViewWidget(
                                        filePath: file.path,
                                        downloadUrl: file.path,
                                        errorBuilder: (error) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  "Hiba történt a dokumentum megnyitása közben",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.redAccent),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Újrapróbálkozás",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .blueAccent),
                                                    ))
                                              ],
                                            ),
                                          );
                                        },
                                        loadingBuilder: (ctx, progress) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          );
                                        })))))),
              ],
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
            ),
    );
  }
}
