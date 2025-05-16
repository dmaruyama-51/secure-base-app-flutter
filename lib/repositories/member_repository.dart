import '../models/member.dart';

/// メンバーデータのリポジトリクラス
class MemberRepository {
  /// ToDo: DBからデータ取得
  Future<List<Member>> fetchMembers() async {
    // サンプルデータ
    return [
      Member(name: 'お母さん', category: 'Family', gender: '女性'),
      Member(name: 'お父さん', category: 'Family', gender: '男性'),
      Member(name: 'たろー', category: 'Friends', gender: '男性'),
      Member(name: 'ももちゃん', category: 'Friends', gender: '女性'),
    ];
  }

  /// メンバーを保存する
  Future<bool> saveMember(Member member) async {
    // TODO: 実際のデータベースに保存する処理を実装
    // 現在はダミー実装として成功を返す
    return true;
  }
}
