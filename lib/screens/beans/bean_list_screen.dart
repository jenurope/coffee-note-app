import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/bean/bean_filters.dart';
import '../../cubits/bean/bean_list_cubit.dart';
import '../../cubits/bean/bean_list_state.dart';
import '../../models/coffee_bean.dart';
import '../../widgets/bean_card.dart';
import '../../widgets/common/common_widgets.dart';

class BeanListScreen extends StatefulWidget {
  const BeanListScreen({super.key});

  @override
  State<BeanListScreen> createState() => _BeanListScreenState();
}

class _BeanListScreenState extends State<BeanListScreen> {
  final _searchController = TextEditingController();
  BeanFilters _filters = const BeanFilters();
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final newFilters = _filters.copyWith(searchQuery: _searchController.text);
    setState(() {
      _filters = newFilters;
    });
    context.read<BeanListCubit>().updateFilters(newFilters);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FilterSheet(
        currentFilters: _filters,
        onApply: (filters) {
          setState(() {
            _filters = filters;
          });
          context.read<BeanListCubit>().updateFilters(filters);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is AuthGuest;
        final isAuthenticated = authState is AuthAuthenticated;

        return BlocBuilder<BeanListCubit, BeanListState>(
          builder: (context, beanState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('원두 기록'),
                actions: [
                  IconButton(
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SearchFilterBar(
                      searchController: _searchController,
                      onSearch: _search,
                      onFilterPressed: _showFilterSheet,
                      hintText: '원두 이름, 로스터리 검색...',
                      hasActiveFilters:
                          _filters.minRating != null ||
                          _filters.roastLevel != null,
                    ),
                  ),
                  Expanded(
                    child: _buildBody(beanState, isAuthenticated, isGuest),
                  ),
                ],
              ),
              floatingActionButton: isAuthenticated && !isGuest
                  ? FloatingActionButton(
                      onPressed: () => context.push('/beans/new'),
                      child: const Icon(Icons.add),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    BeanListState beanState,
    bool isAuthenticated,
    bool isGuest,
  ) {
    return switch (beanState) {
      BeanListInitial() ||
      BeanListLoading() => const Center(child: CircularProgressIndicator()),
      BeanListLoaded(beans: final beans) =>
        beans.isEmpty
            ? EmptyState(
                icon: Icons.coffee_outlined,
                title: '등록된 원두가 없습니다',
                subtitle: isAuthenticated && !isGuest
                    ? '첫 원두를 기록해보세요!'
                    : '로그인하면 원두를 기록할 수 있습니다.',
                buttonText: isAuthenticated && !isGuest ? '원두 기록하기' : null,
                onButtonPressed: isAuthenticated && !isGuest
                    ? () => context.push('/beans/new')
                    : null,
              )
            : _buildBeanList(beans),
      BeanListError(message: final message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다\n$message'),
            const SizedBox(height: 16),
            CustomButton(
              text: '다시 시도',
              onPressed: () => context.read<BeanListCubit>().reload(),
            ),
          ],
        ),
      ),
    };
  }

  Widget _buildBeanList(List<CoffeeBean> beans) {
    if (_isGridView) {
      return RefreshIndicator(
        onRefresh: () async => context.read<BeanListCubit>().reload(),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: beans.length,
          itemBuilder: (context, index) {
            final bean = beans[index];
            return BeanCard(
              bean: bean,
              onTap: () => context.push('/beans/${bean.id}'),
            );
          },
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async => context.read<BeanListCubit>().reload(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: beans.length,
          itemBuilder: (context, index) {
            final bean = beans[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: BeanListTile(
                bean: bean,
                onTap: () => context.push('/beans/${bean.id}'),
              ),
            );
          },
        ),
      );
    }
  }
}

class _FilterSheet extends StatefulWidget {
  final BeanFilters currentFilters;
  final void Function(BeanFilters) onApply;

  const _FilterSheet({required this.currentFilters, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double? _minRating;
  late String? _roastLevel;
  late String? _sortBy;

  @override
  void initState() {
    super.initState();
    _minRating = widget.currentFilters.minRating;
    _roastLevel = widget.currentFilters.roastLevel;
    _sortBy = widget.currentFilters.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '필터',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _minRating = null;
                    _roastLevel = null;
                    _sortBy = null;
                  });
                },
                child: const Text('초기화'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('정렬', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip('최신순', 'created_at'),
              _buildSortChip('평점순', 'rating'),
              _buildSortChip('이름순', 'name'),
            ],
          ),

          const SizedBox(height: 16),

          Text('로스팅 레벨', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CoffeeBean.roastLevels.map((level) {
              return FilterChip(
                label: Text(level),
                selected: _roastLevel == level,
                onSelected: (selected) {
                  setState(() {
                    _roastLevel = selected ? level : null;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          Text('최소 평점', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [3.0, 4.0, 4.5].map((rating) {
              return FilterChip(
                label: Text('$rating점 이상'),
                selected: _minRating == rating,
                onSelected: (selected) {
                  setState(() {
                    _minRating = selected ? rating : null;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          CustomButton(
            text: '적용하기',
            onPressed: () {
              widget.onApply(
                widget.currentFilters.copyWith(
                  minRating: _minRating,
                  roastLevel: _roastLevel,
                  sortBy: _sortBy,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _sortBy == value,
      onSelected: (selected) {
        setState(() {
          _sortBy = selected ? value : null;
        });
      },
    );
  }
}
