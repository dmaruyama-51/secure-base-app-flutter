import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/kindness_giver/kindness_giver_list_page.dart';
import '../views/home_page.dart';
import '../views/kindness_giver/kindness_giver_add_page.dart';
import '../views/kindness_giver/kindness_giver_edit_page.dart';
import '../models/kindness_giver.dart';
import '../models/kindness_record.dart';
import '../views/kindness_record/kindness_record_list_page.dart';
import '../views/kindness_record/kindness_record_add_page.dart';
import '../views/kindness_record/kindness_record_edit_page.dart';

/// 認証が必要なページへのリダイレクト処理
String? _authGuard(String location) {
  final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

  // kindness-giver系のページは認証が必要
  final requiresAuth = location.startsWith('/kindness-givers');

  if (requiresAuth && !isLoggedIn) {
    return '/login?redirect=${Uri.encodeComponent(location)}';
  }

  return null; // 問題なし
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) => _authGuard(state.uri.toString()),
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    // 認証が必要なkindness-giver系のルート
    GoRoute(
      path: '/kindness-givers',
      builder: (context, state) => const KindnessGiverListPage(),
    ),
    GoRoute(
      path: '/kindness-givers/add',
      builder: (context, state) => const KindnessGiverAddPage(),
    ),
    GoRoute(
      path: '/kindness-givers/edit/:id',
      builder: (context, state) {
        final kindnessGiver = state.extra as KindnessGiver;
        return KindnessGiverEditPage(kindnessGiver: kindnessGiver);
      },
    ),
    // kindness-record系は認証チェックなし（別担当のため）
    GoRoute(
      path: '/kindness-records',
      builder: (context, state) => const KindnessRecordListPage(),
    ),
    GoRoute(
      path: '/kindness-records/add',
      builder: (context, state) => const KindnessRecordAddPage(),
    ),
    GoRoute(
      path: '/kindness-records/edit/:id',
      builder: (context, state) {
        final record = state.extra as KindnessRecord?;
        if (record == null) {
          return const KindnessRecordListPage();
        }
        return KindnessRecordEditPage(record: record);
      },
    ),
  ],
);
