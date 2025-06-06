import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/kindness_giver/kindness_giver_list_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_giver/kindness_giver_avatar.dart';
import '../../widgets/kindness_giver/kindness_giver_info_chip.dart';
import '../../utils/app_colors.dart';

class KindnessGiverListPage extends ConsumerStatefulWidget {
  const KindnessGiverListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<KindnessGiverListPage> createState() =>
      _KindnessGiverListPageState();
}

class _KindnessGiverListPageState extends ConsumerState<KindnessGiverListPage> {
  @override
  void initState() {
    super.initState();
    // 初期化時にデータを読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(kindnessGiverListViewModelProvider.notifier)
          .loadKindnessGivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kindnessGiverListViewModelProvider);
    final viewModel = ref.read(kindnessGiverListViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 8.0,
          bottom: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
            _buildMembersSection(state, viewModel, theme),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(viewModel, theme),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: 32.0,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'あなたの安全基地メンバー',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28), // アイコン分のインデント
            child: Text(
              '心の支えとなるメンバーを管理できます',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(state, viewModel, ThemeData theme) {
    if (state.isLoading) {
      return _buildLoadingCard(theme);
    }

    if (state.errorMessage != null) {
      return _buildErrorCard(state, viewModel, theme);
    }

    if (state.kindnessGivers.isEmpty) {
      return _buildEmptyCard(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.group_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'メンバー',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.kindnessGivers.length}人',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...state.kindnessGivers.map(
          (kindnessGiver) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMemberCard(kindnessGiver, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(kindnessGiver, ThemeData theme) {
    final viewModel = ref.read(kindnessGiverListViewModelProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // アバター（共通ウィジェット使用）
          KindnessGiverAvatar(kindnessGiver: kindnessGiver),
          const SizedBox(width: 16),

          // メンバー情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kindnessGiver.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // 情報チップ（共通ウィジェット使用）
                KindnessGiverInfoChip(kindnessGiver: kindnessGiver),
              ],
            ),
          ),

          // 編集ボタン
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => viewModel.navigateToEdit(context, kindnessGiver),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'メンバーを読み込み中...',
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(state, viewModel, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'エラーが発生しました',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage!,
            style: TextStyle(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => viewModel.loadKindnessGivers(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('再試行'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    final viewModel = ref.read(kindnessGiverListViewModelProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.people_outline,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'まだメンバーがいません',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '右下のボタンから\n最初のメンバーを追加しましょう',
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => viewModel.navigateToAdd(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('メンバーを追加'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(viewModel, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () => viewModel.navigateToAdd(context),
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 28),
      ),
    );
  }
}
