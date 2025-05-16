import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  // 現在選択されているタブのインデックス
  final int currentIndex;
  // タブ切り替え時のコールバック
  final Function(int) onTabChanged;

  const BottomNavigation({
    Key? key,
    this.currentIndex = 1, // デフォルトはmemberタブ
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'member'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Reflection',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
      ],
      onTap: onTabChanged,
    );
  }
}
