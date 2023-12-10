import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getObserver() =>
      FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> logEvent(String name) async {
    final prefs = await SharedPreferences.getInstance();
    bool enableAnalytics =
        await prefs.getBool('enableAnalytics') ?? true;
    if (enableAnalytics == true) {
      await analytics.logEvent(name: name);
      debugPrint('Analytics: $name');
    }
  }
}
