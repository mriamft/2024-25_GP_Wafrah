// global_notification_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class GlobalNotificationManager {
  // Singleton pattern
  static final GlobalNotificationManager _instance =
      GlobalNotificationManager._internal();
  factory GlobalNotificationManager() => _instance;
  GlobalNotificationManager._internal();

  Timer? _timer;
    // For aggregated notifications:
  // For each milestone (1: >0 & <50, 2: 50%-<75, 3: 75%-<100, 4: 100%)
  // we store the last count notified.
  final Map<int, int> _sentAggregatedMilestones = {};

  // Track the last plan month for which a month-end notification was sent.
  int _lastNotifiedMonth = 0;
  // Track if mid-month notification has been sent in the current plan month.
  bool _midMonthNotified = false;
  // For each category, store the last notified milestone for the current month.
  // (Milestones: 0 = 0%, 1 = >0% & <50%, 2 = 50%-<75%, 3 = 75%-<100%, 4 = 100%)
  final Map<String, int> _sentMilestones = {};

  // These will be updated when a user’s saving plan data becomes available.
  Map<String, dynamic>? _resultData;
  List<Map<String, dynamic>>? _accounts;
  DateTime? _planStartDate;
  int? _durationMonths;

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
      _durationMonths = (resultData['DurationMonths'] is int)
          ? resultData['DurationMonths']
          : (resultData['DurationMonths'] as num).toInt();
    }
    // Reset notifications tracking whenever plan data is updated.
        _sentAggregatedMilestones.clear();

    _sentMilestones.clear();
    _lastNotifiedMonth = 0;
  }

  /// Clear the saved data when there is no plan.
  void clearData() {
    _resultData = null;
    _accounts = null;
    _planStartDate = null;
    _durationMonths = null;
    _sentAggregatedMilestones.clear();
    _lastNotifiedMonth = 0;
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
      (_resultData!['MonthlySavingsPlan'] is List &&
       (_resultData!['MonthlySavingsPlan'] as List).isEmpty) ||
      !_resultData!.containsKey('CategorySavings')) {
    NotificationService.showNotification(
      title: "لا توجد خطة ادخار!",
      body: "لم تقم بإضافة خطة ادخار بعد. انضم إلينا وابدأ خطتك الآن!",
    );
    return;
  }

  // Otherwise, proceed with your normal notification checks.
  _checkMonthEndNotification();
  _checkMidMonthNotification();
  _checkAggregatedCategoryProgressNotifications();
  _checkCategoryProgressNotifications();
}

  /// Calculate progress for the **current plan month** only.
  Map<String, double> _calculateMonthlyProgress() {
    final Map<String, double> progressPercentage = {};
    
    // Ensure we have saving plan data with at least the "CategorySavings" field.
    if (!_resultData!.containsKey('CategorySavings')) return progressPercentage;
    
    // Extract the list of categories that are in the saving plan.
    List<String> savingPlanCategories = [];
    if (_resultData!.containsKey('MonthlySavingsPlan')) {
      savingPlanCategories = (_resultData!['MonthlySavingsPlan'] as List<dynamic>)
          .map((e) => e['category'] as String)
          .toList();
    }
    
    // Get the savings assigned per category (from the plan).
    final Map<String, double> categorySavings = Map<String, double>.from(
      _resultData!['CategorySavings'].map((key, value) =>
          MapEntry(key, (value as num).toDouble())),
    );
    
    // Filter to only include categories from the saving plan.
    final filteredCategorySavings = Map<String, double>.fromEntries(
      categorySavings.entries.where((entry) => savingPlanCategories.contains(entry.key))
    );
    
    final DateTime now = DateTime.now();
    final int daysSincePlanStart = now.difference(_planStartDate!).inDays;
    // Determine which plan month we're in (0-indexed).
    final int currentPlanMonthIndex = daysSincePlanStart ~/ 30;
    // Compute the days passed in the current month (range 0 to 30).
    final int daysPassedInCurrentMonth = daysSincePlanStart % 30;
    final double dailyProgressGrowth = 100 / 30;

    // Now calculate progress for each category in the saving plan.
    filteredCategorySavings.forEach((category, _) {
      double progress = daysPassedInCurrentMonth * dailyProgressGrowth;
      // Optionally: compare spending from last year vs. current month.
      // For the current month, define its start date:
      final DateTime currentMonthStart =
          _planStartDate!.add(Duration(days: currentPlanMonthIndex * 30));
      
      double lastYearSpending = _calculateCategorySpendingForPeriod(
        category,
        currentMonthStart.subtract(const Duration(days: 365)),
        currentMonthStart.add(const Duration(days: 30)).subtract(const Duration(seconds: 15)),
      );
      double currentSpending = _calculateCategorySpendingForPeriod(
        category,
        currentMonthStart,
        now,
      );
      // If spending in the current month is higher than last year’s equivalent month,
      // then we “reset” progress (or set it to zero).
      if ((lastYearSpending - currentSpending) < 0) {
        progress = 0;
      }
      progressPercentage[category] = progress.clamp(0, 100);
    });
    return progressPercentage;
  }

  /// Helper to calculate spending for a category between two dates.
  double _calculateCategorySpendingForPeriod(
      String category, DateTime start, DateTime end) {
    double spending = 0.0;
    for (var account in _accounts!) {
      final transactions = account['transactions'] ?? [];
      for (var transaction in transactions) {
        final transactionCategory = transaction['Category'] ?? 'Unknown';
        if (transactionCategory != category) continue;
        final transactionDate =
            DateTime.tryParse(transaction['TransactionDateTime'] ?? '') ?? DateTime.now();
        if (transactionDate.isAfter(start) && transactionDate.isBefore(end)) {
          double amount =
              double.tryParse(transaction['Amount']?.toString() ?? '0') ?? 0.0;
          spending += amount;
        }
      }
    }
    return spending;
  }

  /// Check and send a month‑end notification if a full 30‑day period has passed.
  /// Check and send a month‑end notification if a full 30‑day period has passed.
  void _checkMonthEndNotification() {
    final DateTime now = DateTime.now();
    final int daysPassed = now.difference(_planStartDate!).inDays;
    final int totalMonths = _durationMonths!;
    final int monthsPassed = daysPassed ~/ 30;

    // Reset mid-month flag if we entered a new month.
    if (monthsPassed > _lastNotifiedMonth) {
      _midMonthNotified = false;
    }

    // Do nothing if less than one month has passed.
    if (daysPassed < 30) return;

    // End-of-month notification (send only once per month end)
    if (daysPassed % 30 == 0 &&
        monthsPassed <= totalMonths &&
        monthsPassed > _lastNotifiedMonth) {
      NotificationService.showNotification(
        title: "لقد أكملت الشهر $monthsPassed من $totalMonths شهور من الخطة",
        body: "في هذا الشهر أنجزت ${(monthsPassed / totalMonths * 100).toStringAsFixed(2)}% من الخطة. استمر في العمل!",
      );
      _lastNotifiedMonth = monthsPassed;
      // If the plan is fully complete, send a final notification:
      if (monthsPassed == totalMonths) {
        NotificationService.showNotification(
          title: "تهانينا! لقد أكملت الخطة بنسبة 100%",
          body: "لقد أنجزت كل أهداف الادخار المحددة. مبروك!",
        );
      }
    }
  }
    /// Check and send a mid‑month notification when day 15 of the current plan month is reached.
  void _checkMidMonthNotification() {
    final DateTime now = DateTime.now();
    final int daysSincePlanStart = now.difference(_planStartDate!).inDays;
    final int daysPassedInCurrentMonth = daysSincePlanStart % 30;
    // Determine the current plan month (1-indexed)
    final int currentPlanMonthNumber = (daysSincePlanStart ~/ 30) + 1;
    // If it is the 15th day (or very close) and mid-month notification hasn't been sent
    if (daysPassedInCurrentMonth == 15 && !_midMonthNotified) {
      // For percentage achieved in the current month, we assume 15*dailyGrowth.
      double progress = (15 * (100 / 30)).clamp(0, 100);
      NotificationService.showNotification(
        title: "أنت في منتصف الشهر $currentPlanMonthNumber من الخطة",
        body: "لقد أنجزت ${progress.toStringAsFixed(2)}% من هدف هذا الشهر. استمر في العمل!",
      );
      _midMonthNotified = true;
    }
  }

  /// Helper to determine milestone based on progress value.
  int _milestoneFromProgress(double progress) {
    if (progress == 0) return 0;
    if (progress > 0 && progress < 50) return 1;
    if (progress >= 50 && progress < 75) return 2;
    if (progress >= 75 && progress < 100) return 3;
    if (progress == 100) return 4;
    return 0;
  }

