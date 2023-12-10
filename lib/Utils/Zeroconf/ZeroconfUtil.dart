import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:nsd/nsd.dart';
import 'package:puskazz_app/Utils/WS/WebsocketServer.dart';
import 'package:puskazz_app/Utils/Zeroconf/NameGenerator.dart';

class ZeroconfUtil {
  void startInstance() async {
    NameGenerator nameGenerator = NameGenerator();
    String name = nameGenerator.generatedNames();
    final registration = await register(Service(
      name: name,
      type: '_http._tcp',
      port: 5050,
    ));

    debugPrint('Registered service: $registration');

    Future.delayed(Duration(minutes: 10), () async {
      await unregister(registration);
    });
  }
}
