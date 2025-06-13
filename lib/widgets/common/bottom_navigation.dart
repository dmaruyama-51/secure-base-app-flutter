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
            context.go('/'); // Reflectionページ用（未実装）
            break;
          case 3:
            context.go('/settings'); // 設定画面に遷移
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Member'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Reflection',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
      ],
    );
  }
}
