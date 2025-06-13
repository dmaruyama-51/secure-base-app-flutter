// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../view_models/settings/settings_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';

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

          // エラーメッセージと成功メッセージの監視
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

              // ログアウト後にログイン画面に遷移
              context.go('/login');
            }
          });

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: _buildAppBar(theme),
            body: _buildBody(viewModel, theme),
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
      title: Text(
        '設定',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
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
            _buildAccountSettingsSection(theme),
            const SizedBox(height: 24),

            // アプリ設定セクション
            _buildAppSettingsSection(theme),
            const SizedBox(height: 24),

            // 情報・サポートセクション
            _buildInfoSupportSection(theme),
            const SizedBox(height: 24),

            // ログアウトセクション
            _buildLogoutSection(viewModel, theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsSection(ThemeData theme) {
    return _buildSection(
      title: 'アカウント設定',
      icon: Icons.person_outline,
      theme: theme,
      children: [
        _buildSettingItem(
          icon: Icons.email_outlined,
          title: 'メールアドレス変更',
          subtitle: 'ログイン用のメールアドレスを変更',
          onTap: () {
            _showChangeEmailDialog();
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildSettingItem(
          icon: Icons.lock_outline,
          title: 'パスワード変更',
          subtitle: 'ログイン用のパスワードを変更',
          onTap: () {
            _showChangePasswordDialog();
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection(ThemeData theme) {
    return _buildSection(
      title: 'アプリ設定',
      icon: Icons.tune,
      theme: theme,
      children: [
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          title: '通知設定',
          subtitle: 'リフレクションの通知を管理',
          onTap: () {
            // TODO: 通知設定画面に遷移
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildInfoSupportSection(ThemeData theme) {
    return _buildSection(
      title: '情報・サポート',
      icon: Icons.help_outline,
      theme: theme,
      children: [
        _buildSettingItem(
          icon: Icons.info_outline,
          title: 'アプリについて',
          subtitle: 'バージョン情報・開発者情報',
          onTap: () {
            _showAboutDialog();
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildSettingItem(
          icon: Icons.bug_report_outlined,
          title: 'フィードバック',
          subtitle: 'ご意見・バグ報告',
          onTap: () {
            // TODO: フィードバック機能
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildSettingItem(
          icon: Icons.privacy_tip_outlined,
          title: 'プライバシーポリシー',
          subtitle: '個人情報の取り扱いについて',
          onTap: () {
            // TODO: プライバシーポリシー表示
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildLogoutSection(SettingsViewModel viewModel, ThemeData theme) {
    return _buildSection(
      title: 'アカウント管理',
      icon: Icons.account_circle_outlined,
      theme: theme,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap:
                viewModel.isLoading ? null : () => _showLogoutDialog(viewModel),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
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
                          'アカウントからログアウトします',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.65,
                            ),
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
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        _buildSettingCard(theme: theme, child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingCard({required ThemeData theme, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: child,
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            theme.colorScheme.primary.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  void _showChangeEmailDialog() {
    final theme = Theme.of(context);
    final currentEmailController = TextEditingController();
    final newEmailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text('メールアドレス変更'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentEmailController,
                  decoration: const InputDecoration(
                    labelText: '現在のメールアドレス',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newEmailController,
                  decoration: const InputDecoration(
                    labelText: '新しいメールアドレス',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  currentEmailController.dispose();
                  newEmailController.dispose();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'キャンセル',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: メールアドレス変更処理
                  currentEmailController.dispose();
                  newEmailController.dispose();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('メールアドレスの変更機能は実装予定です')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('変更'),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog() {
    final theme = Theme.of(context);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text('パスワード変更'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: '現在のパスワード',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: '新しいパスワード',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: '新しいパスワード（確認）',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  currentPasswordController.dispose();
                  newPasswordController.dispose();
                  confirmPasswordController.dispose();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'キャンセル',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: パスワード変更処理
                  currentPasswordController.dispose();
                  newPasswordController.dispose();
                  confirmPasswordController.dispose();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('パスワードの変更機能は実装予定です')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('変更'),
              ),
            ],
          ),
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
