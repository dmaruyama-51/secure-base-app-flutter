// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/constants.dart';
import '../../view_models/settings/settings_view_model.dart';
import 'settings_form_field.dart';

/// 基本的な設定ダイアログのベースクラス
class BaseSettingsDialog extends StatelessWidget {
  const BaseSettingsDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.onClose,
    required this.child,
  });

  final String title;
  final IconData icon;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppBorderRadius.extraLargeRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppBorderRadius.extraLarge),
                    topRight: Radius.circular(AppBorderRadius.extraLarge),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: AppBorderRadius.mediumRadius,
                      ),
                      child: Icon(
                        icon,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// メールアドレス変更ダイアログ
class EmailChangeDialog extends StatelessWidget {
  const EmailChangeDialog({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseSettingsDialog(
      title: 'メールアドレス変更',
      icon: Icons.email_outlined,
      onClose: viewModel.closeDialogs,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 自動ログアウトの説明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: AppBorderRadius.mediumRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'メールアドレス変更後、セキュリティのため自動的にログアウトされます',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SettingsFormField(
              value: viewModel.currentEmail,
              onChanged: viewModel.updateCurrentEmail,
              label: '現在のメールアドレス',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SettingsFormField(
              value: viewModel.newEmail,
              onChanged: viewModel.updateNewEmail,
              label: '新しいメールアドレス',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),
            SettingsActionButtons(
              onCancel: viewModel.closeDialogs,
              onConfirm: viewModel.changeEmail,
              confirmText: '変更',
              isLoading: viewModel.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

/// パスワード変更ダイアログ
class PasswordChangeDialog extends StatelessWidget {
  const PasswordChangeDialog({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseSettingsDialog(
      title: 'パスワード変更',
      icon: Icons.lock_outline,
      onClose: viewModel.closeDialogs,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 自動ログアウトの説明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: AppBorderRadius.mediumRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'パスワード変更後、セキュリティのため自動的にログアウトされます',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SettingsFormField(
              value: viewModel.currentPassword,
              onChanged: viewModel.updateCurrentPassword,
              label: '現在のパスワード',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SettingsFormField(
              value: viewModel.newPassword,
              onChanged: viewModel.updateNewPassword,
              label: '新しいパスワード',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SettingsFormField(
              value: viewModel.confirmPassword,
              onChanged: viewModel.updateConfirmPassword,
              label: 'パスワード確認',
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SettingsActionButtons(
              onCancel: viewModel.closeDialogs,
              onConfirm: viewModel.changePassword,
              confirmText: '変更',
              isLoading: viewModel.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

/// リフレクション設定ダイアログ
class ReflectionSettingsDialog extends StatelessWidget {
  const ReflectionSettingsDialog({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = ['週に1回', '2週に1回', '月に1回'];

    return BaseSettingsDialog(
      title: 'リフレクション設定',
      icon: Icons.notifications_outlined,
      onClose: viewModel.closeDialogs,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'リフレクションの頻度を選択してください',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),

            if (viewModel.isLoadingReflectionSettings)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children:
                    options.map((option) {
                      final isSelected =
                          viewModel.selectedReflectionFrequency == option;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap:
                              () => viewModel.updateReflectionFrequency(option),
                          borderRadius: AppBorderRadius.mediumRadius,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary.withOpacity(
                                        0.1,
                                      )
                                      : theme.colorScheme.surface,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline.withOpacity(
                                          0.3,
                                        ),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: AppBorderRadius.mediumRadius,
                            ),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: option,
                                  groupValue:
                                      viewModel.selectedReflectionFrequency,
                                  onChanged: (value) {
                                    if (value != null) {
                                      viewModel.updateReflectionFrequency(
                                        value,
                                      );
                                    }
                                  },
                                  activeColor: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                              color:
                                                  isSelected
                                                      ? theme
                                                          .colorScheme
                                                          .primary
                                                      : theme
                                                          .colorScheme
                                                          .onSurface,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      FutureBuilder<String>(
                                        future: viewModel
                                            .getFrequencyDescription(option),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? '',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

            const SizedBox(height: 32),
            SettingsActionButtons(
              onCancel: viewModel.closeDialogs,
              onConfirm: viewModel.saveReflectionSettings,
              confirmText: '保存',
              isLoading: viewModel.isLoadingReflectionSettings,
            ),
          ],
        ),
      ),
    );
  }
}
