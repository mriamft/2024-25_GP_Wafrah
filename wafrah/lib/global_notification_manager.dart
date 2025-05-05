// global_notification_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class GlobalNotificationManager {
  // Singleton pattern
  static final GlobalNotificationManager _instance = GlobalNotificationManager._internal();
  factory GlobalNotificationManager() => _instance;
  GlobalNotificationManager._internal();

  Timer? _timer;

  // For aggregated notifications: milestone -> last count notified
  final Map<int, int> _sentAggregatedMilestones = {};

  // Track the last plan month for which a month-end notification was sent.
  int _lastNotifiedMonth = 0;
  // Track if mid-month notification has been sent in the current plan month.
  bool _midMonthNotified = false;
  // For each category: last milestone notified (0-4)
  final Map<String, int> _sentMilestones = {};
  // Track behind-plan notification sent
  bool _behindPlanNotified = false;

  // Saving plan data
  Map<String, dynamic>? _resultData;
  List<Map<String, dynamic>>? _accounts;
  DateTime? _planStartDate;
  int? _durationMonths;

  // Enforce a minimum interval between notifications
  DateTime? _lastNotificationTime;

  bool _canSend() {
    final now = DateTime.now();
    if (_lastNotificationTime == null ||
        now.difference(_lastNotificationTime!) >= Duration(minutes: 10)) {
      _lastNotificationTime = now;
      return true;
    }
    return false;
  }

  void _showNotification({required String title, required String body}) {
    if (_canSend()) {
      NotificationService.showNotification(title: title, body: body);
    }
  }

  /// Update the manager with the current saving plan data.
  void updateData({
    required Map<String, dynamic> resultData,
    required List<Map<String, dynamic>> accounts,
  }) {
    _resultData = resultData;
    _accounts = accounts;
    if (resultData.containsKey('startDate')) {
      _planStartDate = DateTime.parse(resultData['startDate']);
    }
    if (resultData.containsKey('DurationMonths')) {
      _durationMonths = (resultData['DurationMonths'] as num).toInt();
    }
    // Reset notifications tracking whenever plan data is updated.
    _sentAggregatedMilestones.clear();
    _sentMilestones.clear();
    _behindPlanNotified = false;
    _lastNotifiedMonth = 0;
    _midMonthNotified = false;
  }

  /// Clear the saved data when there is no plan.
  void clearData() {
    _resultData = null;
    _accounts = null;
    _planStartDate = null;
    _durationMonths = null;
    _sentAggregatedMilestones.clear();
    _sentMilestones.clear();
    _behindPlanNotified = false;
    _lastNotifiedMonth = 0;
    _midMonthNotified = false;
  }

  /// Start the periodic timer to check notifications.
  void start({Duration interval = const Duration(minutes: 1)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (timer) {
      _checkNotifications();
    });
  }

  /// Stop the timer if needed.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _checkNotifications() {
    // If there is no saving plan data, send an invitation notification and return.
    if (_resultData == null ||
        _planStartDate == null ||
        _accounts == null ||
        _durationMonths == null ||
        !_resultData!.containsKey('MonthlySavingsPlan') ||
        (_resultData!['MonthlySavingsPlan'] as List).isEmpty ||
        !_resultData!.containsKey('CategorySavings')) {
      _showNotification(
        title: "لا توجد خطة ادخار!",
        body: "لم تقم بإضافة خطة ادخار بعد. ابدأ الآن لتتمكن من تتبع أموالك.",
      );
      return;
    }

    // Proceed with notifications
    _checkMonthEndNotification();
    _checkMidMonthNotification();
    _checkAggregatedProgressNotification();
    _checkCategoryProgressNotifications();
    _checkBehindPlanNotification();
  }

  /// Check and send a month end notification if a full 30 day period has passed.
  void _checkMonthEndNotification() {
    final now = DateTime.now();
    final int daysPassed = now.difference(_planStartDate!).inDays;
    final int monthsPassed = daysPassed ~/ 30;

    // Reset mid-month flag if we entered a new month.
    if (monthsPassed > _lastNotifiedMonth) {
      _midMonthNotified = false;
    }

    // Do nothing if less than one month has passed.
    if (daysPassed < 30) return;

    // End-of-month notification (send only once per month end)
    if (daysPassed % 30 == 0 &&
        monthsPassed <= _durationMonths! &&
        monthsPassed > _lastNotifiedMonth) {
      _showNotification(
        title: "نهاية الشهر $monthsPassed من الخطة",
        body: "لقد أتممت شهرًا آخر من خطتك. راجع تقدمك وواصل الادخار!",
      );
      _lastNotifiedMonth = monthsPassed;
      // If the plan is fully complete, send a final notification:
      if (monthsPassed == _durationMonths) {
        _showNotification(
          title: "تهانينا! لقد أكملت الخطة بنسبة 100%",
          body: "لقد وصلت إلى هدف الادخار المحدد. عمل ممتاز!",
        );
      }
    }
  }

  /// Check and send a mid month notification when day 15 of the current plan month is reached.
  void _checkMidMonthNotification() {
    final now = DateTime.now();
    final int daysSincePlanStart = now.difference(_planStartDate!).inDays;
    final int daysPassedInCurrentMonth = daysSincePlanStart % 30;
    final int currentPlanMonthNumber = (daysSincePlanStart ~/ 30) + 1;
    if (daysPassedInCurrentMonth == 15 && !_midMonthNotified) {
      _showNotification(
        title: "منتصف الشهر $currentPlanMonthNumber من الخطة",
        body: "أنت الآن في منتصف الشهر، استمر على هذا المنوال لتحقيق هدفك.",
      );
      _midMonthNotified = true;
    }
  }

  /// Aggregated progress notification (general encouragement)
  void _checkAggregatedProgressNotification() {
    final progress = _calculateOverallProgress();
    if (progress > 0 && !_sentAggregatedMilestones.containsKey(1)) {
      _showNotification(
        title: "تشجيع!", 
        body: "أنت تحقق تقدمًا جيدًا في خطة الادخار الخاصة بك. واصل التقدم!",
      );
      _sentAggregatedMilestones[1] = 1;
    }
  }

  /// Individual category progress notifications (optional)
  void _checkCategoryProgressNotifications() {
    final monthlyProgress = _calculateMonthlyProgress();
    monthlyProgress.forEach((category, progress) {
      int milestone = progress >= 100
          ? 4
          : progress >= 75
              ? 3
              : progress >= 50
                  ? 2
                  : progress > 0
                      ? 1
                      : 0;
      if (milestone > (_sentMilestones[category] ?? 0)) {
        if (milestone > 0) {
          _showNotification(
            title: "تهانينا!",
            body: "لقد أحرزت تقدمًا في فئة $category. تابع التقدم!",
          );
        }
        _sentMilestones[category] = milestone;
      }
    });
  }

  /// Behind-plan reminder (general)
  void _checkBehindPlanNotification() {
    if (_behindPlanNotified) return;
    final progress = _calculateOverallProgress();
    final now = DateTime.now();
    final int daysSincePlanStart = now.difference(_planStartDate!).inDays;
    final double expectedProgress = (daysSincePlanStart % 30) * (100 / 30);
    if (progress < expectedProgress) {
      _showNotification(
        title: "تذكير: راجع خطة الادخار",
        body: "يبدو أنك متأخر قليلًا عن الجدول، راجع تقدمك للبقاء على المسار!",
      );
      _behindPlanNotified = true;
    }
  }

  /// Calculate overall progress (%) against goal
  double _calculateOverallProgress() {
    final Map<String, double> categorySavings = Map<String, double>.from(
      _resultData!['CategorySavings'].map((key, value) =>
          MapEntry(key, (value as num).toDouble())),
    );
    final totalSaved = categorySavings.values.fold(0.0, (a, b) => a + b);
    final goal = (_resultData!['GoalAmount'] as num?)?.toDouble() ?? 0;
    return goal > 0 ? (totalSaved / goal) * 100 : 0;
  }

  /// Calculate progress per category for the current plan month
  Map<String, double> _calculateMonthlyProgress() {
    final Map<String, double> progressPercentage = {};
    if (!_resultData!.containsKey('CategorySavings')) return progressPercentage;

    final List<String> savingPlanCategories = (_resultData!['MonthlySavingsPlan'] as List)
        .map((e) => e['category'] as String)
        .toList();

    final Map<String, double> categorySavings = Map<String, double>.from(
      _resultData!['CategorySavings'].map((key, value) =>
          MapEntry(key, (value as num).toDouble())),
    );

    final DateTime now = DateTime.now();
    final int daysSincePlanStart = now.difference(_planStartDate!).inDays;
    final int daysPassedInCurrentMonth = daysSincePlanStart % 30;
    final double dailyGrowth = 100 / 30;

    for (var category in savingPlanCategories) {
      double progress = daysPassedInCurrentMonth * dailyGrowth;
      progressPercentage[category] = progress.clamp(0, 100);
    }

    return progressPercentage;
  }

  int _milestoneFromProgress(double progress) {
    if (progress == 0) return 0;
    if (progress > 0 && progress < 50) return 1;
    if (progress >= 50 && progress < 75) return 2;
    if (progress >= 75 && progress < 100) return 3;
    if (progress == 100) return 4;
    return 0;
  }

  String _milestoneToString(int milestone) {
    switch (milestone) {
      case 1:
        return "بدأت الادخار";
      case 2:
        return "50% من الهدف";
      case 3:
        return "75% من الهدف";
      case 4:
        return "100% من الهدف";
      default:
        return "";
    }
  }
}


