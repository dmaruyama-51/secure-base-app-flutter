import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member.dart';

// サンプルデータを提供するプロバイダー
final membersProvider = Provider<List<Member>>((ref) {
  return [
    Member(name: 'お母さん', category: 'Family'),
    Member(name: 'お父さん', category: 'Family'),
    Member(name: 'たろー', category: 'Friends'),
    Member(name: 'ももちゃん', category: 'Friends'),
  ];
});

// ボトムナビゲーションの選択中のタブを管理するプロバイダー
final selectedTabProvider = StateProvider<int>((ref) => 1); // デフォルトはmemberタブ
