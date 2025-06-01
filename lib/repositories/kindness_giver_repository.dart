import '../models/kindness_giver.dart';

/// 優しさをくれる人のデータのリポジトリクラス
class KindnessGiverRepository {
  /// ToDo: DBからデータ取得
  Future<List<KindnessGiver>> fetchKindnessGivers() async {
    // サンプルデータ
    return [
      KindnessGiver(id: '1', name: 'お母さん', category: '家族', gender: '女性'),
      KindnessGiver(id: '2', name: 'お父さん', category: '家族', gender: '男性'),
      KindnessGiver(id: '3', name: 'たろー', category: '友達', gender: '男性'),
      KindnessGiver(id: '4', name: 'ももちゃん', category: '友達', gender: '女性'),
    ];
  }

  /// メンバー新規作成
  Future<KindnessGiver> createKindnessGiver(KindnessGiver kindnessGiver) async {
    // TODO: 実際のデータベースに新規作成する処理を実装
    // 現在はダミー実装として、IDを付与して返す
    final String newId = DateTime.now().millisecondsSinceEpoch.toString();
    return KindnessGiver(
      id: newId,
      name: kindnessGiver.name,
      category: kindnessGiver.category,
      gender: kindnessGiver.gender,
      avatarUrl: kindnessGiver.avatarUrl,
    );
  }

  /// メンバー更新
  Future<bool> updateKindnessGiver(KindnessGiver kindnessGiver) async {
    // TODO: 実際のデータベースで更新する処理を実装
    // IDが必要なので、nullチェックを行う
    if (kindnessGiver.id == null) {
      return false;
    }

    // 現在はダミー実装として成功を返す
    return true;
  }
}
