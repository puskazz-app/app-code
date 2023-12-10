import 'dart:io';

import 'package:alert/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:puskazz_app/Utils/AnalyticsService/AnalyticsServcie.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PanicButton {
  int _counter = 0;
  int _lastPressed = 0;

  Future<bool> enableTouchLock() async {
    var prefs = await SharedPreferences.getInstance();
    bool? _usePanicButton = await prefs.getBool("usePanicButton") ?? false;
    bool enabled = false;
    int _now = DateTime.now().millisecondsSinceEpoch;
    if (_now - _lastPressed > 1000) {
      _counter = 0;
    }
    _counter++;
    _lastPressed = _now;
    if (_counter >= 2 && _usePanicButton == true) {
      if (enabled == false) {
        enabled = true;
        ScreenBrightness().setScreenBrightness(0);
      } else {
        enabled = false;
        ScreenBrightness().resetScreenBrightness();
      }
    }
    return enabled;
  }
}
