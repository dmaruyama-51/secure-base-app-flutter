import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/navigation_view_model.dart';

class BottomNavigation extends ConsumerWidget {
  // オプション：タブ切り替え時のコールバック
  final Function(int)? onTabChanged;

  const BottomNavigation({Key? key, this.onTabChanged}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return BottomNavigationBar(
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

        // コールバックがあれば実行
        if (onTabChanged != null) {
          onTabChanged!(index);
        }
      },
    );
  }
}
