import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/kindness_record/kindness_record_list_view_model.dart';
import '../../widgets/kindness_record_list_item.dart';
import '../../widgets/common/bottom_navigation.dart';
import 'package:go_router/go_router.dart';

// やさしさ記録一覧ページの画面Widget
class KindnessRecordListPage extends ConsumerStatefulWidget {
  const KindnessRecordListPage({super.key});

  @override
  ConsumerState<KindnessRecordListPage> createState() => _KindnessRecordListPageState();
}

// やさしさ記録一覧ページの状態管理クラス
class _KindnessRecordListPageState extends ConsumerState<KindnessRecordListPage> {
  @override
  void initState() {
    super.initState();
    // 初期データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kindnessRecordListViewModelProvider.notifier).loadKindnessRecords();
    });
  }

  // 記録一覧の取得処理
  Future<void> _loadRecords() async {
    await ref.read(kindnessRecordListViewModelProvider.notifier).loadKindnessRecords();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kindnessRecordListViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text('History', style: theme.textTheme.titleLarge),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () {
          GoRouter.of(context).push('/kindness-records/add');
        },
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
      bottomNavigationBar: const BottomNavigation(
        currentIndex: 0, // Historyタブを選択済みとして表示
      ),
    );
  }

  // 記録リスト部分のUI構築処理
  Widget _buildBody() {
    final state = ref.watch(kindnessRecordListViewModelProvider);
    final theme = Theme.of(context);

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecords,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (state.kindnessRecords.isEmpty) {
      return Center(
        child: Text('記録がありません', style: theme.textTheme.bodyMedium),
      );
    }

    return ListView.builder(
      itemCount: state.kindnessRecords.length,
      itemBuilder: (context, index) {
        final record = state.kindnessRecords[index];
        return KindnessRecordListItem(
          record: record,
          onTap: () {
            // 編集ページに遷移
            GoRouter.of(context).push('/kindness-records/edit/${record.id}', extra: record).then((_) {
              // 編集ページから戻ってきた際にリストを再読み込み
              _loadRecords();
            });
          },
        );
      },
    );
  }
} 