// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../view_models/settings/settings_view_model.dart';
import '../../utils/app_colors.dart';
import 'settings_form_field.dart';

/// ベース設定ダイアログ
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

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
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
    return BaseSettingsDialog(
      title: 'メールアドレス変更',
      icon: Icons.email_outlined,
      onClose: viewModel.closeDialogs,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    return BaseSettingsDialog(
      title: 'パスワード変更',
      icon: Icons.lock_outline,
      onClose: viewModel.closeDialogs,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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

  static const List<String> _reflectionFrequencies = ['週に1回', '2週に1回', '月に1回'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseSettingsDialog(
      title: 'リフレクション設定',
      icon: Icons.notifications_outlined,
      onClose: viewModel.closeDialogs,
      child:
          viewModel.isLoadingReflectionSettings
              ? const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '設定した頻度で、受け取った優しさを振り返る機会をお届けします。',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'リフレクションの頻度',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 正しい頻度選択肢のみを表示
                    ..._reflectionFrequencies
                        .map(
                          (frequency) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    viewModel.selectedReflectionFrequency ==
                                            frequency
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.primary.withOpacity(
                                          0.2,
                                        ),
                              ),
                            ),
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
                              subtitle: Text(
                                viewModel.getFrequencyDescription(frequency),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),
                              activeColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tileColor:
                                  viewModel.selectedReflectionFrequency ==
                                          frequency
                                      ? theme.colorScheme.primary.withOpacity(
                                        0.05,
                                      )
                                      : theme.colorScheme.surface,
                            ),
                          ),
                        )
                        .toList(),
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
