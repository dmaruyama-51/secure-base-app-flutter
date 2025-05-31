import '../models/kindness_reflection.dart';

// Reflectionデータの取得を担当するRepository
class ReflectionRepository {
  // ダミーデータ（将来的にはDBやAPIから取得）
  Future<List<KindnessReflection>> getReflectionItems() async {
    // 実際のアプリでは非同期でデータを取得する想定でFutureを使用
    await Future.delayed(const Duration(milliseconds: 100));

    return [
      KindnessReflection(
        id: 1,
        userId: 1,
        reflectionTypeId: 1,
        reflectionType: 'Monthly',
        reflectionTitle: 'Monthly #2',
        reflectionStartDate: DateTime(2024, 2, 1),
        reflectionEndDate: DateTime(2024, 2, 28),
        createdAt: DateTime.now(),
      ),
      KindnessReflection(
        id: 2,
        userId: 1,
        reflectionTypeId: 1,
        reflectionType: 'Monthly',
        reflectionTitle: 'Monthly #1',
        reflectionStartDate: DateTime(2024, 1, 1),
        reflectionEndDate: DateTime(2024, 1, 31),
        createdAt: DateTime.now(),
      ),
    ];
  }
}
