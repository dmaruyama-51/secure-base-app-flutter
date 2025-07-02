// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../utils/app_colors.dart';
import '../../view_models/kindness_giver/kindness_giver_list_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_giver/kindness_giver_card.dart';

class KindnessGiverListPage extends StatefulWidget {
  const KindnessGiverListPage({super.key});

  @override
  State<KindnessGiverListPage> createState() => _KindnessGiverListPageState();
}

class _KindnessGiverListPageState extends State<KindnessGiverListPage> {
  KindnessGiverListViewModel? _viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KindnessGiverListViewModel()..loadKindnessGivers(),
      child: Consumer<KindnessGiverListViewModel>(
        builder: (context, viewModel, child) {
          _viewModel = viewModel; // ViewModelインスタンスを保存
          final theme = Theme.of(context);

          // メッセージ表示処理
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
            if (viewModel.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _buildAppBar(theme),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 8.0,
                bottom: 100.0, // FloatingActionButton + BottomNavigation + 余白
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 16),
                  _buildMembersSection(viewModel, theme),
                ],
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(viewModel, theme),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: const BottomNavigation(currentIndex: 1),
          );
        },
      ),
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
      padding: const EdgeInsets.all(12),
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
              Icon(Icons.people, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '安全基地メンバー',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '支え合いの輪を広げていきましょう',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    if (viewModel.isLoading) {
      return _buildLoadingCard(theme);
    }

    if (viewModel.errorMessage != null) {
      return _buildErrorCard(viewModel, theme);
    }

    if (viewModel.kindnessGivers.isEmpty) {
      return _buildEmptyCard(viewModel, theme);
    }

    final groupedMembers = viewModel.getGroupedMembers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // アクティブセクション
        if (groupedMembers.containsKey('アクティブ'))
          ..._buildSection(
            'アクティブ',
            groupedMembers['アクティブ']!,
            viewModel,
            theme,
            isFirst: true,
          ),

        // 凡例（アクティブとアーカイブの間）
        if (groupedMembers.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildLegend(theme),
          const SizedBox(height: 8),
        ],

        // アーカイブセクション
        if (groupedMembers.containsKey('アーカイブ'))
          ..._buildSection(
            'アーカイブ',
            groupedMembers['アーカイブ']!,
            viewModel,
            theme,
            isFirst: false,
          ),
      ],
    );
  }

  List<Widget> _buildSection(
    String sectionKey,
    List<KindnessGiver> members,
    KindnessGiverListViewModel viewModel,
    ThemeData theme, {
    required bool isFirst,
  }) {
    final isArchiveSection = sectionKey == 'アーカイブ';

    return [
      // セクションヘッダー
      _buildSectionHeader(
        sectionKey,
        members.length,
        theme,
        isFirst: isFirst,
        isArchiveSection: isArchiveSection,
        isExpanded:
            isArchiveSection ? viewModel.isArchiveSectionExpanded : true,
        onToggle:
            isArchiveSection
                ? () => viewModel.toggleArchiveSectionExpanded()
                : null,
      ),

      // メンバーリスト（アーカイブセクションは展開時のみ表示）
      AnimatedCrossFade(
        firstChild: const SizedBox.shrink(),
        secondChild: Column(
          children:
              members
                  .map(
                    (kindnessGiver) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildKindnessGiverCard(
                        kindnessGiver,
                        viewModel,
                        theme,
                      ),
                    ),
                  )
                  .toList(),
        ),
        crossFadeState:
            (!isArchiveSection || viewModel.isArchiveSectionExpanded)
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    ];
  }

  Widget _buildKindnessGiverCard(
    KindnessGiver kindnessGiver,
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    final bool isArchived = kindnessGiver.isArchived;

    return Opacity(
      opacity: isArchived ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              isArchived
                  ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1)
                  : null,
        ),
        child: KindnessGiverCard(
          kindnessGiver: kindnessGiver,
          onTap: () => _navigateToEdit(kindnessGiver),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 12),
          Text(
            'メンバーを読み込み中...',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
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
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'エラーが発生しました',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            viewModel.errorMessage!,
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => viewModel.loadKindnessGivers(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('再試行'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          // イラスト的なアバターコンテナ
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.people_outline,
              size: 32,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'まだメンバーがいません',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '右下のボタンから\n最初のメンバーを追加しましょう',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    KindnessGiverListViewModel viewModel,
    ThemeData theme,
  ) {
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
      child: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'メンバーを追加',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _navigateToAdd() {
    context.push('/kindness-givers/add').then((_) {
      // 追加ページから戻ってきた際にリストを再読み込み
      if (_viewModel != null) {
        _viewModel!.refreshKindnessGivers();
      }
    });
  }

  void _navigateToEdit(KindnessGiver kindnessGiver) {
    context
        .push('/kindness-givers/edit/${kindnessGiver.id}', extra: kindnessGiver)
        .then((_) {
          // 編集ページから戻ってきた際にリストを再読み込み
          if (_viewModel != null) {
            _viewModel!.refreshKindnessGivers();
          }
        });
  }

  Widget _buildLegendIconChip(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLegendIconChip(Icons.inbox, Colors.pink.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '受け取ったやさしさの数',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildLegendIconChip(Icons.send, Colors.blue.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '送ったやさしさの数',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String sectionKey,
    int memberCount,
    ThemeData theme, {
    bool isFirst = false,
    bool isArchiveSection = false,
    bool isExpanded = true,
    VoidCallback? onToggle,
  }) {
    return Container(
      margin: EdgeInsets.only(top: isFirst ? 16 : 24, bottom: 8),
      child: Row(
        children: [
          Icon(
            sectionKey == 'アクティブ'
                ? Icons.people_outline
                : Icons.archive_outlined,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            sectionKey,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:
                  isArchiveSection && !isExpanded
                      ? theme.colorScheme.secondary.withOpacity(0.15)
                      : theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${memberCount}人',
              style: TextStyle(
                fontSize: 11,
                color:
                    isArchiveSection && !isExpanded
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isArchiveSection)
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
