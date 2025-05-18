import '../models/kindness_giver.dart';

/// 優しさをくれる人のデータのリポジトリクラス
class KindnessGiverRepository {
  /// ToDo: DBからデータ取得
  Future<List<KindnessGiver>> fetchKindnessGivers() async {
    // サンプルデータ
    return [
      KindnessGiver(name: 'お母さん', relationship: '家族', gender: '女性'),
      KindnessGiver(name: 'お父さん', relationship: '家族', gender: '男性'),
      KindnessGiver(name: 'たろー', relationship: '友達', gender: '男性'),
      KindnessGiver(name: 'ももちゃん', relationship: '友達', gender: '女性'),
    ];
  }

  /// 優しさをくれる人を保存する
  Future<bool> saveKindnessGiver(KindnessGiver kindnessGiver) async {
    // TODO: 実際のデータベースに保存する処理を実装
    // 現在はダミー実装として成功を返す
    return true;
  }
}
