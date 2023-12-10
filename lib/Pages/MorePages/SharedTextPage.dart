import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_bar_code/qr/src/qr_code.dart';
import 'package:web_socket_channel/io.dart';

import '../../Utils/WS/WebsocketServer.dart';

class SharedTextPage extends StatefulWidget {
  const SharedTextPage({super.key});

  @override
  State<SharedTextPage> createState() => _SharedTextPageState();
}

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({required this.point, required this.areaPaint});
}

class _SharedTextPageState extends State<SharedTextPage> {
  String? serverIp;
  final pageController = PageController(initialPage: 0);
  final controller = MobileScannerController(returnImage: true);
  dynamic stream;
  Timer? _debounceTimer;
  List<DrawingArea> points = [];
  late Color selectedColor;
  late double strokeWidth;

  void _sendDrawToServer(points) {
    // Replace this with your WebSocket logic
    WebsocketServer().sendDraw(points);
    debugPrint("Sending points to server: $points");
  }

  void _onDrawChanged(newPoints) {
    _debounceTimer?.cancel(); // Cancel the previous timer

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _sendDrawToServer(newPoints); // Send text to server after a brief delay
    });
  }

  @override
  void initState() {
    super.initState();
    getIp();
    selectedColor = Colors.white;
    strokeWidth = 1.0;
  }

  void getIp() async {
    await WebsocketServer().getInternalIpAddress().then((value) {
      setState(() {
        serverIp = value;
      });
      debugPrint(serverIp.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: pageController,
        //physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Vászon megosztása",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 26),
                        ),
                        QRCode(
                          data: serverIp.toString(),
                          size: 180,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              pageController.jumpToPage(
                                4,
                              );
                            });
                          },
                          child: const Text('Tovább'),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Csatlatlakozás",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              pageController.jumpToPage(
                                1,
                              );
                            });
                          },
                          child: const Text('QR kód beolvasása'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          MobileScanner(
            onDetect: (capture) async {
              final barcodes = capture.barcodes;
              final image = capture.image;
              String? scan;

              for (final barcode in barcodes) {
                scan = barcode.rawValue;

                if (scan != null) {
                  IOWebSocketChannel channel =
                      IOWebSocketChannel.connect('ws://$scan:55544');
                  stream = channel.stream;
                  debugPrint(scan);
                  setState(() {
                    pageController.jumpToPage(
                      3,
                    );
                  });
                }
              }
            },
          ),
          Center(
            child: GestureDetector(
              onPanDown: (details) {
                setState(() {
                  points.add(DrawingArea(
                      point: details.localPosition,
                      areaPaint: Paint()
                        ..color = selectedColor
                        ..strokeWidth = strokeWidth
                        ..isAntiAlias = true));
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  points.add(DrawingArea(
                      point: details.localPosition,
                      areaPaint: Paint()
                        ..color = selectedColor
                        ..strokeWidth = strokeWidth
                        ..isAntiAlias = true));
                });
              },
              onPanEnd: (details) {
                setState(() {
                  points.add(DrawingArea(
                      point: Offset.infinite,
                      areaPaint: Paint()
                        ..color = selectedColor
                        ..strokeWidth = strokeWidth
                        ..isAntiAlias = true));
                });
              },
              child: CustomPaint(
                painter: DrawingPainter(points: points),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: StreamBuilder(
                stream: stream,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  List<DrawingArea> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    for (int x = 0; x < points.length - 1; x++) {
      if (points[x].point.dx != Offset.infinite.dx &&
          points[x + 1].point.dx != Offset.infinite.dx) {
        canvas.drawLine(
            points[x].point, points[x + 1].point, points[x].areaPaint);
      } else if (points[x].point.dx != Offset.infinite.dx &&
          points[x + 1].point.dx == Offset.infinite.dx) {
        canvas.drawPoints(
            PointMode.points, [points[x].point], points[x].areaPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
