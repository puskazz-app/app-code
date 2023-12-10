import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:puskazz_app/Utils/AnalyticsService/AnalyticsServcie.dart';
import 'package:puskazz_app/Utils/Cheats/DatabaseHelper.dart';
import 'package:puskazz_app/Utils/Cheats/SaveModel.dart';
import 'package:puskazz_app/Utils/EncriptionManager.dart';
import 'package:puskazz_app/Utils/GitHub/DownloadManager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/cupertino.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? cheat = "";
  bool isCameraInitailized = false;
  List values = [];

  var controller = MobileScannerController(
    // facing: CameraFacing.back,
    // torchEnabled: false,
    returnImage: true,
  );

  void vibrate() async {
    HapticFeedback.heavyImpact();
  }

  void establishWebSocketConnection(String url) {
    final channel = WebSocketChannel.connect(Uri.parse("ws://$url:55444"));
    channel.stream.listen((event) async {
      controller.stop();
      setState(() {
        cheat = event;
        debugPrint("cheat: " + cheat.toString());
      });
    });
    if (cheat != null && cheat != "") {
      vibrate();
      channel.sink.close();
      Navigator.pushReplacementNamed(context, '/load', arguments: {
        "data": cheat,
        "save": true,
      });
    }

    cheat = "";
  }

  Future<List<int>> downloadGitHubImage(String path, int index) async {
    final downloader = GitHubImageDownloader(
      username: 'SzeligBalazs',
      repository: 'puskazz-app-shares',
      branch: 'main',
      path: '${path}/image_${index}.png',
    );

    return await downloader.downloadImage();
  }

  Future<String> downloadGitHubText(String path) async {
    final downloader = GitHubImageDownloader(
      username: 'SzeligBalazs',
      repository: 'puskazz-app-shares',
      branch: 'main',
      path: "${path}/cheat.md",
    );

    return await downloader.downloadMarkdownFile();
  }

  @override
  void dispose() {
    super.dispose();
    controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (arguments["data"] != null) {
      Navigator.pushReplacementNamed(context, "/image");
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
                  body: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dx > 50) {
                        Navigator.pop(context);
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          fit: BoxFit.cover,
                          controller: controller,
                          errorBuilder: (context, error, widget) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Hiba történt a kamera inicializálása közben. Kérlek próbáld újra!",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22),
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25))),
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(
                                              context, '/homepage');
                                        },
                                        child: Text(
                                          "Újra",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ))
                                  ],
                                ),
                              ),
                            );
                          },
                          onScannerStarted: (scan) {
                            setState(() {
                              isCameraInitailized = true;
                            });
                          },
                          onDetect: (capture) async {
                            final List<Barcode> barcodes = capture.barcodes;
                            final Uint8List? image = capture.image;

                            String? scan = "";
                            for (final barcode in barcodes) {
                              scan = barcode.rawValue;
                              if (scan != null) {
                                debugPrint("scan-result: " + scan);
                                controller.stop();
                                if (scan.toString().startsWith("puska::::")) {
                                  var url = scan
                                      .toString()
                                      .substring(9, scan.length - 4);
                                  var numberOfImages =
                                      int.parse(scan.toString().substring(
                                            scan.toString().length - 1,
                                            scan.toString().length,
                                          ));

                                  debugPrint("numberOfImages: " +
                                      numberOfImages.toString());

                                  int downloadedImages =
                                      0; // Counter for downloaded images

                                  for (var i = 0; i < numberOfImages; i++) {
                                    var imageUrl = '$url/image_${i}.png';
                                    print(
                                        'Downloading image $i from $imageUrl');
                                    try {
                                      var value = await downloadGitHubImage(
                                        url,
                                        i,
                                      );
                                      setState(() {
                                        if (values.contains(
                                                base64Encode(value) + ",,,") ==
                                            false) {
                                          values
                                              .add(base64Encode(value) + ",,,");
                                        }
                                        downloadedImages = i;
                                        debugPrint("downloadedImages: " +
                                            downloadedImages.toString());
                                      });
                                    } catch (e) {
                                      print('Error downloading image $i: $e');
                                    }
                                  }

                                  debugPrint("values: " + values.toString());
                                  if (numberOfImages >= 1) {
                                    if (downloadedImages ==
                                        numberOfImages - 1) {
                                      var value = await downloadGitHubImage(
                                        url,
                                        downloadedImages + 1,
                                      );
                                      setState(() {
                                        values.add(base64Encode(value) + ",,,");
                                        debugPrint("downloadedImages: " +
                                            downloadedImages.toString());
                                      });
                                      Navigator.pushReplacementNamed(
                                          context, '/load',
                                          arguments: {
                                            "data": values.join(),
                                            "save": true,
                                          });
                                    }
                                  } else {
                                    var value = await downloadGitHubImage(
                                      url,
                                      downloadedImages,
                                    );
                                    values.add(base64Encode(value) + ",,,");
                                    Navigator.pushReplacementNamed(
                                        context, '/load',
                                        arguments: {
                                          "data": values.join(),
                                          "save": true,
                                        });
                                  }
                                } else if (scan
                                    .toString()
                                    .startsWith("szoveg_puska::::")) {
                                  var url = scan
                                      .toString()
                                      .substring(16, scan.length);
                                  var text = await downloadGitHubText(url);
                                  Navigator.pushReplacementNamed(
                                      context, '/loadText',
                                      arguments: {
                                        "data": text,
                                        "save": true,
                                      });
                                } else {
                                  controller.stop();
                                  EncriptionManager encriptionManager =
                                      EncriptionManager();
                                  scan = encriptionManager
                                      .decrypt(scan.toString())
                                      .toString();

                                  List received = scan.split(":");
                                  int daysToUnlock = int.parse(received[2]);
                                  int validUntilYear = int.parse(received[3]);
                                  int validUntilMonth = int.parse(received[4]);
                                  int validUntilDay = int.parse(received[5]);
                                  int validUntilHour = int.parse(received[6]);
                                  DateTime validUntil = DateTime(
                                      validUntilYear,
                                      validUntilMonth,
                                      validUntilDay,
                                      validUntilHour);
                                  debugPrint(daysToUnlock.toString());
                                  DateTime now = DateTime.now();
                                  DateTime unlockDate;
                                  if (validUntil.isAfter(now)) {
                                    if (daysToUnlock == 0) {
                                      unlockDate =
                                          now.add(Duration(seconds: 60));
                                    } else {
                                      unlockDate =
                                          now.add(Duration(days: daysToUnlock));
                                    }
                                    final prefs =
                                        await SharedPreferences.getInstance();

                                    prefs.setInt("unlockDate",
                                        unlockDate.millisecondsSinceEpoch);
                                    EncriptionManager encriptionManager =
                                        EncriptionManager();
                                    prefs.setInt("unlockDate",
                                        unlockDate.millisecondsSinceEpoch);
                                    prefs.setString("purchasedBundleIndex",
                                        encriptionManager.encrypt("-1"));
                                    prefs.setBool("isCameraInitailized", true);

                                    Navigator.pushNamed(context, '/thanks');
                                    AnalyticsService()
                                        .logEvent("unlocked_by_dev_scan");
                                  } else {
                                    Navigator.pushNamed(
                                        context, '/invalidPurchase');
                                    AnalyticsService().logEvent(
                                        "tried_to_unlock_by_dev_scan");
                                  }
                                }
                              }
                            }
                          },
                        ),
                        Visibility(
                          visible: isCameraInitailized,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.8),
                                BlendMode.srcOut),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      backgroundBlendMode: BlendMode.dstOut),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width * 0.8,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
