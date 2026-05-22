import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/api_service.dart';
import '../../../auth/controllers/login_controller.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/views/login_page.dart';
import '../models/lecturer_settings_model.dart';

class LecturerSettingsController extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  LecturerSettingsModel? data;

  // ── Cache keys ─────────────────────────────────────────────────────────────
  static const _keyUserId              = 'lec_user_id';
  static const _keyUserName            = 'lec_user_name';
  static const _keyDepartment          = 'lec_department';
  static const _keyActiveClassesCount  = 'lec_active_classes_count';
  static const _keyBurnoutAlerts       = 'lec_burnout_alerts';
  static const _keyFallingBehindAlerts = 'lec_falling_behind_alerts';
  static const _keyWeeklyEngagement    = 'lec_weekly_engagement_report';
  static const _keyAppVersion          = 'lec_app_version';
  static const _keyAvatarUrl           = 'lec_avatar_url';

  // ── State ──────────────────────────────────────────────────────────────────
  bool    burnoutAlerts          = false;
  bool    fallingBehindAlerts    = false;
  bool    weeklyEngagementReport = false;
  String? avatarUrl;
  bool    loading = false;
  String? error;

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> load() async {
    loading = true;
    error   = null;
    notifyListeners();

    await _loadFromCache();
    loading = false;
    notifyListeners();

    try {
      final json = await ApiService.get('/lecturer/settings');
      _applyFromApi(json);
      await _saveToCache();
      notifyListeners();
    } catch (_) {}
  }

  void _applyFromApi(Map<String, dynamic> json) {
    data = LecturerSettingsModel.fromJson(json);

    avatarUrl              = data!.avatarUrl;
    burnoutAlerts          = data!.burnoutAlerts;
    fallingBehindAlerts    = data!.fallingBehindAlerts;
    weeklyEngagementReport = data!.weeklyEngagementReport;
  }

  Future<void> _loadFromCache() async {
    final userIdRaw            = await _storage.read(key: _keyUserId);
    final userNameRaw          = await _storage.read(key: _keyUserName);
    final departmentRaw        = await _storage.read(key: _keyDepartment);
    final activeClassesRaw     = await _storage.read(key: _keyActiveClassesCount);
    final burnoutRaw           = await _storage.read(key: _keyBurnoutAlerts);
    final fallingBehindRaw     = await _storage.read(key: _keyFallingBehindAlerts);
    final weeklyEngagementRaw  = await _storage.read(key: _keyWeeklyEngagement);
    final appVersionRaw        = await _storage.read(key: _keyAppVersion);
    final avatarRaw            = await _storage.read(key: _keyAvatarUrl);

    if (avatarRaw           != null) avatarUrl              = avatarRaw;
    if (burnoutRaw          != null) burnoutAlerts          = burnoutRaw         == 'true';
    if (fallingBehindRaw    != null) fallingBehindAlerts    = fallingBehindRaw   == 'true';
    if (weeklyEngagementRaw != null) weeklyEngagementReport = weeklyEngagementRaw == 'true';

    if (userIdRaw != null) {
      data = LecturerSettingsModel(
        userId:                 int.tryParse(userIdRaw) ?? 0,
        userName:               userNameRaw ?? '',
        department:             departmentRaw ?? '',
        activeClassesCount:     int.tryParse(activeClassesRaw ?? '0') ?? 0,
        burnoutAlerts:          burnoutAlerts,
        fallingBehindAlerts:    fallingBehindAlerts,
        weeklyEngagementReport: weeklyEngagementReport,
        appVersion:             appVersionRaw ?? 'v1.0',
        avatarUrl:              avatarRaw,
      );
    }
  }

  Future<void> _saveToCache() async {
    await _storage.write(key: _keyBurnoutAlerts,       value: burnoutAlerts.toString());
    await _storage.write(key: _keyFallingBehindAlerts, value: fallingBehindAlerts.toString());
    await _storage.write(key: _keyWeeklyEngagement,    value: weeklyEngagementReport.toString());

    if (data != null) {
      await _storage.write(key: _keyUserId,             value: data!.userId.toString());
      await _storage.write(key: _keyUserName,           value: data!.userName);
      await _storage.write(key: _keyDepartment,         value: data!.department);
      await _storage.write(key: _keyActiveClassesCount, value: data!.activeClassesCount.toString());
      await _storage.write(key: _keyAppVersion,         value: data!.appVersion);
      if (avatarUrl != null) {
        await _storage.write(key: _keyAvatarUrl, value: avatarUrl!);
      }
    }
  }

  // ── Toggles ────────────────────────────────────────────────────────────────

  Future<void> toggleBurnoutAlerts() async {
    burnoutAlerts = !burnoutAlerts;
    data = data?.copyWith(burnoutAlerts: burnoutAlerts);
    await _persistToggle('burnout_alerts', burnoutAlerts);
  }

  Future<void> toggleFallingBehindAlerts() async {
    fallingBehindAlerts = !fallingBehindAlerts;
    data = data?.copyWith(fallingBehindAlerts: fallingBehindAlerts);
    await _persistToggle('falling_behind_alerts', fallingBehindAlerts);
  }

  Future<void> toggleWeeklyEngagementReport() async {
    weeklyEngagementReport = !weeklyEngagementReport;
    data = data?.copyWith(weeklyEngagementReport: weeklyEngagementReport);
    await _persistToggle('weekly_engagement_report', weeklyEngagementReport);
  }

  Future<void> _persistToggle(String apiKey, bool value) async {
    await _saveToCache();
    _tryApiPatch({apiKey: value});
    notifyListeners();
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<void> updateUserName(String name) async {
    data = data?.copyWith(userName: name);
    await _storage.write(key: _keyUserName, value: name);
    _tryApiPatch({'name': name});
    notifyListeners();
  }

  Future<void> updateAvatar(XFile file) async {
    try {
      final response = await ApiService.uploadImage(
        '/lecturer/settings/avatar',
        file.path,
      );
      final remoteUrl = response['avatar_url'] as String;
      avatarUrl = remoteUrl;
      data = data?.copyWith(avatarUrl: remoteUrl);
      await _storage.write(key: _keyAvatarUrl, value: remoteUrl);
      notifyListeners();
    } catch (_) {
      setError('Failed to upload avatar');
    }
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  Future<void> signOut(BuildContext context) async {
    await LoginController.clearSession();
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

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

  void _tryApiPatch(Map<String, dynamic> body) async {
    try {
      await ApiService.patch('/lecturer/settings', body);
    } catch (_) {}
  }
}