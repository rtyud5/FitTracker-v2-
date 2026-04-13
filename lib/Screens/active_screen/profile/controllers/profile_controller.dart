import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fittracker_source/Screens/active_screen/profile/services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  ProfileData? _data;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedRangeDays = 7;

  ProfileData? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedRangeDays => _selectedRangeDays;

  Future<void> load() async {
    _setLoading(true);
    try {
      _data = await ProfileService.loadProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  void setRangeDays(int value) {
    if (_selectedRangeDays == value) return;
    _selectedRangeDays = value;
    notifyListeners();
  }

  List<String> get chartLabels {
    return List.generate(selectedRangeDays, (index) {
      final date = DateTime.now().subtract(Duration(days: selectedRangeDays - 1 - index));
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month';
    });
  }

  List<double> get chartWeights {
    final source = _data?.weightHistoryMap ?? const <String, double>{};
    final fallback = _data?.currentWeightLbs ?? 0;
    return chartLabels.map((label) => source[label] ?? fallback).toList();
  }

  Future<void> pickAvatar() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await ProfileService.saveAvatarPath(image.path);
    await load();
  }

  File? get avatarFile {
    final path = _data?.avatarPath;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  Future<void> addWeightEntry(double weightLbs) async {
    await ProfileService.addWeightEntry(weightLbs);
    await load();
  }

  Future<void> updateProfile({
    required String name,
    required String goal,
    required double currentWeightLbs,
    required double targetWeightLbs,
  }) async {
    await ProfileService.updateProfile(
      name: name,
      goal: goal,
      currentWeightLbs: currentWeightLbs,
      targetWeightLbs: targetWeightLbs,
    );
    await load();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
