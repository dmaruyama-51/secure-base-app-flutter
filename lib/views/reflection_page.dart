import 'package:flutter/material.dart';
import '../widgets/common/bottom_navigation.dart';
import '../widgets/reflection_list_item.dart';
import '../view_models/kindness_reflection_view_model.dart';

// Reflectionページの画面Widget
class ReflectionPage extends StatefulWidget {
  const ReflectionPage({super.key});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

// Reflectionページの状態管理クラス
class _ReflectionPageState extends State<ReflectionPage> {
  late ReflectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReflectionViewModel();
    _loadReflectionItems();
  }

  // Reflectionアイテムの読み込み処理
  Future<void> _loadReflectionItems() async {
    await _viewModel.loadReflectionItems();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Reflection',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

  // リスト部分のUI構築処理
  Widget _buildBody() {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        if (_viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_viewModel.error!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadReflectionItems,
                  child: const Text('再試行'),
                ),
              ],
            ),
          );
        }

        if (_viewModel.reflectionItems.isEmpty) {
          return Center(
            child: Text('リフレクションがありません', style: theme.textTheme.bodyMedium),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _viewModel.reflectionItems.length,
          itemBuilder: (context, index) {
            return ReflectionListItem(
              item: _viewModel.reflectionItems[index],
              onTap: () {
                _viewModel.onReflectionItemTap(
                  context,
                  _viewModel.reflectionItems[index],
                );
              },
            );
          },
        );
      },
    );
  }
}
