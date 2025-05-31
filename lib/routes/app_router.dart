import 'package:go_router/go_router.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/kindness_giver/kindness_giver_list_page.dart';
import '../views/home_page.dart';
import '../views/kindness_giver/kindness_giver_add_page.dart';
import '../views/kindness_giver/kindness_giver_edit_page.dart';
import '../views/kindness_reflection/kindness_reflection_list_page.dart';
import '../models/kindness_giver.dart';
import '../views/kindness_record_list_page.dart';
import '../views/kindness_record_add_page.dart';
import '../utils/constants.dart';
import '../views/kindness_reflection/kindness_reflection_summary_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // 現在のユーザー情報を取得
    final currentUser = supabase.auth.currentUser;

    // 現在のパス
    final currentPath = state.uri.path;

    // 認証が必要なパスのリスト
    final requiresAuth = [
      '/kindness-givers',
      '/kindness-givers/add',
      '/reflections',
      '/reflections/summary',
    ];

    // 現在のパスが認証が必要なパスかどうか
    final requiresAuthForCurrentPath = requiresAuth.any(
      (path) => currentPath.startsWith(path),
    );

    // 認証が必要なパスにアクセスしようとしているが、ログインしていない場合
    if (requiresAuthForCurrentPath && currentUser == null) {
      return '/login';
    }

    // ログイン済みでログインページにアクセスしようとしている場合
    if ((currentPath == '/login' || currentPath == '/register') &&
        currentUser != null) {
      return '/';
    }

    // それ以外の場合は通常のルーティング
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
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
    GoRoute(
      path: '/kindness-records',
      builder: (context, state) => const KindnessRecordListPage(),
    ),
    GoRoute(
      path: '/kindness-records/add',
      builder: (context, state) => const KindnessRecordAddPage(),
    ),
    GoRoute(
      path: '/reflections',
      builder: (context, state) => const ReflectionPage(),
    ),
    GoRoute(
      path: '/reflections/summary/:id',
      builder: (context, state) {
        final summaryId = state.pathParameters['id']!;
        return ReflectionSummaryPage(summaryId: summaryId);
      },
    ),
  ],
);
