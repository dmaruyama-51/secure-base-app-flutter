import 'package:flutter/material.dart';
import '../models/kindness_reflection.dart';
import '../repositories/kindness_reflection_repository.dart';

// ReflectionページのViewModel
class KindnessReflectionListViewModel extends ChangeNotifier {
  final ReflectionRepository _repository = ReflectionRepository();

  List<KindnessReflection> _reflectionItems = [];
  bool _isLoading = false;
  String? _error;

  KindnessReflectionListViewModel();

  // ゲッター
  List<KindnessReflection> get reflectionItems => _reflectionItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 初期データ読み込み
  Future<void> loadReflectionItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reflectionItems = await _repository.getReflectionItems();
    } catch (e) {
      _error = 'データの読み込みに失敗しました';
      debugPrint('Reflection items loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // リストアイテムタップ時の処理
  void onReflectionItemTap(BuildContext context, KindnessReflection item) {
    // 詳細画面への遷移処理（今後実装予定）
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.reflectionTitle} が選択されました')));
  }
}
