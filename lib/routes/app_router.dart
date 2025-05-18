import 'package:go_router/go_router.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/member_list_page.dart';
import '../views/home_page.dart';
import '../views/member_add_page.dart';
import '../views/kindness_record_list_page.dart';
import '../views/kindness_record_add_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/members',
      builder: (context, state) => const MemberListPage(),
    ),
    GoRoute(
      path: '/member/add',
      builder: (context, state) => const MemberAddPage(),
    ),
    GoRoute(
      path: '/kindness-records',
      builder: (context, state) => const KindnessRecordListPage(),
    ),
    GoRoute(
      path: '/kindness-record/add',
      builder: (context, state) => const KindnessRecordAddPage(),
    ),
  ],
);
