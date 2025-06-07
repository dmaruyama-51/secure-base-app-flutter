import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../view_models/settings/settings_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../utils/app_colors.dart';

/// 設定画面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    // ログアウト完了時の処理
    ref.listen(settingsViewModelProvider, (previous, next) {
      if (next.successMessage != null) {
        // ログアウト成功時はログイン画面に遷移
        context.go('/login');
      }

      if (next.errorMessage != null) {
        // エラー時はスナックバーで表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        viewModel.clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text('Settings', style: theme.textTheme.titleLarge),
      ),
      body: _buildBody(context, theme, state, viewModel),
      bottomNavigationBar: const BottomNavigation(
        currentIndex: 3, // Settingsタブを選択済みとして表示
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    dynamic state,
    dynamic viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アカウント設定セクション
          _buildSectionHeader(theme, 'アカウント'),
          const SizedBox(height: 12),

          // ログアウトボタン
          _buildLogoutButton(context, theme, state, viewModel),

          const Spacer(),

          // アプリ情報
          _buildAppInfo(theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ThemeData theme,
    dynamic state,
    dynamic viewModel,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              state.isLoading
                  ? null
                  : () => _showLogoutDialog(context, viewModel),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: Colors.red.shade600),
                const SizedBox(width: 12),
                Text(
                  'ログアウト',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (state.isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red.shade600,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Text(
            'Kindly',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, dynamic viewModel) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('本当にログアウトしますか？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
              ),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.signOut();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('ログアウト'),
            ),
          ],
        );
      },
    );
  }
}
