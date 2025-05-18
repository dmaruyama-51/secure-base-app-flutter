import 'package:go_router/go_router.dart';
import '../views/login_page.dart';
import '../views/register_page.dart';
import '../views/member/member_list_page.dart';
import '../views/home_page.dart';
import '../views/member/member_add_page.dart';
import '../views/member/member_edit_page.dart';
import '../models/kindness_giver.dart';

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
      path: '/kindness_giver',
      builder: (context, state) => const KindnessGiverListPage(),
    ),
    GoRoute(
      path: '/kindness_giver/add',
      builder: (context, state) => const KindnessGiverAddPage(),
    ),
    GoRoute(
      path: '/kindness_giver/edit/:id',
      builder: (context, state) {
        final kindnessGiver = state.extra as KindnessGiver;
        return KindnessGiverEditPage(kindnessGiver: kindnessGiver);
      },
    ),
  ],
);
