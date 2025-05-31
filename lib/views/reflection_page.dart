import 'package:flutter/material.dart';
import '../widgets/common/bottom_navigation.dart';
import '../widgets/reflection_list_item.dart';

// Reflectionページの画面Widget
class ReflectionPage extends StatefulWidget {
  const ReflectionPage({super.key});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

// Reflectionページの状態管理クラス
class _ReflectionPageState extends State<ReflectionPage> {
  // サンプルデータ（DBとの接続時に置き換え予定）
  final List<ReflectionItem> _reflectionItems = [
    ReflectionItem(
      title: 'Monthly Reflection',
      date: 'Feb 28',
      type: ReflectionType.monthly,
    ),
    ReflectionItem(
      title: 'バレンタインデー',
      date: 'Feb 14',
      type: ReflectionType.custom,
    ),
    ReflectionItem(
      title: 'Monthly Reflection',
      date: 'Jan 31',
      type: ReflectionType.monthly,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Reflection',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

  // リスト部分のUI構築処理
  Widget _buildBody() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _reflectionItems.length,
      itemBuilder: (context, index) {
        return ReflectionListItem(
          item: _reflectionItems[index],
          onTap: () {
            // 詳細画面への遷移（今後実装予定）
            _onReflectionItemTap(_reflectionItems[index]);
          },
        );
      },
    );
  }

  // リストアイテムタップ時の処理
  void _onReflectionItemTap(ReflectionItem item) {
    // 詳細画面への遷移処理（今後実装予定）
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.title} が選択されました')));
  }
}

// Reflectionアイテムのデータモデル
class ReflectionItem {
  final String title;
  final String date;
  final ReflectionType type;

  ReflectionItem({required this.title, required this.date, required this.type});
}

// Reflectionの種類を表すEnum
enum ReflectionType { monthly, custom }
