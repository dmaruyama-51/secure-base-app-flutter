import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/kindness_reflection.dart';
import '../../repositories/kindness_reflection_repository.dart';

// ReflectionページのViewModel
class KindnessReflectionListViewModel extends ChangeNotifier {
  final KindnessReflectionRepository _repository =
      KindnessReflectionRepository();

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
      _reflectionItems = await _repository.fetchKindnessReflections();
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
    GoRouter.of(context).push('/reflection/summary/${item.id}');
  }
}
