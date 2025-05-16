import 'package:flutter/material.dart';
import '../view_models/member_list_view_model.dart';
import '../widgets/member_list_item.dart';
import '../widgets/common/bottom_navigation.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'Members',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          // UIのみのため実装は省略、表示だけ行う
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('新しいメンバーを追加します')));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1, // memberタブを選択済みとして表示
        onTabChanged: (index) {
          // ToDo: GoRouterでルーティングを実装
        },
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // エラーがある場合
        if (_viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_viewModel.error!),
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
          return const Center(child: Text('メンバーがいません'));
        }

        // メンバーがいる場合
        return ListView.builder(
          itemCount: _viewModel.members.length,
          itemBuilder: (context, index) {
            return MemberListItem(
              member: _viewModel.members[index],
              onEditPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('編集: ${_viewModel.members[index].name}'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
