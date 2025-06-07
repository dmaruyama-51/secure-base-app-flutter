import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/tutorial/tutorial_view_model.dart';
import '../../states/tutorial/tutorial_state.dart';
import '../../widgets/kindness_giver/gender_selection.dart';
import '../../widgets/kindness_giver/relation_selection.dart';
import '../../widgets/kindness_giver/kindness_giver_avatar.dart';
import '../../utils/app_colors.dart';

class TutorialPage extends ConsumerStatefulWidget {
  const TutorialPage({super.key});

  @override
  ConsumerState<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends ConsumerState<TutorialPage> {
  final PageController _pageController = PageController();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorialViewModelProvider);
    final viewModel = ref.read(tutorialViewModelProvider.notifier);
    final theme = Theme.of(context);

    // エラーメッセージの表示
    ref.listen(tutorialViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        viewModel.clearError();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // プログレスバー
            _buildProgressBar(state.currentPage, theme),
            // メインコンテンツ
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(theme),
                  _buildKindnessGiverRegistrationPage(state, viewModel, theme),
                ],
              ),
            ),
            // ナビゲーションボタン
            _buildNavigationButtons(state, viewModel, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentPage, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: (currentPage + 1) / 2,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${currentPage + 1}/2',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // アイコン
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          // タイトル
          Text(
            'ようこそ, xxxへ!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          // サブタイトル
          Text(
            '心の安全基地を\n育てていこう',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // 説明文
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '日々受け取っている小さな優しさに目を向けて、あなたが大切で価値ある存在であることを見える化するためのアプリです。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'まずは、あなたの安全基地のメンバーを登録しましょう。',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKindnessGiverRegistrationPage(
    TutorialState state,
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          _buildRegistrationHeader(theme),
          const SizedBox(height: 24),
          // アバター表示
          Center(
            child: KindnessGiverAvatar(
              gender: state.selectedGender,
              relationship: state.selectedRelation,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          // 名前入力
          _buildNameSection(state, viewModel, theme),
          const SizedBox(height: 20),
          // 性別選択
          _buildGenderSection(state, viewModel, theme),
          const SizedBox(height: 20),
          // 関係性選択
          _buildRelationSection(state, viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildRegistrationHeader(ThemeData theme) {
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
                Icons.person_add,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '最初のメンバーを登録',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'あなたの心の安全基地になる大切な人を登録しましょう。\n家族、友人、恋人など、どなたでも構いません。\nメンバーは後から変更できます。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(
    TutorialState state,
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '名前/ニックネーム *',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          onChanged: viewModel.updateName,
          decoration: InputDecoration(
            hintText: '名前/ニックネームを入力してください',
            hintStyle: TextStyle(color: AppColors.textLight),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSection(
    TutorialState state,
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GenderSelection(
          selectedGender: state.selectedGender,
          onGenderSelected: viewModel.updateGender,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildRelationSection(
    TutorialState state,
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        RelationSelection(
          selectedRelation: state.selectedRelation,
          onRelationSelected: viewModel.updateRelation,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    TutorialState state,
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 戻るボタン
          if (state.currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  viewModel.previousPage();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '戻る',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),
          if (state.currentPage > 0) const SizedBox(width: 16),
          // 次へ/完了ボタン
          Expanded(
            flex: state.currentPage == 0 ? 1 : 2,
            child: FilledButton(
              onPressed:
                  state.isCompleting
                      ? null
                      : () async {
                        if (state.currentPage == 0) {
                          // 次のページへ
                          viewModel.nextPage();
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // チュートリアル完了後はkindness-recordsに遷移
                          final success = await viewModel.completeTutorial();
                          if (success && mounted) {
                            context.go('/kindness-records');
                          }
                        }
                      },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  state.isCompleting
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                      : Text(
                        state.currentPage == 0 ? '次へ' : '始める',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
