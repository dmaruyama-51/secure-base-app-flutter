import 'package:flutter/material.dart';
import '../view_models/member_list_view_model.dart';
import '../widgets/member_list_item.dart';
import '../widgets/common/bottom_navigation.dart';
import 'package:go_router/go_router.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({Key? key}) : super(key: key);

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  late MemberListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // ViewModelのインスタンス化
    _viewModel = MemberListViewModel();
    // データの読み込み
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    await _viewModel.loadMembers();
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
        title: Text('Members', style: theme.textTheme.titleLarge),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () {
          GoRouter.of(context).push('/member/add');
        },
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
      bottomNavigationBar: const BottomNavigation(
        currentIndex: 1, // memberタブを選択済みとして表示
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
                  onPressed: _loadMembers,
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        }

        // メンバーがいない場合
        if (_viewModel.members.isEmpty) {
          return Center(
            child: Text('メンバーがいません', style: theme.textTheme.bodyMedium),
          );
        }

        // メンバーがいる場合
        return ListView.builder(
          itemCount: _viewModel.members.length,
          itemBuilder: (context, index) {
            return MemberListItem(
              member: _viewModel.members[index],
              onEditPressed: () {
                GoRouter.of(context).push(
                  '/member/edit/${_viewModel.members[index].name}',
                  extra: _viewModel.members[index],
                );
              },
            );
          },
        );
      },
    );
  }
}
