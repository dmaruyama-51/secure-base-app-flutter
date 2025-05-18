import '../models/kindness_giver.dart';

/// 優しさをくれる人のデータのリポジトリクラス
class KindnessGiverRepository {
  /// ToDo: DBからデータ取得
  Future<List<KindnessGiver>> fetchKindnessGivers() async {
    // サンプルデータ
    return [
      KindnessGiver(name: 'お母さん', category: 'Family', gender: '女性'),
      KindnessGiver(name: 'お父さん', category: 'Family', gender: '男性'),
      KindnessGiver(name: 'たろー', category: 'Friends', gender: '男性'),
      KindnessGiver(name: 'ももちゃん', category: 'Friends', gender: '女性'),
    ];
  }

  /// 優しさをくれる人を保存する
  Future<bool> saveKindnessGiver(KindnessGiver kindnessGiver) async {
    // TODO: 実際のデータベースに保存する処理を実装
    // 現在はダミー実装として成功を返す
    return true;
  }
}
