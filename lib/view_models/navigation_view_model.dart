import 'package:flutter_riverpod/flutter_riverpod.dart';

// 選択中のタブを管理するプロバイダー
final selectedTabProvider = StateProvider<int>((ref) => 1); // デフォルトはmemberタブ
