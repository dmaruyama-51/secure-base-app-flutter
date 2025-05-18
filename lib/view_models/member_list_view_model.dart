import 'dart:async';
import 'package:flutter/material.dart';
import '../models/kindness_giver.dart';
import '../repositories/kindness_giver_repository.dart';

class KindnessGiverListViewModel extends ChangeNotifier {
  final KindnessGiverRepository _repository = KindnessGiverRepository();

  List<KindnessGiver> _kindnessGivers = [];
  bool _isLoading = false; // データ読み込み中フラグ
  String? _error;

  List<KindnessGiver> get kindnessGivers => _kindnessGivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 優しさをくれる人一覧の読み込み
  Future<void> loadKindnessGivers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _kindnessGivers = await _repository.fetchKindnessGivers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
