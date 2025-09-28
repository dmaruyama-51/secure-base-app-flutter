// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  // 現在選択されているタブのインデックス
  final int currentIndex;

  const BottomNavigation({Key? key, required this.currentIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 10),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/kindness-givers');
            break;
          case 2:
            context.go('/reflections'); // リフレクションページに遷移
            break;
          case 3:
            context.go('/settings'); // 設定画面に遷移
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: '記録'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'メンバー'),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome),
          label: 'リフレクション',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
      ],
    );
  }
}
