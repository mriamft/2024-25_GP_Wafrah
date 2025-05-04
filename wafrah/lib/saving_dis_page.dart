import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math; // ← أضف هذا السطر مع بقيّة الاستيرادات

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
  bool _isLoading = false; // ⬅ مؤشر التحميل
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

  // القيم الحالية لعامل القطع (0-100)
  late Map<String, int> _cutPercents;

  // النسخ الأصلية (لإعادة الضبط)
  late Map<String, int> _initialPercents;

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

    // 1) استيراد القيم المبدئية من resultData
    final rawPerc = widget.resultData['CategoryCutFactors'] ?? {};
    final rawSav = widget.resultData['CategorySavings'] ?? {};

    _cutPercents = {
      for (var c in _allCats) c: ((rawPerc[c] ?? 0.0) * 100).round()
    };
    _catSavings = {for (var c in _allCats) c: (rawSav[c] ?? 0.0).toDouble()};

    // حفظ نسخة أصلية
    _initialPercents = Map.from(_cutPercents);

    // ضبط المحرّرات بالنِّسب المئوية
    _controllers.forEach((cat, ctl) {
      ctl.text = '%${_cutPercents[cat]}';
    });
  }

  // ─────────── أدوات مساعدة ───────────
  double _totalPercent() =>
      _cutPercents.values.fold(0, (a, b) => a + b).toDouble();

  void _updatePercent(String cat, double newVal) {
    setState(() {
      _cutPercents[cat] = newVal.round();
      _controllers[cat]!.text = '%${_cutPercents[cat]}';
      // المبلغ يُحدَّث فى السيرفر بعد إعادة البناء، لذا لا نعيد حسابه هنا
    });
  }

  void _resetAll() {
    setState(() {
      _cutPercents = Map.from(_initialPercents);
      _cutPercents.forEach((c, v) => _controllers[c]!.text = '%$v');
    });
  }

  // ─────────── إرسال التعديلات إلى السيرفر ───────────
  Future<void> _saveAndRebuildPlan() async {
    if (_totalPercent() != 100) return;

    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    // 1) custom_cuts = نسب/100
    final Map<String, double> customCuts = {
      for (var c in _allCats) c: (_cutPercents[c]! / 100.0)
    };

    // 2) جمع كل العمليات فى قائمة واحدة
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
          "custom_cuts": customCuts, // ★ الجديد
        }),
      );

      final decoded = jsonDecode(res.body);
      if (res.statusCode != 200 || !(decoded["success"] ?? false)) {
        throw decoded["error"] ?? decoded["message"] ?? "Server error";
      }

      // 3) النجاح → خطة محدَّثة
      final newPlan = decoded["data"] as Map<String, dynamic>;

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
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  // ─────────── واجهة المستخدم ───────────
  @override
  Widget build(BuildContext context) {
    final totalPct = _totalPercent();
    final valid = totalPct == 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // ↩ رجوع
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child:
                  Icon(Icons.arrow_forward_ios, color: _arrowColor, size: 28),
            ),
          ),

          // العنوان
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
            left: 63,
            top: 152,
            child: Text(
              ' :اذا كنت تريد تعديل هذا التوزيع \n'
              '. قم بسحب المؤشر إلى اليمين أو اليسار أو إدخال النسبة المئوية لكل فئة  \n\n'
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

          // القائمة القابلة للتمرير
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

          // تحذير مجموع ≠ 100
          if (!valid)
            Positioned(
              left: 90,
              top: 245,
              child: Text(
                  'يجب أن يساوى المجموع ١٠٠٪ (الحالى ${totalPct.toInt()}٪)',
                  style: const TextStyle(
                      color: Color(0xFFDD2C35),
                      fontSize: 11,
                      fontFamily: 'GE-SS-Two-Light')),
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

          // رسالة خطأ إن وُجِدت
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

  // ─────────── عنصر صف الفئة ───────────
  Widget _buildCatRow(String cat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Container(
        width: 352,
        height: 55,
        decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(8)),
        child: Stack(children: [
          // اسم الفئة
          Positioned(
            left: 260,
            top: 19,
            child: SizedBox(
              width: 80,
              child: Text(
                  cat == 'المدفوعات الحكومية' ? 'المدفوعات\nالحكومية' : cat,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GE-SS-Two-Bold')),
            ),
          ),

          // Slider (0-100)
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
                  onChanged: (v) => _updatePercent(cat, v),
                  activeColor: const Color(0xFF2C8C68),
                  inactiveColor: const Color(0xFF838383),
                ),
              ),
            ),
          ),

          // مربع الإدخال اليدوى
          Positioned(
            left: 95,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF8D8D8D)),
                  borderRadius: BorderRadius.circular(5)),
              child: SizedBox(
                width: 35,
                height: 34,
                child: TextField(
                  controller: _controllers[cat],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontFamily: 'GE-SS-Two-Light'),
                  decoration: const InputDecoration(border: InputBorder.none),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (val) {
                    final parsed = int.tryParse(val.replaceAll('%', ''));
                    if (parsed != null && parsed >= 0 && parsed <= 100) {
                      _updatePercent(cat, parsed.toDouble());
                    }
                  },
                ),
              ),
            ),
          ),

          // مبلغ الادخار
          Positioned(
            left: 24,
            top: 16,
            child: Row(children: [
              const Icon(CustomIcons.riyal, size: 14, color: Color(0xFF3D3D3D)),
              const SizedBox(width: 4),
              Text(_arabicFmt.format(_catSavings[cat] ?? 0.0),
                  style: const TextStyle(
                      color: Color(0xFF3D3D3D),
                      fontSize: 17,
                      fontFamily: 'GE-SS-Two-Bold')),
            ]),
          ),
        ]),
      ),
    );
  }
}
