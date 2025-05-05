import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math; // ← لأجل تدوير السلايدر
import 'package:flutter/foundation.dart'; // ← for mapEquals

import 'success_plan_page.dart';
import 'custom_icons.dart';

class SavingDisPage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final Map<String, dynamic> resultData; // الخطة المبدئية
  final List<Map<String, dynamic>> accounts; // كل الحسابات + العمليات
  final String startDate; // تاريخ البداية للخطة

  const SavingDisPage({
    super.key,
    required this.userName,
    required this.phoneNumber,
    required this.resultData,
    required this.startDate,
    this.accounts = const [],
  });

  @override
  State<SavingDisPage> createState() => _SavingDisPageState();
}

class _SavingDisPageState extends State<SavingDisPage> {
  // ─────────── المتغيرات العامة ───────────
  final _arabicFmt = NumberFormat("#,##0.00", "ar");
  Color _arrowColor = const Color(0xFF3D3D3D);
  bool _isPressed = false;
  bool _isLoading = false;
  String _errorMsg = '';

  // كل الفئات الممكنة (حسب backend)
  final List<String> _allCats = const [
    'المطاعم',
    'التعليم',
    'الصحة',
    'تسوق',
    'البقالة',
    'النقل',
    'السفر',
    'المدفوعات الحكومية',
    'الترفيه',
    'الاستثمار',
    'الإيجار',
    'القروض',
    'الراتب',
    'التحويلات',
  ];

  // القيم الحالية للتوزيع (0–100)
  late Map<String, double> _cutPercents;

  // النسخ الأصلية (لإعادة الضبط)
  late Map<String, double> _initialPercents;

  // مبالغ الادخار لكل فئة عبر كامل الخطة
  late Map<String, double> _catSavings;

  // محرّرات TextField لكل فئة
  late final Map<String, TextEditingController> _controllers = {
    for (var c in _allCats) c: TextEditingController(),
  };

  // ─────────── initState ───────────
  @override
  void initState() {
    super.initState();

    // 1) استيراد مبالغ الادخار الفعلية وهدف الادخار
    final rawSav =
        widget.resultData['CategorySavings'] as Map<String, dynamic>? ?? {};
    final totalGoal = (widget.resultData['SavingsGoal'] as num).toDouble();

// 2) احسب النسبة بناءً على ما ستوفره من إجمالي الهدف
    _cutPercents = {
      for (var c in _allCats)
        // compute full-precision
        c: ((rawSav[c] ?? 0.0) / totalGoal * 100.0)
    };

// 3) مبالغ الادخار كما هي
    _catSavings = {
      for (var c in _allCats) c: (rawSav[c] ?? 0.0).toDouble(),
    };

    // 4) حفظ نسخة أصلية لإعادة الضبط
    _initialPercents = Map.from(_cutPercents);

    // 5) ضبط محرّرات النص
    // set controllers to show e.g. 4 decimal places
    _controllers.forEach((cat, ctl) {
      ctl.text = '${_cutPercents[cat]!.toStringAsFixed(4)}%';
    });
  }

  double _totalPercent() => _cutPercents.values.fold(0.0, (a, b) => a + b);

  void _updatePercent(String cat, double newVal) {
    setState(() {
      final oldVal = _cutPercents[cat]!;
      final remOld = _totalPercent() - oldVal;
      final remNew = 100.0 - newVal;
      final scale = remOld > 0 ? remNew / remOld : 0.0;

      _cutPercents.updateAll((key, val) {
        return key == cat ? newVal : val * scale;
      });

      // correct any tiny floating-point drift so sum == 100
      final diff = 100.0 - _totalPercent();
// أزل شرط الـ if وأضف diff دائماً:
      final maxKey = _cutPercents.entries
          .where((e) => e.key != cat)
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      _cutPercents[maxKey] = _cutPercents[maxKey]! + diff;

      // update text controllers, preserving 4 decimals
      _cutPercents.forEach((key, val) {
        _controllers[key]!.text = '${val.toStringAsFixed(4)}%';
      });

      // recompute savings amounts
      final totalGoal = widget.resultData['SavingsGoal'] as double;
      _catSavings = {
        for (var key in _allCats)
          key: double.parse(
              (totalGoal * _cutPercents[key]! / 100.0).toStringAsFixed(2))
      };
    });
  }

