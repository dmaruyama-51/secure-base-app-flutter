import 'package:flutter/material.dart';
import 'package:secure_base/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(builder: (context) => const RegisterPage());
  }

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    try {
      await supabase.auth.signUp(email: email, password: password);
      // 登録後はホーム画面に遷移
      if (mounted) {
        context.go('/');
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登録')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(label: Text('メールアドレス')),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return '必須';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(label: Text('パスワード')),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return '必須';
                }
                if (val.length < 6) {
                  return '6文字以上';
                }
                return null;
              },
            ),
            formSpacer,
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('登録'),
            ),
            formSpacer,
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('すでにアカウントをお持ちの方はこちら'),
            ),
          ],
        ),
      ),
    );
  }
}
