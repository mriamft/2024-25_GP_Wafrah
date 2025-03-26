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
  // For each category, store the last notified milestone for the current month.
  // (Milestones: 0 = 0%, 1 = >0% & <50%, 2 = 50%-<75%, 3 = 75%-<100%, 4 = 100%)
  final Map<String, int> _sentMilestones = {};

  // Track the last plan month for which a month-end notification was sent.
  int _lastNotifiedMonth = 0;

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
    _sentMilestones.clear();
    _lastNotifiedMonth = 0;
  }

  /// Clear the saved data when there is no plan.
  void clearData() {
    _resultData = null;
    _accounts = null;
    _planStartDate = null;
    _durationMonths = null;
    _sentMilestones.clear();
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
    // Do nothing if no saving plan data exists.
    if (_resultData == null ||
        _planStartDate == null ||
        _accounts == null ||
        _durationMonths == null) {
      return;
    }
    // Check both month-end and category milestone notifications.
    _checkMonthEndNotification();
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
  void _checkMonthEndNotification() {
    final DateTime now = DateTime.now();
    final int daysPassed = now.difference(_planStartDate!).inDays;
    final int totalMonths = _durationMonths!;
    final int monthsPassed = daysPassed ~/ 30;

    // Do nothing if less than one month has passed.
    if (daysPassed < 30) return;

    if (daysPassed % 30 == 0 &&
        monthsPassed <= totalMonths &&
        monthsPassed > _lastNotifiedMonth) {
      NotificationService.showNotification(
        title: "لقد أكملت الشهر $monthsPassed من $totalMonths شهور من الخطة",
        body: "في هذا الشهر أنجزت ${(monthsPassed / totalMonths * 100).toStringAsFixed(2)}% من الخطة. استمر في العمل!",
      );
      _lastNotifiedMonth = monthsPassed;
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
