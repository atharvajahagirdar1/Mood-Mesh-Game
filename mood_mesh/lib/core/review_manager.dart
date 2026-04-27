import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ReviewManager {
  static final InAppReview _inAppReview = InAppReview.instance;

  static Future<void> triggerReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool hasPrompted = prefs.getBool('has_prompted_review') ?? false;

      // Only trigger if we haven't successfully prompted them before
      if (!hasPrompted) {
        if (await _inAppReview.isAvailable()) {
          await _inAppReview.requestReview();
          // Save to memory so we never bother them with this popup again!
          await prefs.setBool('has_prompted_review', true);
        }
      }
    } catch (e) {
      debugPrint('Error triggering review: $e');
    }
  }
}