import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/kindness_giver.dart';
import '../../view_models/kindness_giver/kindness_giver_edit_view_model.dart';
import '../../view_models/kindness_giver/kindness_giver_list_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../utils/app_colors.dart';
import '../../widgets/kindness_giver/kindness_giver_avatar.dart';
import '../../widgets/kindness_giver/gender_selection.dart';
import '../../widgets/kindness_giver/relation_selection.dart';

class KindnessGiverEditPage extends ConsumerStatefulWidget {
  final KindnessGiver kindnessGiver;

  const KindnessGiverEditPage({super.key, required this.kindnessGiver});

  @override
  ConsumerState<KindnessGiverEditPage> createState() =>
      _KindnessGiverEditPageState();
}

class _KindnessGiverEditPageState extends ConsumerState<KindnessGiverEditPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.kindnessGiver.giverName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      kindnessGiverEditViewModelProvider(widget.kindnessGiver),
    );
    final viewModel = ref.read(
      kindnessGiverEditViewModelProvider(widget.kindnessGiver).notifier,
    );
    final theme = Theme.of(context);

    // 成功メッセージと画面遷移の処理
    ref.listen(kindnessGiverEditViewModelProvider(widget.kindnessGiver), (
      previous,
      next,
    ) {
      if (next.shouldNavigateBack) {
        viewModel.clearMessages();
        ref
            .read(kindnessGiverListViewModelProvider.notifier)
            .loadKindnessGivers();
        GoRouter.of(context).pop();
      }

      if (next.successMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.successMessage!)));
      }

      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
            _buildNameSection(state, viewModel, theme),
            const SizedBox(height: 24),
            _buildGenderSection(state, viewModel, theme),
            const SizedBox(height: 24),
            _buildRelationSection(state, viewModel, theme),
            const SizedBox(height: 40),
            _buildUpdateButton(state, viewModel, theme),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        onPressed: () => GoRouter.of(context).pop(),
      ),
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
                Icons.edit_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'メンバー情報を編集',
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
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              '${widget.kindnessGiver.giverName}さんの情報を更新できます',
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

  Widget _buildNameSection(state, viewModel, ThemeData theme) {
    return _buildCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('名前', Icons.edit_outlined, theme),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.secondary, width: 1),
            ),
            child: TextField(
              controller: _nameController,
              onChanged: viewModel.updateName,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: '名前またはニックネームを入力',
                hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection(state, viewModel, ThemeData theme) {
    return _buildCard(
      theme,
      child: GenderSelection(
        selectedGender: state.selectedGender,
        onGenderSelected: viewModel.selectGender,
        theme: theme,
      ),
    );
  }

  Widget _buildRelationSection(state, viewModel, ThemeData theme) {
    return _buildCard(
      theme,
      child: RelationSelection(
        selectedRelation: state.selectedRelation,
        onRelationSelected: viewModel.selectRelation,
        theme: theme,
      ),
    );
  }

  Widget _buildCard(ThemeData theme, {required Widget child}) {
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
          color: theme.colorScheme.secondary.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(state, viewModel, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSaving ? null : viewModel.updateKindnessGiver,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child:
            state.isSaving
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.update_outlined,
                      size: 20,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'メンバー情報を更新',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