void _checkAggregatedCategoryProgressNotifications() {
  final monthlyProgress = _calculateMonthlyProgress();
  final int totalCategories = monthlyProgress.length;
  // For milestones 1, 2, 3, and 4, count how many categories have reached at least that milestone.
  for (int milestone = 1; milestone <= 4; milestone++) {
    int count = monthlyProgress.values
        .where((progress) => _milestoneFromProgress(progress) >= milestone)
        .length;
    // Get the previously notified count for this milestone (default 0)
    int prevCount = _sentAggregatedMilestones[milestone] ?? 0;
    // If the count increased, send a new notification reflecting all categories that reached this milestone.
    if (count > prevCount) {
      String milestoneText;
      String bodyText;
      switch (milestone) {
        case 1:
          milestoneText = "بدأت الادخار";
          bodyText = "أنت على الطريق الصحيح! حاول زيادة المدخرات لتحقيق الهدف.";
          break;
        case 2:
          milestoneText = "أكملت 50%";
          bodyText = "أنت في منتصف الطريق! استمر في العمل لتحقيق الهدف.";
          break;
        case 3:
          milestoneText = "أنت قريب جداً من الهدف";
          bodyText = "لقد أكملت 75% من هدفك في هذه الفئات. قريباً ستصل!";
          break;
        case 4:
          milestoneText = "تمت الخطة بنجاح";
          bodyText = "تهانينا! لقد أكملت 100% من هدف الادخار في هذه الفئات.";
          break;
        default:
          milestoneText = "";
          bodyText = "";
      }
      NotificationService.showNotification(
        title: "لقد $milestoneText في $count فئة من أصل $totalCategories فئات",
        body: bodyText,
      );
      // Update the stored count so that future notifications reflect any further increase.
      _sentAggregatedMilestones[milestone] = count;
    }
  }
}



  /// Check each category’s progress (only for categories in the saving plan and for the current month)
  /// and send a notification if a new milestone is reached.
 void _checkCategoryProgressNotifications() {
   final Map<String, double> monthlyProgress = _calculateMonthlyProgress();
   monthlyProgress.forEach((category, progress) {
     int currentMilestone;
     if (progress == 0) {
       currentMilestone = 0;
     } else if (progress > 0 && progress < 50) {
       currentMilestone = 1;
     } else if (progress >= 50 && progress < 75) {
       currentMilestone = 2;
     } else if (progress >= 75 && progress < 100) {
       currentMilestone = 3;
     } else if (progress == 100) {
       currentMilestone = 4;
     } else {
       currentMilestone = 0;
     }

     // If the category has never been notified before, send notification (even for 0%).
     if (!_sentMilestones.containsKey(category)) {
       final delay = Duration(seconds: _sentMilestones.length * 5);
       Future.delayed(delay, () {
         NotificationService.showNotification(
           title: _getCategoryNotificationTitle(category, currentMilestone),
           body: _getCategoryNotificationBody(category, currentMilestone),
         );
       });
       _sentMilestones[category] = currentMilestone;
     } else {
       final int previousMilestone = _sentMilestones[category]!;
       // Only send a notification if the current milestone is higher than what was already notified.
       if (currentMilestone > previousMilestone) {
         final delay = Duration(seconds: _sentMilestones.length * 5);
         Future.delayed(delay, () {
           NotificationService.showNotification(
             title: _getCategoryNotificationTitle(category, currentMilestone),
             body: _getCategoryNotificationBody(category, currentMilestone),
           );
         });
         _sentMilestones[category] = currentMilestone;
       }
     }
   });
 }

  String _getCategoryNotificationTitle(String category, int milestone) {
    switch (milestone) {
      case 1:
        return "لقد بدأت الادخار في فئة $category";
      case 2:
        return "لقد أكملت 50% من الادخار في فئة $category";
      case 3:
        return "أنت قريب جداً من الهدف في فئة $category!";
      case 4:
        return "تمت الخطة بنجاح في فئة $category!";
      default:
        return "تنبيه في فئة $category";
    }
  }

  String _getCategoryNotificationBody(String category, int milestone) {
    switch (milestone) {
      case 1:
        return "أنت على الطريق الصحيح! حاول زيادة المدخرات لتحقيق الهدف.";
      case 2:
        return "أنت في منتصف الطريق! استمر في العمل لتحقيق الهدف.";
      case 3:
        return "لقد أكملت 75% من هدفك في هذه الفئة. قريباً ستصل!";
      case 4:
        return "تهانينا! لقد أكملت 100% من هدف الادخار في هذه الفئة.";
      default:
        return "ابدأ الادخار في فئة $category لتحقيق هدفك.";
    }
  }
}

