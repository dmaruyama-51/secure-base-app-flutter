// Package imports:
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../models/kindness_giver.dart';
import '../models/kindness_record.dart';
import '../models/kindness_reflection.dart';
import '../models/user_model.dart';
import '../views/kindness_giver/kindness_giver_add_page.dart';
import '../views/kindness_giver/kindness_giver_edit_page.dart';
import '../views/kindness_giver/kindness_giver_list_page.dart';
import '../views/kindness_record/kindness_record_add_page.dart';
import '../views/kindness_record/kindness_record_edit_page.dart';
import '../views/kindness_record/kindness_record_list_page.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/settings/settings_page.dart';
import '../views/tutorial/tutorial_page.dart';
import '../views/kindness_reflection/kindness_reflection_list_page.dart';
import '../views/kindness_reflection/kindness_reflection_detail_page.dart';

/// 認証とチュートリアルのガード処理
Future<String?> _authAndTutorialGuard(String location) async {
  final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

  // ログインページと登録ページは認証不要
  if (location == '/login' || location == '/register') {
    return null;
  }

  // 未認証の場合はログインページにリダイレクト
  if (!isLoggedIn) {
    return '/login';
  }

  // 認証済みの場合、チュートリアル完了状況をチェック
  final hasCompletedTutorial = await UserModel.hasCompletedTutorial();

  // チュートリアル未完了かつチュートリアルページでない場合、チュートリアルにリダイレクト
  if (!hasCompletedTutorial && location != '/tutorial') {
    return '/tutorial';
  }

  return null; // 問題なし
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) => _authAndTutorialGuard(state.uri.toString()),
  routes: [
    // ルートパスは認証後kindness-recordsにリダイレクト
    GoRoute(path: '/', redirect: (context, state) => '/kindness-records'),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    // チュートリアル画面
    GoRoute(
      path: '/tutorial',
      builder: (context, state) => const TutorialPage(),
    ),
    // kindness-giver系のルート（認証必須）
    GoRoute(
      path: '/kindness-givers',
      builder: (context, state) => const KindnessGiverListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const KindnessGiverAddPage(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final kindnessGiver = state.extra as KindnessGiver;
            return KindnessGiverEditPage(kindnessGiver: kindnessGiver);
          },
        ),
      ],
    ),
    // kindness-record系のルート（認証必須）
    GoRoute(
      path: '/kindness-records',
      builder: (context, state) => const KindnessRecordListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const KindnessRecordAddPage(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            return KindnessRecordEditPage(
              kindnessRecord: state.extra as KindnessRecord,
            );
          },
        ),
      ],
    ),
    // 設定画面（認証必須）
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    // リフレクション系のルート（認証必須）
    GoRoute(
      path: '/reflections',
      builder: (context, state) => const ReflectionListPage(),
      routes: [
        // リフレクション詳細ページのサブルート
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final reflection = state.extra as KindnessReflection?;
            final id = state.pathParameters['id'];
            return ReflectionDetailPage(
              reflection: reflection,
              reflectionId: id,
            );
          },
        ),
      ],
    ),
  ],
);
