import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  String userName; // Make userName mutable if you want to update it
  final String phoneNumber;

  ProfilePage({
    super.key,
    required this.userName,
    required this.phoneNumber,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Color _arrowColor = const Color(0xFF3D3D3D);
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
  }

  void _onArrowTap() {
    setState(() => _arrowColor = Colors.grey);
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _arrowColor = const Color(0xFF3D3D3D));
      Navigator.pop(context);
    });
  }

  // Show a dialog to edit the user's name
  void _showEditNameDialog() {
    // Ensure the controller text is the current userName
    _nameController.text = widget.userName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'تعديل الاسم',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'GE-SS-Two-Bold',
              fontSize: 18,
              color: Color(0xFF3D3D3D),
            ),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الجديد',
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      color: Color(0xFF838383),
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 20),
                TextButton(
                  child: const Text(
                    'تعديل',
                    style: TextStyle(
                      fontFamily: 'GE-SS-Two-Light',
                      color: Color(0xFF2C8C68),
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () async {
                    String newName = _nameController.text.trim();
                    if (newName.isNotEmpty) {
                      // (1) Update DB or storage if needed
                      // await _updateNameInDatabase(newName);

                      // (2) Update the local widget userName
                      setState(() {
                        widget.userName = newName;
                      });
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // (Optional) Example for DB update
  Future<void> _updateNameInDatabase(String newName) async {
    // Implement your own DB update logic (API call, local storage, etc.)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Back arrow at top-right
          Positioned(
            top: 60,
            right: 15,
            child: GestureDetector(
              onTap: _onArrowTap,
              child: Icon(
                Icons.arrow_forward_ios,
                color: _arrowColor,
                size: 28,
              ),
            ),
          ),

          // Page title at top-left
          const Positioned(
            top: 58,
            left: 145,
            child: Text(
              'الحساب الشخصي',
              style: TextStyle(
                color: Color(0xFF3D3D3D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'GE-SS-Two-Bold',
              ),
            ),
          ),

          // Gray rectangle (364x148)
          Positioned(
            top: 150,
            left: 14,
            child: Container(
              width: 364,
              height: 148,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // "الاسم" label
                  const Positioned(
                    top: 20,
                    left: 310,
                    child: Text(
                      'الاسم',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F5F5F),
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                    ),
                  ),

                  // Row with the edit icon on the left, and the user name on the right
                  Positioned(
                    top: 41,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // The edit icon (on the left)
                        GestureDetector(
                          onTap: _showEditNameDialog,
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF3D3D3D),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // The user's name (on the right)
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GE-SS-Two-Bold',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // "رقم الجوال" label
                  const Positioned(
                    top: 78,
                    left: 277,
                    child: Text(
                      'رقم الجوال',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F5F5F),
                        fontFamily: 'GE-SS-Two-Light',
                      ),
                    ),
                  ),

                  // phone number
                  Positioned(
                    top: 99,
                    left: 235,
                    child: Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GE-SS-Two-Bold',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // "الحساب الشخصي" label near the top
          const Positioned(
            top: 127,
            left: 268,
            child: Text(
              'الحساب الشخصي',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5F5F5F),
                fontFamily: 'GE-SS-Two-Light',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
