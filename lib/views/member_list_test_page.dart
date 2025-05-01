import 'package:flutter/material.dart';
import 'member_list_page.dart';

class MemberListTestApp extends StatelessWidget {
  const MemberListTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Member List Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MemberListPage(),
    );
  }
}

// このファイルから直接実行するためのmain関数
void main() {
  runApp(const MemberListTestApp());
}
