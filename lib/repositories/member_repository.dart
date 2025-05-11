import '../models/member.dart';

/// メンバーデータのリポジトリクラス
class MemberRepository {
  /// ToDo: DBからデータ取得
  Future<List<Member>> fetchMembers() async {
    // サンプルデータ
    return [
      Member(name: 'お母さん', category: 'Family'),
      Member(name: 'お父さん', category: 'Family'),
      Member(name: 'たろー', category: 'Friends'),
      Member(name: 'ももちゃん', category: 'Friends'),
    ];
  }
}
