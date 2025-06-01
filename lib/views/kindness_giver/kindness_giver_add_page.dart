import 'package:flutter/material.dart';
import 'package:secure_base/utils/app_colors.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../view_models/kindness_giver/kindness_giver_add_view_model.dart';

class KindnessGiverAddPage extends StatefulWidget {
  const KindnessGiverAddPage({Key? key}) : super(key: key);

  @override
  State<KindnessGiverAddPage> createState() => _KindnessGiverAddPageState();
}

class _KindnessGiverAddPageState extends State<KindnessGiverAddPage> {
  // ViewModelのインスタンス
  late KindnessGiverAddViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = KindnessGiverAddViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose(); // ViewModelのリソース解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // テーマを取得

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('メンバー追加', style: theme.textTheme.titleLarge),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          // エラーメッセージの表示
          if (_viewModel.errorMessage != null) {
            // エラーメッセージがあればSnackBarで表示
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(_viewModel.errorMessage!)));
              _viewModel.clearMessages();
            });
          }

          // 成功メッセージと画面遷移
          if (_viewModel.successMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_viewModel.successMessage!)),
              );

              if (_viewModel.shouldNavigateBack) {
                Navigator.of(context).pop();
              }

              _viewModel.clearMessages();
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // プロフィール画像（中央に表示）
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight,
                    ),
                    child: Center(
                      child: Icon(
                        _viewModel.getGenderIcon(_viewModel.selectedGender),
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 性別選択
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildGenderOption('女性'),
                      const SizedBox(width: 8),
                      _buildGenderOption('男性'),
                      const SizedBox(width: 8),
                      _buildGenderOption('ペット'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 名前/ニックネーム入力
                Text(
                  '名前 / ニックネーム',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _viewModel.nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.colorScheme.secondary,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    errorText: _viewModel.errorMessage,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 関係性選択
                Text(
                  '関係性',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRelationOption('家族'),
                      const SizedBox(width: 8),
                      _buildRelationOption('友達'),
                      const SizedBox(width: 8),
                      _buildRelationOption('パートナー'),
                      const SizedBox(width: 8),
                      _buildRelationOption('ペット'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 保存ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _viewModel.isSaving ? null : _saveKindnessGiver,
                    child:
                        _viewModel.isSaving
                            ? CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                            )
                            : Text(
                              '保存',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavigation(
        currentIndex: 1, // memberタブを選択
      ),
    );
  }

  // 性別選択オプションを構築
  Widget _buildGenderOption(String gender) {
    final theme = Theme.of(context);
    final isSelected = _viewModel.selectedGender == gender;

    return GestureDetector(
      onTap: () {
        _viewModel.selectGender(gender);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              _viewModel.getGenderIcon(gender),
              size: 16,
              color:
                  isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              gender,
              style: TextStyle(
                color:
                    isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 関係性選択オプションを構築
  Widget _buildRelationOption(String relation) {
    final theme = Theme.of(context);
    final isSelected = _viewModel.selectedRelation == relation;

    return GestureDetector(
      onTap: () {
        _viewModel.selectRelation(relation);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          relation,
          style: TextStyle(
            color:
                isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // メンバー保存処理
  Future<void> _saveKindnessGiver() async {
    await _viewModel.saveKindnessGiver();
  }
}
