import 'package:flutter/material.dart';
import '../models/member.dart';
import '../widgets/member_list_item.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({Key? key}) : super(key: key);

  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  // サンプルデータ
  final List<Member> _members = [
    Member(name: 'お母さん', category: 'Family'),
    Member(name: 'お父さん', category: 'Family'),
    Member(name: 'たろー', category: 'Friends'),
    Member(name: 'ももちゃん', category: 'Friends'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
        itemCount: _members.length,
        itemBuilder: (context, index) {
          return MemberListItem(
            member: _members[index],
            onEditPressed: () {
              // 編集ボタンが押されたときの処理
              print('Edit ${_members[index].name}');
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          // 追加ボタンが押されたときの処理
          print('Add new member');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
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
          // タブが押されたときの処理
        },
      ),
    );
  }
}
