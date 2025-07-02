// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../view_models/auth/auth_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          // エラーメッセージの表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              context.showErrorSnackBar(message: viewModel.errorMessage!);
              viewModel.clearNavigation();
            }
          });

          // 成功時のナビゲーション
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.shouldNavigate && viewModel.navigationPath != null) {
              context.go(viewModel.navigationPath!);
              viewModel.clearNavigation();
            }
          });

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ロゴとタイトル
                        _buildHeader(),

                        const SizedBox(height: 48),

                        // ログインフォーム
                        _buildLoginForm(viewModel),

                        const SizedBox(height: 32),

                        // 区切り線とアカウント作成リンク
                        _buildRegisterSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // より大きな円形デザイン
        Container(
          width: 180,
          height: 180,
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
              'assets/images/img_giftbox.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // タイトル（デフォルトフォント使用）
        const Text(
          'Kindly',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // サブタイトル（デフォルトフォント使用）
        const Text(
          '心の安全基地を育むアプリ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textLight,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // メールアドレス
        _buildTextField(
          controller: _emailController,
          label: 'メールアドレス',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // パスワード
        _buildTextField(
          controller: _passwordController,
          label: 'パスワード',
          obscureText: true,
        ),
        const SizedBox(height: 24),

        // ログインボタン
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed:
                viewModel.isLoading ? null : () => _handleSignIn(viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.largeRadius,
              ),
            ),
            child:
                viewModel.isLoading
                    ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                      ),
                    )
                    : const Text(
                      'ログイン',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  void _handleSignIn(AuthViewModel viewModel) {
    final redirectPath =
        GoRouter.of(
          context,
        ).routeInformationProvider.value.uri.queryParameters['redirect'];

    viewModel.signIn(
      email: _emailController.text,
      password: _passwordController.text,
      redirectPath: redirectPath,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ラベル（デフォルトフォント使用）
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.text,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.largeRadius,
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.largeRadius,
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.largeRadius,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterSection() {
    return Column(
      children: [
        // 区切り線
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.divider.withOpacity(0.3))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'または',
                style: TextStyle(fontSize: 14, color: AppColors.textLight),
              ),
            ),
            Expanded(child: Divider(color: AppColors.divider.withOpacity(0.3))),
          ],
        ),
        const SizedBox(height: 24),

        // アカウント作成ボタン
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => context.go('/register'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.border.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.largeRadius,
              ),
            ),
            child: const Text(
              'アカウントを作成',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
