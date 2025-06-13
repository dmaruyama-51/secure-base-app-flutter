import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/kindness_record/kindness_record_list_view_model.dart';
import '../../widgets/kindness_record_list_item.dart';
import '../../widgets/common/bottom_navigation.dart';

/// やさしさ記録一覧ページ
class KindnessRecordListPage extends StatefulWidget {
  const KindnessRecordListPage({super.key});

  @override
  State<KindnessRecordListPage> createState() => _KindnessRecordListPageState();
}

class _KindnessRecordListPageState extends State<KindnessRecordListPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KindnessRecordListViewModel()..loadKindnessRecords(),
      child: Consumer<KindnessRecordListViewModel>(
        builder: (context, viewModel, child) {
          // エラーメッセージがあればSnackBarで表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
              viewModel.clearErrorMessage();
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('やさしさ記録'),
              automaticallyImplyLeading: false,
            ),
            body: _buildBody(viewModel),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAdd(),
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: const BottomNavigation(currentIndex: 0),
          );
        },
      ),
    );
  }

  Widget _buildBody(KindnessRecordListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.errorMessage!),
            ElevatedButton(
              onPressed: viewModel.loadKindnessRecords,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (viewModel.kindnessRecords.isEmpty) {
      return Center(
        child: Text('記録がありません', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView.builder(
      itemCount: viewModel.kindnessRecords.length,
      itemBuilder: (context, index) {
        final record = viewModel.kindnessRecords[index];
        return KindnessRecordListItem(
          record: record,
          onTap: () {
            // 編集ページに遷移
            GoRouter.of(context)
                .push('/kindness-records/edit/${record.id}', extra: record)
                .then((_) {
                  // 編集ページから戻ってきた際にリストを再読み込み
                  viewModel.loadKindnessRecords();
                });
          },
        );
      },
    );
  }

  void _navigateToAdd() {
    // 追加ページへのナビゲーション
    GoRouter.of(context).push('/kindness-records/add');
  }
}
