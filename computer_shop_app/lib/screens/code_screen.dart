import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnterCodeDialog extends StatefulWidget {
  final String email; // Pass user email here

  const EnterCodeDialog({Key? key, required this.email}) : super(key: key);

  @override
  _EnterCodeDialogState createState() => _EnterCodeDialogState();
}

class _EnterCodeDialogState extends State<EnterCodeDialog> {
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _codeControllers.length; i++) {
      _codeControllers[i].addListener(() {
        if (_codeControllers[i].text.isNotEmpty && i < _focusNodes.length - 1) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        } else if (i == _focusNodes.length - 1) {
          _focusNodes[i].unfocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var c in _codeControllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String _getEnteredCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  Future<void> _handleConfirm() async {
    final otp = _getEnteredCode();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits')),
      );
      return;
    }

    setState(() => _isConfirming = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/verify-reset-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': otp,
          'new_password': 'temporary', // OTP verification only
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true); // OTP verified
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Invalid OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error, please try again')),
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter 4-digit code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'A code has been sent to your email address.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (i) => SizedBox(
                  width: 50,
                  height: 50,
                  child: TextFormField(
                    controller: _codeControllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: "",
                      fillColor: Colors.grey[100],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF003399),
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    onChanged: (value) {
                      if (value.isNotEmpty && i < _focusNodes.length - 1) {
                        FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                      } else if (value.isEmpty && i > 0) {
                        FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConfirming ? null : _handleConfirm,
                    child: _isConfirming
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Confirm', style: TextStyle(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003399),
                      disabledBackgroundColor: const Color(0xFF003399).withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isConfirming ? null : _handleCancel,
                    child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF003399),
                      side: const BorderSide(color: Color(0xFF003399), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
