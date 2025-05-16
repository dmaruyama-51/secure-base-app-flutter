import 'package:flutter/material.dart';
import '../widgets/common/bottom_navigation.dart';
import '../view_models/member_add_view_model.dart';

class MemberAddPage extends StatefulWidget {
  const MemberAddPage({Key? key}) : super(key: key);

  @override
  State<MemberAddPage> createState() => _MemberAddPageState();
}

class _MemberAddPageState extends State<MemberAddPage> {
  // ViewModelのインスタンス
  late MemberAddViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MemberAddViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose(); // ViewModelのリソース解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add new member',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
                      color: Colors.orange.shade100,
                    ),
                    child: Center(
                      child: Icon(
                        _viewModel.getGenderIcon(_viewModel.selectedGender),
                        size: 80,
                        color: Colors.orange,
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
                const Text(
                  '名前 / ニックネーム',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _viewModel.nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _viewModel.errorMessage,
                  ),
                ),
                const SizedBox(height: 24),

                // 関係性選択
                const Text(
                  '関係性',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRelationOption('Family'),
                      const SizedBox(width: 8),
                      _buildRelationOption('Friend'),
                      const SizedBox(width: 8),
                      _buildRelationOption('Partner'),
                      const SizedBox(width: 8),
                      _buildRelationOption('Pet'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 保存ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _viewModel.isSaving ? null : _saveMember,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _viewModel.isSaving
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Save',
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
    final isSelected = _viewModel.selectedGender == gender;

    return GestureDetector(
      onTap: () {
        _viewModel.selectGender(gender);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              _viewModel.getGenderIcon(gender),
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 4),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 関係性選択オプションを構築
  Widget _buildRelationOption(String relation) {
    final isSelected = _viewModel.selectedRelation == relation;

    return GestureDetector(
      onTap: () {
        _viewModel.selectRelation(relation);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          relation,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // メンバー保存処理
  Future<void> _saveMember() async {
    await _viewModel.saveMember();
  }
}
