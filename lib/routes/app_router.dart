import 'package:go_router/go_router.dart';
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
      path: '/kindness-records/edit/:id',
      builder: (context, state) {
        final record = state.extra as KindnessRecord?;
        if (record == null) {
          // Record not passed, redirect to list page
          return const KindnessRecordListPage();
        }
        return KindnessRecordEditPage(record: record);
      },
    ),
  ],
);
