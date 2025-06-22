// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../utils/app_colors.dart';
import '../../view_models/tutorial/tutorial_view_model.dart';
import '../../widgets/kindness_giver/gender_selection.dart';
import '../../widgets/kindness_giver/kindness_giver_avatar.dart';
import '../../widgets/kindness_giver/relation_selection.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  late TextEditingController _nameController;
  late TextEditingController _kindnessController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _kindnessController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _kindnessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TutorialViewModel(),
      child: Consumer<TutorialViewModel>(
        builder: (context, viewModel, child) {
          final theme = Theme.of(context);

          // エラーメッセージの表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
              viewModel.clearErrorMessage();
            }
          });

          // ナビゲーション処理
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.shouldNavigateNext && mounted) {
              _pageController.nextPage(
                duration: Duration(
                  milliseconds: TutorialViewModel.pageAnimationDurationMs,
                ),
                curve: Curves.easeInOut,
              );
              viewModel.clearNavigationState();
            }

            if (viewModel.shouldNavigateToMain && mounted) {
              // チュートリアル完了マークの反映を待つ
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  context.go('/kindness-records');
                }
              });
              viewModel.clearNavigationState();
            }
          });

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // プログレスバー
                  _buildProgressBar(viewModel.currentPage, theme),
                  // メインコンテンツ
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildWelcomePage(theme),
                        _buildKindnessGiverRegistrationPage(viewModel, theme),
                        _buildKindnessRecordPage(viewModel, theme),
                        _buildReflectionSettingPage(viewModel, theme),
                      ],
                    ),
                  ),
                  // ナビゲーションボタン
                  _buildNavigationButtons(viewModel, theme),
                ],
              ),
            ),
          );
        },
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
              value: (currentPage + 1) / TutorialViewModel.totalPages,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${currentPage + 1}/${TutorialViewModel.totalPages}',
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
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryLight.withOpacity(0.4),
                  AppColors.secondary.withOpacity(0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/images/img_welcome.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // タイトル
          Text(
            'ようこそ, Kindlyへ!',
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
                  'Kindly は日々受け取っている小さな優しさに目を向けて、心がほっとする場所を作っていくアプリです。',
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
              gender: viewModel.selectedGender,
              relationship: viewModel.selectedRelation,
              size: 120,
            ),
          ),
          const SizedBox(height: 24),
          // 名前入力
          _buildNameSection(viewModel, theme),
          const SizedBox(height: 20),
          // 性別選択
          _buildGenderSection(viewModel, theme),
          const SizedBox(height: 20),
          // 関係性選択
          _buildRelationSection(viewModel, theme),
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
            'あなたにやさしさを向けてくれる大切な人を登録しましょう。\n家族、友人、恋人など、どなたでも構いません。\nメンバーは後から変更や追加もできます。',
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

  Widget _buildNameSection(TutorialViewModel viewModel, ThemeData theme) {
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
            hintText: '名前かニックネームを入力してください',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
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

  Widget _buildGenderSection(TutorialViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GenderSelection(
          selectedGender: viewModel.selectedGender,
          onGenderSelected: viewModel.updateGender,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildRelationSection(TutorialViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        RelationSelection(
          selectedRelation: viewModel.selectedRelation,
          onRelationSelected: viewModel.updateRelation,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildKindnessRecordPage(
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          _buildKindnessRecordHeader(viewModel, theme),
          const SizedBox(height: 24),
          // アバター表示
          Center(
            child: KindnessGiverAvatar(
              gender: viewModel.selectedGender,
              relationship: viewModel.selectedRelation,
              size: 100,
            ),
          ),
          const SizedBox(height: 16),
          // 名前表示
          Center(
            child: Text(
              viewModel.kindnessGiverName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 優しさ記録入力
          _buildKindnessContentSection(viewModel, theme),
          const SizedBox(height: 24),
          // 例文表示
          _buildExampleSection(theme),
        ],
      ),
    );
  }

  Widget _buildKindnessRecordHeader(
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
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
              Icon(Icons.edit_note, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '最初の優しさを記録してみましょう',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '最近${viewModel.kindnessGiverName}さんから受け取った小さな優しさはありませんか？\n些細なことでも構いません。この記録はスキップも可能です。',
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

  Widget _buildKindnessContentSection(
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '優しさの内容',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _kindnessController,
          onChanged: viewModel.updateKindnessContent,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '例：疲れているときに「お疲れ様」と声をかけてくれた',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
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

  Widget _buildExampleSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '記録のヒント',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '小さな出来事も、心の支えとなるかけがえのない記録になります：\n・笑顔であいさつをもらった瞬間\n・体調を気にかけてくれたひと言\n・話をじっくり聞いてくれたとき\n・ちょっとした手助けをもらったこと',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSettingPage(
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          _buildReflectionHeader(theme),
          const SizedBox(height: 32),
          // アイコン表示 → 画像表示に変更
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.4),
                    AppColors.secondary.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/img_mindfulness.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 機能説明
          _buildReflectionDescription(theme),
          const SizedBox(height: 32),
          // 頻度選択
          _buildFrequencySelection(viewModel, theme),
        ],
      ),
    );
  }

  Widget _buildReflectionHeader(ThemeData theme) {
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
                Icons.auto_awesome,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'リフレクション',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '設定した頻度で、受け取った優しさを振り返る機会をお届けします。',
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

  Widget _buildReflectionDescription(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'リフレクションでできること',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            theme,
            Icons.summarize,
            '受け取ったやさしさのサマリ',
            '期間中に記録した優しさをまとめて表示',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            theme,
            Icons.schedule,
            '定期的な振り返り',
            '忙しい日常でも大切なことを思い出せる',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            theme,
            Icons.volunteer_activism,
            'あたたかい気持ちを育てる',
            '自然と大切な相手にやさしくなれる',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelection(
    TutorialViewModel viewModel,
    ThemeData theme,
  ) {
    final frequencies = ['週に1回', '2週に1回', '月に1回'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'リフレクションの頻度',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...frequencies
            .map(
              (frequency) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  value: frequency,
                  groupValue: viewModel.selectedReflectionFrequency,
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.updateReflectionFrequency(value);
                    }
                  },
                  title: Text(
                    frequency,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: FutureBuilder<String>(
                    future: viewModel.getFrequencyDescription(frequency),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                      );
                    },
                  ),
                  activeColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          viewModel.selectedReflectionFrequency == frequency
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  tileColor:
                      viewModel.selectedReflectionFrequency == frequency
                          ? theme.colorScheme.primary.withOpacity(0.05)
                          : theme.colorScheme.surface,
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildNavigationButtons(TutorialViewModel viewModel, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 戻るボタン
          if (viewModel.shouldShowBackButton())
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  viewModel.previousPage();
                  _pageController.previousPage(
                    duration: Duration(
                      milliseconds: TutorialViewModel.pageAnimationDurationMs,
                    ),
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
          if (viewModel.shouldShowBackButton()) const SizedBox(width: 16),

          // スキップボタン
          if (viewModel.shouldShowSkipButton())
            Expanded(
              child: OutlinedButton(
                onPressed: () => viewModel.executeSkipAction(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.textLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'スキップ',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ),
            ),
          if (viewModel.shouldShowSkipButton()) const SizedBox(width: 16),

          // 次へ/完了ボタン
          Expanded(
            flex:
                viewModel.currentPage == TutorialViewModel.introductionPageIndex
                    ? 1
                    : 2,
            child: FilledButton(
              onPressed:
                  viewModel.isNextButtonDisabled()
                      ? null
                      : () => viewModel.executeNextAction(),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  viewModel.isNextButtonLoading()
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
                        viewModel.getNextButtonText(),
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
