import 'package:flutter/material.dart';
import '../../view_models/kindness_giver/kindness_giver_list_view_model.dart';
import '../../widgets/kindness_giver_list_item.dart';
import '../../widgets/common/bottom_navigation.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../models/kindness_giver.dart';

class KindnessGiverListPage extends StatefulWidget {
  const KindnessGiverListPage({super.key});

  @override
  State<KindnessGiverListPage> createState() => _KindnessGiverListPageState();
}

class _KindnessGiverListPageState extends State<KindnessGiverListPage> {
  late KindnessGiverListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // ViewModelのインスタンス化
    _viewModel = KindnessGiverListViewModel();
    // データの読み込み
    _loadKindnessGivers();

    // 更新通知をリッスンする
    kindnessGiverListUpdateNotifier.addListener(_onListUpdate);
  }

  @override
  void dispose() {
    // リスナーの解除
    kindnessGiverListUpdateNotifier.removeListener(_onListUpdate);
    super.dispose();
  }

  // リストの更新が通知されたときに呼ばれる
  void _onListUpdate() {
    _loadKindnessGivers();
  }

  Future<void> _loadKindnessGivers() async {
    await _viewModel.loadKindnessGivers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // テーマを取得

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text('メンバー一覧', style: theme.textTheme.titleLarge),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () {
          GoRouter.of(context).push('/kindness-givers/add');
        },
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
      bottomNavigationBar: const BottomNavigation(
        currentIndex: 1, // メンバータブを選択済みとして表示
      ),
    );
  }

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

        // エラーがある場合
        if (_viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_viewModel.error!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadKindnessGivers,
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        }

        // メンバーがいない場合
        if (_viewModel.kindnessGivers.isEmpty) {
          return Center(
            child: Text('メンバーがいません', style: theme.textTheme.bodyMedium),
          );
        }

        // メンバーがいる場合
        return ListView.builder(
          itemCount: _viewModel.kindnessGivers.length,
          itemBuilder: (context, index) {
            return KindnessGiverListItem(
              kindnessGiver: _viewModel.kindnessGivers[index],
              onEditPressed: () {
                GoRouter.of(context).push(
                  '/kindness-givers/edit/${_viewModel.kindnessGivers[index].name}',
                  extra: _viewModel.kindnessGivers[index],
                );
              },
              onDeletePressed: () {
                _showDeleteConfirmationDialog(_viewModel.kindnessGivers[index]);
              },
            );
          },
        );
      },
    );
  }

  // 削除確認ダイアログを表示するメソッドを追加
  void _showDeleteConfirmationDialog(KindnessGiver kindnessGiver) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('削除の確認'),
            content: Text('${kindnessGiver.name}を削除してもよろしいですか？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                  // 削除処理を実行
                  final result = await _viewModel.deleteKindnessGiver(
                    kindnessGiver.id!,
                  );
                  if (result && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('メンバーを削除しました')),
                    );
                  }
                },
                child: Text(
                  '削除',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }
}
