import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/views/login_page.dart';
import '../models/lecturer_settings_model.dart';

class LecturerSettingsProvider extends ChangeNotifier {
  final FirebaseFirestore _db      = FirebaseFirestore.instance;
  final FirebaseAuth      _auth    = FirebaseAuth.instance;
  final FirebaseStorage   _storage = FirebaseStorage.instance;
  static const _secureStorage      = FlutterSecureStorage();

  static const _keyBurnoutAlerts      = 'lec_burnout_alerts';
  static const _keyFallingBehindAlerts= 'lec_falling_behind_alerts';
  static const _keyWeeklyEngagement   = 'lec_weekly_engagement_report';
  static const _keyAvatarUrl          = 'lec_avatar_url';

  LecturerSettingsModel? data;
  bool    burnoutAlerts          = false;
  bool    fallingBehindAlerts    = false;
  bool    weeklyEngagementReport = false;
  String? avatarUrl;
  bool    loading = false;
  String? error;

  StreamSubscription? _userSubscription;

  String? get _uid => _auth.currentUser?.uid;

  LecturerSettingsProvider() {
    initLiveListeners();
  }

  /// INITIALIZES LIVE LISTENERS: Links directly to the master users collection document for real-time name parsing
  void initLiveListeners() async {
    final uid = _uid;
    if (uid == null) return;

    loading = true;
    notifyListeners();

    await _loadFromCache();

    // Attach real-time stream pipeline directly into your core users collection profiles
    _userSubscription?.cancel();
    _userSubscription = _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((userSnapshot) {

      if (userSnapshot.exists && userSnapshot.data() != null) {
        final userData = userSnapshot.data()!;
        final String liveProfileName = userData['name']?.toString() ?? 'Lecturer Account';
        final String dept = userData['programme']?.toString() ?? userData['department']?.toString() ?? 'Faculty Portal';

        // Rebuild settings model leveraging database values explicitly over layout mocks
        data = LecturerSettingsModel(
          userId: uid.hashCode.abs(),
          userName: liveProfileName, // Captures authentic name cleanly from Firebase mapping pipelines
          department: dept,
          activeClassesCount: 3,
          burnoutAlerts: burnoutAlerts,
          fallingBehindAlerts: fallingBehindAlerts,
          weeklyEngagementReport: weeklyEngagementReport,
          appVersion: 'v1.0',
          avatarUrl: avatarUrl,
        );

        loading = false;
        error = null;
        notifyListeners();
      }
    }, onError: (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> load() async {
    initLiveListeners();
  }

  void loadMock() {
    initLiveListeners(); // Bypasses mockData assignment models entirely to block static records
  }

  void _applyFromJson(Map<String, dynamic> json) {
    data                   = LecturerSettingsModel.fromJson(json);
    avatarUrl              = data!.avatarUrl;
    burnoutAlerts          = data!.burnoutAlerts;
    fallingBehindAlerts    = data!.fallingBehindAlerts;
    weeklyEngagementReport = data!.weeklyEngagementReport;
  }

  Future<void> _loadFromCache() async {
    final burnoutRaw          = await _secureStorage.read(key: _keyBurnoutAlerts);
    final fallingBehindRaw    = await _secureStorage.read(key: _keyFallingBehindAlerts);
    final weeklyEngagementRaw = await _secureStorage.read(key: _keyWeeklyEngagement);
    final avatarRaw           = await _secureStorage.read(key: _keyAvatarUrl);

    if (avatarRaw           != null) avatarUrl              = avatarRaw;
    if (burnoutRaw          != null) burnoutAlerts          = burnoutRaw          == 'true';
    if (fallingBehindRaw    != null) fallingBehindAlerts    = fallingBehindRaw    == 'true';
    if (weeklyEngagementRaw != null) weeklyEngagementReport = weeklyEngagementRaw == 'true';
  }

  Future<void> _saveToCache() async {
    await _secureStorage.write(key: _keyBurnoutAlerts,       value: burnoutAlerts.toString());
    await _secureStorage.write(key: _keyFallingBehindAlerts, value: fallingBehindAlerts.toString());
    await _secureStorage.write(key: _keyWeeklyEngagement,    value: weeklyEngagementReport.toString());
    if (avatarUrl != null) {
      await _secureStorage.write(key: _keyAvatarUrl, value: avatarUrl!);
    }
  }

  Future<void> toggleBurnoutAlerts() async {
    burnoutAlerts = !burnoutAlerts;
    data = data?.copyWith(burnoutAlerts: burnoutAlerts);
    await _persistToggle({'burnout_alerts': burnoutAlerts});
  }

  Future<void> toggleFallingBehindAlerts() async {
    fallingBehindAlerts = !fallingBehindAlerts;
    data = data?.copyWith(fallingBehindAlerts: fallingBehindAlerts);
    await _persistToggle({'falling_behind_alerts': fallingBehindAlerts});
  }

  Future<void> toggleWeeklyEngagementReport() async {
    weeklyEngagementReport = !weeklyEngagementReport;
    data = data?.copyWith(weeklyEngagementReport: weeklyEngagementReport);
    await _persistToggle({'weekly_engagement_report': weeklyEngagementReport});
  }

  Future<void> _persistToggle(Map<String, dynamic> fields) async {
    await _saveToCache();
    _tryFirestorePatch(fields);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    if (_uid == null) return;
    data = data?.copyWith(userName: name);
    // Write changes back to master user identity record folder safely
    await _db.collection('users').doc(_uid).update({'name': name});
    notifyListeners();
  }

  Future<void> updateAvatar(XFile file) async {
    if (_uid == null) return;
    try {
      final ref = _storage.ref().child('avatars/lecturers/$_uid.jpg');
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();

      avatarUrl = url;
      data      = data?.copyWith(avatarUrl: url);
      await _secureStorage.write(key: _keyAvatarUrl, value: url);
      _tryFirestorePatch({'avatar_url': url});
      notifyListeners();
    } catch (_) {
      setError('Failed to upload avatar');
    }
  }

  Future<void> signOut(BuildContext context) async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  void setData(LecturerSettingsModel model) {
    data                   = model;
    burnoutAlerts          = model.burnoutAlerts;
    fallingBehindAlerts    = model.fallingBehindAlerts;
    weeklyEngagementReport = model.weeklyEngagementReport;
    avatarUrl              = model.avatarUrl;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setError(String message) {
    error   = message;
    loading = false;
    notifyListeners();
  }

  void clear() {
    data                   = null;
    burnoutAlerts          = false;
    fallingBehindAlerts    = false;
    weeklyEngagementReport = false;
    avatarUrl              = null;
    loading                = false;
    error                  = null;
    notifyListeners();
  }

  void _tryFirestorePatch(Map<String, dynamic> fields) async {
    if (_uid == null) return;
    try {
      await _db.collection('users').doc(_uid).update(fields);
    } catch (_) {}
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}