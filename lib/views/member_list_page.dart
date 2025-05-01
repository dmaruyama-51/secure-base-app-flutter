import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member.dart';
import '../view_models/member_list_view_model.dart';
import '../widgets/member_list_item.dart';

// Riverpodを使用するConsumerWidget
class MemberListPage extends ConsumerWidget {
  const MemberListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プロバイダーからデータを読み取る
    final members = ref.watch(membersProvider);
    final selectedTab = ref.watch(selectedTabProvider);

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
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return MemberListItem(
            member: members[index],
            onEditPressed: () {
              // UIのみのため実装は省略、表示だけ行う
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('編集: ${members[index].name}')),
              );
            },
          );
        },
      ),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'member'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Reflection',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
        onTap: (index) {
          // タブの状態を更新
          ref.read(selectedTabProvider.notifier).state = index;
          // UIのみのため実装は省略、表示だけ行う
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('タブを切り替え: $index')));
        },
      ),
    );
  }
}
