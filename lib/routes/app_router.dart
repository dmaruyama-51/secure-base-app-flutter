import 'package:go_router/go_router.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/member_list_page.dart';
import '../views/home_page.dart';
import '../views/member_add_page.dart';
import '../views/kindness_record_list_page.dart';
import '../views/kindness_record_add_page.dart';
import '../views/kindness_record_edit_page.dart';

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
      path: '/kindness-records/add',
      builder: (context, state) => const KindnessRecordAddPage(),
    ),
    GoRoute(
      path: '/kindness-records/edit/:id',
      builder: (context, state) {
        final idParam = state.pathParameters['id'];
        final id = int.tryParse(idParam ?? '');
        if (id == null) {
          // IDが無効な場合は一覧ページにリダイレクト
          return const KindnessRecordListPage();
        }
        return KindnessRecordEditPage(recordId: id);
      },
    ),
  ],
);