  void _resetAll() {
    setState(() {
      _cutPercents = Map.from(_initialPercents);
      _cutPercents.forEach((c, v) {
        _controllers[c]!.text = '${v.toStringAsFixed(4)}%';
      });
      // إعادة حساب مبالغ الادخار على القيم الأصلية
      final totalGoal = widget.resultData['SavingsGoal'] as double;
      _catSavings = {
        for (var key in _allCats)
          key: double.parse(
              (totalGoal * _cutPercents[key]! / 100.0).toStringAsFixed(2))
      };
    });
  }

  // ─────────── إرسال التعديلات إلى السيرفر ───────────
  Future<void> _saveAndRebuildPlan() async {
    // 1) تحقق إن كان المستخدم غيّر أي نسبة
    final hasChanged = !mapEquals(
      _cutPercents.map((k, v) => MapEntry(k, v.toStringAsFixed(4))),
      _initialPercents.map((k, v) => MapEntry(k, v.toStringAsFixed(4))),
    );

    // 2) إذا ما فيه تغيير، ننتقل مباشرةً مع الخريطة الأصلية + startDate + Schedule (إن وجدت)
    if (!hasChanged) {
      final planWithDate = {
        ...widget.resultData,
        'startDate': widget.startDate,
        'Schedule': widget.resultData['Schedule'],
      };
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessPlanPage(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
            resultData: planWithDate,
          ),
        ),
      );
      return;
    }

    // 3) خلاف ذلك، نرسل التعديلات للسيرفر
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    // تحويل النسب إلى صيغة 0–1
    final customCuts = {for (var c in _allCats) c: (_cutPercents[c]! / 100.0)};

    // جمع المعاملات
    final List<Map<String, dynamic>> tx = [];
    for (var acc in widget.accounts) {
      if (acc.containsKey('transactions')) {
        for (var t in acc['transactions']) {
          tx.add({
            "TransactionId": t["TransactionId"],
            "Date": t["TransactionDateTime"],
            "TransactionType": t["SubTransactionType"],
            "TransactionInformation": t["TransactionInformation"],
            "Amount": t["Amount"],
            "Category": t["Category"],
          });
        }
      }
    }

    try {
      final uri = Uri.parse("https://flask-app.ngrok.io/run-script");
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "transactions": tx,
          "goal": widget.resultData["SavingsGoal"],
          "duration_months": widget.resultData["DurationMonths"],
          "start_date": widget.startDate,
          "custom_cuts": customCuts,
        }),
      );

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || !(decoded["success"] ?? false)) {
        throw decoded["error"] ?? decoded["message"] ?? "Server error";
      }

      // استخرج البيانات من الاستجابة
      final data = decoded["data"] as Map<String, dynamic>;

      // اجمع الخطة الجديدة، حقن startDate و Schedule
      final newPlan = {
        ...data,
        'startDate': widget.startDate,
        'Schedule': data['Schedule'],
      };

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessPlanPage(
            userName: widget.userName,
            phoneNumber: widget.phoneNumber,
            accounts: widget.accounts,
            resultData: newPlan,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMsg = "حدث خطأ أثناء حفظ التعديلات: $e";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────── واجهة المستخدم ───────────
  @override
  Widget build(BuildContext context) {
    final totalPct = _totalPercent();
    // consider it valid if it’s within 0.0001 of 100
    final valid = (_totalPercent() - 100).abs() < 0.1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // زر الرجوع
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child:
                  Icon(Icons.arrow_forward_ios, color: _arrowColor, size: 28),
            ),
          ),

          // العنوان والوصف ...
          const Positioned(
            top: 58,
            left: 150,
            child: Text('توزيع خطة الإدخار',
                style: TextStyle(
                    color: Color(0xFF3D3D3D),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GE-SS-Two-Bold')),
          ),
          const Positioned(
            left: 28,
            top: 114,
            child: Text(
              'قمنا بتوزيع خطة الإدخار الخاصة بك على هذا الشكل بناءً على \nالنمط المدروس من قبلنا',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const Positioned(
            left: 82,
            top: 152,
            child: Text(
              ' :اذا كنت تريد تعديل هذا التوزيع \n'
              '. قم بسحب المؤشر إلى اليمين أو اليسار   \n\n'
              '. هذه النسب والمبالغ هي لكامل الخطة على مدى كل أشهر الخطة  \n',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 10,
                fontFamily: 'GE-SS-Two-Light',
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // زر إعادة الضبط
          Positioned(
            left: 22,
            top: 236,
            child: GestureDetector(
              onTap: _resetAll,
              child: const Icon(Icons.restart_alt_rounded,
                  color: Color(0xFF3D3D3D), size: 28),
            ),
          ),

          // القائمة
          Positioned(
            top: 265,
            left: 0,
            right: 0,
            bottom: 145,
            child: SingleChildScrollView(
              child: Column(
                children: _allCats.map(_buildCatRow).toList(),
              ),
            ),
          ),

          // تحذير إذا لم يساو 100%
          if (!valid)
            Positioned(
              left: 90,
              top: 245,
              child: Text(
                'يجب أن يساوى المجموع ١٠٠٪ (الحالي ${totalPct.toStringAsFixed(2)}٪)',
                style: const TextStyle(
                    color: Color(0xFFDD2C35),
                    fontSize: 11,
                    fontFamily: 'GE-SS-Two-Light'),
              ),
            ),

          // زر حفظ
          Positioned(
            left: 61,
            top: 710,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTap: valid && !_isLoading ? _saveAndRebuildPlan : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 274,
                height: 45,
                decoration: BoxDecoration(
                  color:
                      valid ? const Color(0xFF3D3D3D) : const Color(0xFF838383),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3)
                      : Text('حفظ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'GE-SS-Two-Light')),
                ),
              ),
            ),
          ),

          // رسالة خطأ
          if (_errorMsg.isNotEmpty)
            Positioned(
              bottom: 90,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFC62C2C),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_errorMsg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'GE-SS-Two-Light')),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────── صف الفئة ───────────
  Widget _buildCatRow(String cat) {
    // 1) determine if this row should be disabled
    final isDisabled = (_catSavings[cat] ?? 0.0) == 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Container(
        width: 352,
        height: 55,
        decoration: BoxDecoration(
          // pale background when disabled
          color: isDisabled ? const Color(0xFFE0E0E0) : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(children: [
          // Category name
          Positioned(
            left: 260,
            top: 19,
            child: SizedBox(
              width: 80,
              child: Text(
                cat == 'المدفوعات الحكومية' ? 'المدفوعات\nالحكومية' : cat,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isDisabled
                      ? const Color(0xFF9E9E9E) // greyed out
                      : const Color(0xFF3D3D3D),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GE-SS-Two-Bold',
                ),
              ),
            ),
          ),

          // % label
          Positioned(
            left: 95,
            top: 19,
            child: Text(
              '${_cutPercents[cat]!.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isDisabled
                    ? const Color(0xFF9E9E9E)
                    : const Color(0xFF3D3D3D),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),

          // Slider
          Positioned(
            left: 130,
            top: 26,
            child: SizedBox(
              width: 160,
              height: 4,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Slider(
                  value: _cutPercents[cat]!.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: isDisabled
                      ? null // disable interaction
                      : (v) => _updatePercent(cat, v),
                  activeColor: isDisabled
                      ? const Color(0xFFBDBDBD)
                      : const Color(0xFF2C8C68),
                  inactiveColor: isDisabled
                      ? const Color(0xFFBDBDBD)
                      : const Color(0xFF838383),
                ),
              ),
            ),
          ),

          // Savings amount
          Positioned(
            left: 5,
            top: 16,
            child: Row(children: [
              const Icon(CustomIcons.riyal, size: 14, color: Color(0xFF3D3D3D)),
              const SizedBox(width: 4),
              Text(
                _arabicFmt.format(_catSavings[cat] ?? 0.0),
                style: const TextStyle(
                  color: Color(0xFF3D3D3D),
                  fontSize: 17,
                  fontFamily: 'GE-SS-Two-Bold',
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
