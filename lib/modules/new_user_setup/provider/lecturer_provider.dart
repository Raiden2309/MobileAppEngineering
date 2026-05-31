import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/lecturer_model.dart';

class LecturerProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LecturerModel? lecturer;
  bool loading = false;
  String? error;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> fetch() async {
    if (_uid == null) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final doc = await _db.collection('lecturers').doc(_uid).get();
      if (doc.exists && doc.data() != null) {
        lecturer = LecturerModel.fromJson(doc.data()!);
      }
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> save(LecturerModel model) async {
    if (_uid == null) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _db.collection('lecturers').doc(_uid).set(model.toJson());
      lecturer = model;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<String> generateJoinCode(String subjectName) async {
    if (_uid == null) return '';
    loading = true;
    error = null;
    notifyListeners();
    try {
      final code = _generateCode();
      await _db.collection('join_codes').doc(code).set({
        'lecturerUid': _uid,
        'subjectName': subjectName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      loading = false;
      notifyListeners();
      return code;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return '';
    }
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void setLecturer(LecturerModel model) {
    lecturer = model;
    notifyListeners();
  }

  void clear() {
    lecturer = null;
    error = null;
    notifyListeners();
  }
}