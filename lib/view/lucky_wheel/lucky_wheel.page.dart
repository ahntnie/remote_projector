import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widget/base_page.dart';

class LuckyWheelPage extends StatefulWidget {
  @override
  _LuckyWheelPageState createState() => _LuckyWheelPageState();
}

class _LuckyWheelPageState extends State<LuckyWheelPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _numbersController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isConnected = false;
  String? _connectedDocumentId;
  StreamSubscription<DocumentSnapshot>? _documentSubscription;

  @override
  void initState() {
    super.initState();
  }

  // Hiển thị dialog lỗi chung
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade300, Colors.orange.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.white,
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kết nối đến mã minigame
  Future<void> _connectToMinigame() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showErrorDialog(
        'Thiếu Mã Minigame',
        'Vui lòng nhập mã minigame để kết nối.',
      );
      return;
    }

    try {
      DocumentSnapshot doc =
          await _firestore.collection('lucky_wheel').doc(code).get();
      if (doc.exists) {
        await _firestore.collection('lucky_wheel').doc(code).update({
          'connect': true,
        });
        setState(() {
          _isConnected = true;
          _connectedDocumentId = code;
        });
        _listenToDocumentChanges(code);
        _showSuccessDialog();
        print('📄 Kết nối thành công đến document $code');
      } else {
        _showErrorDialog(
          'Mã Không Tồn Tại',
          'Mã minigame bạn nhập không tồn tại. Vui lòng kiểm tra lại.',
        );
      }
    } catch (e) {
      _showErrorDialog(
        'Lỗi Kết Nối',
        'Đã xảy ra lỗi khi kết nối: $e',
      );
      print('❌ Lỗi khi kết nối: $e');
    }
  }

  // Lắng nghe sự thay đổi của document
  void _listenToDocumentChanges(String documentId) {
    _documentSubscription?.cancel();
    _documentSubscription = _firestore
        .collection('lucky_wheel')
        .doc(documentId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        setState(() {
          _isConnected = false;
          _connectedDocumentId = null;
          _codeController.clear();
          _numbersController.clear();
        });
        _documentSubscription?.cancel();
        _showErrorDialog(
          'Kết Nối Bị Ngắt',
          'Mã minigame đã bị xóa, kết nối bị ngắt.',
        );
        print('❌ Document $documentId đã bị xóa');
      }
    }, onError: (e) {
      setState(() {
        _isConnected = false;
        _connectedDocumentId = null;
        _codeController.clear();
        _numbersController.clear();
      });
      _documentSubscription?.cancel();
      _showErrorDialog(
        'Lỗi Theo Dõi',
        'Lỗi khi theo dõi document: $e',
      );
      print('❌ Lỗi khi theo dõi document: $e');
    });
  }

  // Ngắt kết nối thủ công
  void _disconnect() {
    setState(() {
      _isConnected = false;
      _connectedDocumentId = null;
      _codeController.clear();
      _numbersController.clear();
    });
    _documentSubscription?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã ngắt kết nối')),
    );
  }

  // Gửi danh sách số
  Future<void> _sendNumbers() async {
    if (!_isConnected || _connectedDocumentId == null) {
      _showErrorDialog(
        'Chưa Kết Nối',
        'Vui lòng kết nối đến mã minigame trước khi gửi.',
      );
      return;
    }

    final numbersInput = _numbersController.text.trim();
    if (numbersInput.isEmpty) {
      _showErrorDialog(
        'Thiếu Danh Sách Số',
        'Vui lòng nhập danh sách số để gửi.',
      );
      return;
    }

    final numbers = numbersInput
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (numbers.isEmpty) {
      _showErrorDialog(
        'Danh Sách Không Hợp Lệ',
        'Danh sách số bạn nhập không hợp lệ.',
      );
      return;
    }

    try {
      await _firestore
          .collection('lucky_wheel')
          .doc(_connectedDocumentId)
          .update({
        'numbers': numbers,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật danh sách số thành công')),
      );
      print('📄 Cập nhật numbers: $numbers cho document $_connectedDocumentId');
    } catch (e) {
      _showErrorDialog(
        'Lỗi Gửi Dữ Liệu',
        'Lỗi khi gửi danh sách số: $e',
      );
      print('❌ Lỗi khi gửi danh sách số: $e');
    }
  }

  // Hiển thị dialog kết nối thành công
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade300, Colors.blue.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 50,
                color: Colors.white,
              ),
              SizedBox(height: 15),
              Text(
                'Kết Nối Thành Công',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Đã kết nối với mã minigame: $_connectedDocumentId',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _numbersController.dispose();
    _documentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BasePage(
        showAppBar: true,
        showLeadingAction: true,
        title: 'Gửi Dữ Liệu Trúng Thưởng'.toUpperCase(),
        onBackPressed: () {
          Navigator.pop(context);
        },
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TextField cho mã minigame
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade200, Colors.purple.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Nhập mã minigame',
                    hintText: 'Ví dụ: 123456',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                  keyboardType: TextInputType.number,
                  enabled: !_isConnected,
                ),
              ),
              SizedBox(height: 16),
              // Nút Kết nối hoặc Ngắt kết nối
              ElevatedButton(
                onPressed: _isConnected ? _disconnect : _connectToMinigame,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isConnected ? Colors.red[700] : Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor:
                      _isConnected ? Colors.red[200] : Colors.blue[200],
                ),
                child: Text(
                  _isConnected ? 'Ngắt Kết Nối' : 'Kết Nối',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 24),
              // TextField cho danh sách số
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade200, Colors.purple.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _numbersController,
                  decoration: InputDecoration(
                    labelText: 'Nhập danh sách số',
                    hintText: 'Ví dụ: 12,13,14,15,16',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              // Nút Gửi
              ElevatedButton(
                onPressed: _sendNumbers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.green[200],
                ),
                child: Text(
                  'Gửi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Trạng thái kết nối
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isConnected ? Colors.green[200]! : Colors.red[200]!,
                  ),
                ),
                child: Text(
                  _isConnected
                      ? '✅ Đã kết nối với mã: $_connectedDocumentId'
                      : '🔍 Chưa kết nối',
                  style: TextStyle(
                    color: _isConnected ? Colors.green[800] : Colors.red[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
