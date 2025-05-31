import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String title = 'secure-base';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/register');
              },
              child: const Text('ユーザー認証ページへ'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/kindness-givers');
              },
              child: const Text('メンバー一覧ページへ'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/kindness-records');
              },
              child: const Text('優しさ記録ページへ'),
            ),
          ],
        ),
      ),
    );
  }
}
