import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';

class NetworkConnectivity extends StatefulWidget {
  String destination;
  NetworkConnectivity({super.key, required this.destination});

  @override
  State<NetworkConnectivity> createState() => _NetworkConnectivityState();
}

class _NetworkConnectivityState extends State<NetworkConnectivity> {
  bool? hasInternet;
  bool isReturnable = false;
  FlutterNetworkConnectivity flutterNetworkConnectivity =
      FlutterNetworkConnectivity();

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  StreamSubscription<bool>? internetSubscription;

  void checkConnection() {
    flutterNetworkConnectivity = FlutterNetworkConnectivity(
      isContinousLookUp: hasInternet ?? true,
      lookUpDuration: const Duration(seconds: 2),
      lookUpUrl: 'example.com',
    );

    internetSubscription = flutterNetworkConnectivity
        .getInternetAvailabilityStream()
        .listen((isInternetAvailable) {
      if (isInternetAvailable == true) {
        setState(() {
          hasInternet = true;
        });
        Navigator.pushNamedAndRemoveUntil(
            context, "/" + widget.destination, (route) => isReturnable);
      } else {
        setState(() {
          hasInternet = false;
        });
      }
    });
  }

  @override
  void dispose() {
    internetSubscription?.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (arguments["isReturnable"] != null) {
      isReturnable = arguments["isReturnable"] as bool;
    } else {
      isReturnable = false;
    }
    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: hasInternet == false
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor),
                  child: Icon(Icons.wifi_off_rounded,
                      size: 100,
                      color: Theme.of(context).scaffoldBackgroundColor),
                ),
                Text(
                  "Kérlek kapcsold be a mobilnetedet, vagy csatlakozz egy WiFi hálózathoz!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    onPressed: () => checkConnection(),
                    child: Text(
                      "Újra",
                      style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor),
                    ))
              ],
            )
          : CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
    )));
  }
}
