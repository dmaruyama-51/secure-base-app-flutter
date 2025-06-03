import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/kindness_record.dart';
import '../../repositories/kindness_record_repository.dart';

// やさしさ記録一覧ページ用のViewModel
class KindnessRecordListViewModel extends ChangeNotifier {
  // やさしさ記録取得用リポジトリ
  final KindnessRecordRepository _repository = KindnessRecordRepository();

  // やさしさ記録リスト
  List<KindnessRecord> _records = [];
  // ローディング中フラグ
  bool _isLoading = false;
  // エラーメッセージ
  String? _error;

  // やさしさ記録リストのgetter
  List<KindnessRecord> get records => _records;
  // ローディング中フラグのgetter
  bool get isLoading => _isLoading;
  // エラーメッセージのgetter
  String? get error => _error;

  // やさしさ記録一覧を取得する
  Future<void> loadRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _repository.fetchKindnessRecords();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 