// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../view_models/settings/settings_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/settings/settings_section.dart';
import '../../widgets/settings/settings_dialog.dart';
import '../../utils/app_colors.dart';

/// 設定画面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          final theme = Theme.of(context);

          // 初回読み込み
          if (!_initialized) {
            viewModel.initialize();
            _initialized = true;
          }

          // メッセージ表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
              viewModel.clearMessages();
            }
            if (viewModel.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(viewModel.successMessage!)),
              );
              viewModel.clearMessages();

              // 認証情報変更の場合のみログイン画面に遷移
              if (viewModel.successMessage!.contains('メールアドレス') ||
                  viewModel.successMessage!.contains('パスワード')) {
                context.go('/login');
              }
            }
          });

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: _buildAppBar(theme),
            body: Stack(
              children: [
                _buildBody(viewModel, theme),
                // ダイアログ表示
                if (viewModel.showEmailDialog)
                  EmailChangeDialog(viewModel: viewModel),
                if (viewModel.showPasswordDialog)
                  PasswordChangeDialog(viewModel: viewModel),
                if (viewModel.showReflectionDialog)
                  ReflectionSettingsDialog(viewModel: viewModel),
              ],
            ),
            bottomNavigationBar: const BottomNavigation(currentIndex: 3),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody(SettingsViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アカウント設定セクション
            SettingsSection(
              title: 'アカウント設定',
              icon: Icons.person_outline,
              children: [
                SettingsItem(
                  icon: Icons.email_outlined,
                  title: 'メールアドレス変更',
                  subtitle: 'ログイン用のメールアドレスを変更',
                  onTap: viewModel.showEmailChangeDialog,
                ),
                const SettingsDivider(),
                SettingsItem(
                  icon: Icons.lock_outline,
                  title: 'パスワード変更',
                  subtitle: 'ログイン用のパスワードを変更',
                  onTap: viewModel.showPasswordChangeDialog,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // アプリ設定セクション
            SettingsSection(
              title: 'アプリ設定',
              icon: Icons.tune,
              children: [
                Consumer<SettingsViewModel>(
                  builder:
                      (context, viewModel, child) => SettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'リフレクション設定',
                        subtitle: 'リフレクションの頻度を管理',
                        onTap: viewModel.showReflectionSettingsDialog,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 情報・サポートセクション
            SettingsSection(
              title: '情報・サポート',
              icon: Icons.help_outline,
              children: [
                SettingsItem(
                  icon: Icons.info_outline,
                  title: 'アプリについて',
                  subtitle: 'バージョン情報・開発者情報',
                  onTap: _showAboutDialog,
                ),
                const SettingsDivider(),
                SettingsItem(
                  icon: Icons.bug_report_outlined,
                  title: 'フィードバック',
                  subtitle: 'ご意見・バグ報告',
                  onTap: () {
                    // TODO: フィードバック機能
                  },
                ),
                const SettingsDivider(),
                SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'プライバシーポリシー',
                  subtitle: '個人情報の取り扱いについて',
                  onTap: () {
                    // TODO: プライバシーポリシー表示
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ログアウトセクション
            _buildLogoutSection(viewModel, theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(SettingsViewModel viewModel, ThemeData theme) {
    return SettingsSection(
      title: 'アカウント',
      icon: Icons.logout,
      children: [
        InkWell(
          onTap: () => _showLogoutDialog(viewModel),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ログアウト',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'アプリからログアウトします',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (viewModel.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.error,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(SettingsViewModel viewModel) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: theme.colorScheme.error, size: 24),
                const SizedBox(width: 8),
                const Text('ログアウト'),
              ],
            ),
            content: const Text('ログアウトしますか？\n次回利用時に再度ログインが必要になります。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'キャンセル',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  viewModel.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('ログアウト'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Secure Base App'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'バージョン 1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '心の安全基地を育てるアプリです。\n日々の小さな優しさを記録し、大切な人との関係を深めましょう。',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  '© 2024 Secure Base Team',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ],
          ),
    );
  }
}
