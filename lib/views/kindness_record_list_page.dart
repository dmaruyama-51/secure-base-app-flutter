import 'package:flutter/material.dart';
import '../view_models/kindness_record_list_view_model.dart';
import '../widgets/kindness_record_list_item.dart';
import '../widgets/common/bottom_navigation.dart';
import 'package:go_router/go_router.dart';

// やさしさ記録一覧ページの画面Widget
class KindnessRecordListPage extends StatefulWidget {
  const KindnessRecordListPage({super.key});

  @override
  State<KindnessRecordListPage> createState() => _KindnessRecordListPageState();
}

// やさしさ記録一覧ページの状態管理クラス
class _KindnessRecordListPageState extends State<KindnessRecordListPage> {
  late KindnessRecordListViewModel _viewModel;

  // 初期化処理。ViewModelの生成と記録一覧の取得を行う。
  @override
  void initState() {
    super.initState();
    _viewModel = KindnessRecordListViewModel();
    _loadRecords();
  }

  // 記録一覧の取得処理
  Future<void> _loadRecords() async {
    await _viewModel.loadRecords();
  }

  // 画面のUI構築処理
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
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        if (_viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_viewModel.error!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadRecords,
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        }

        if (_viewModel.records.isEmpty) {
          return Center(
            child: Text('記録がありません', style: theme.textTheme.bodyMedium),
          );
        }

        return ListView.builder(
          itemCount: _viewModel.records.length,
          itemBuilder: (context, index) {
            return KindnessRecordListItem(record: _viewModel.records[index]);
          },
        );
      },
    );
  }
}
