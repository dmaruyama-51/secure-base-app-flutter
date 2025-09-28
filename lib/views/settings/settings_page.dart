// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../utils/constants.dart';
import '../../view_models/settings/settings_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/settings/settings_section.dart';
import '../../widgets/settings/settings_dialog.dart';

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
              // 認証情報変更（メールアドレス・パスワード）の場合は自動ログアウト
              if (viewModel.successMessage!.contains('パスワード') ||
                  viewModel.successMessage!.contains('メールアドレス')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.successMessage!),
                    backgroundColor: theme.colorScheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
                viewModel.clearMessages();
                // 2秒後にログアウト
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    context.go('/login');
                  }
                });
              } else {
                // その他の変更は通常のスナックバーを表示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.successMessage!)),
                );
                viewModel.clearMessages();
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
      toolbarHeight: 20, // AppBarを完全に非表示にして余白を削除
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
                        icon: Icons.auto_awesome,
                        title: 'リフレクション設定',
                        subtitle: 'リフレクションの頻度を変更',
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
                  onTap: viewModel.openFeedbackForm,
                ),
                const SettingsDivider(),
                SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'プライバシーポリシー',
                  subtitle: '個人情報の取り扱いについて',
                  onTap: viewModel.openPrivacyPolicy,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ログアウトセクション
            const SizedBox(height: 16),
            _buildLogoutSection(viewModel, theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(SettingsViewModel viewModel, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.largeRadius,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showLogoutDialog(viewModel),
        borderRadius: AppBorderRadius.largeRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.08),
                  borderRadius: AppBorderRadius.largeRadius,
                ),
                child: Icon(
                  Icons.logout,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'ログアウト',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.error,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(SettingsViewModel viewModel) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.extraLargeRadius,
          ),
          title: const Text('ログアウト'),
          content: const Text('本当にログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await viewModel.signOut();
                if (mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('ログアウト'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.extraLargeRadius,
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: AppBorderRadius.largeRadius,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Kindly')),
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
                Text('心の安全基地を育てるアプリです。', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text(
                  '© 2025 Team Secure-base',
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
