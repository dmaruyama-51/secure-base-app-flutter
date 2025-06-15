// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../view_models/kindness_reflection/kindness_reflection_list_view_model.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/kindness_reflection_list_item.dart';

class ReflectionListPage extends StatefulWidget {
  const ReflectionListPage({Key? key}) : super(key: key);

  @override
  ReflectionListPageState createState() => ReflectionListPageState();
}

class ReflectionListPageState extends State<ReflectionListPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ReflectionListViewModel>().loadMoreReflections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ReflectionListViewModel();
        // 初期データ読み込み
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.loadReflections();
        });
        return viewModel;
      },
      child: Consumer<ReflectionListViewModel>(
        builder: (context, viewModel, child) {
          // エラーメッセージの表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.errorMessage != null) {
              context.showErrorSnackBar(message: viewModel.errorMessage!);
              viewModel.clearError();
            }
          });

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: _buildBody(viewModel),
            bottomNavigationBar: const BottomNavigation(currentIndex: 2),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'リフレクション',
        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildBody(ReflectionListViewModel viewModel) {
    if (viewModel.isLoading && viewModel.reflections.isEmpty) {
      return _buildLoadingState();
    }

    if (viewModel.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshReflections,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.reflections.length + (viewModel.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= viewModel.reflections.length) {
            return _buildLoadingItem();
          }

          final reflection = viewModel.reflections[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ReflectionListItem(
              reflection: reflection,
              onTap: () {
                // TODO: リフレクション詳細ページに遷移
                print('Reflection tapped: ${reflection.id}');
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryLight.withOpacity(0.3),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 48,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'まだリフレクションがありません',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'リフレクションは設定した頻度で自動でお届けします。\nもうしばらくお待ち下さい。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
