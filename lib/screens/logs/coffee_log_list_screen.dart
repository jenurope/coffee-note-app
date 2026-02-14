import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/log/log_filters.dart';
import '../../cubits/log/log_list_cubit.dart';
import '../../cubits/log/log_list_state.dart';
import '../../models/coffee_log.dart';
import '../../widgets/coffee_log_card.dart';
import '../../widgets/common/common_widgets.dart';

class CoffeeLogListScreen extends StatefulWidget {
  const CoffeeLogListScreen({super.key});

  @override
  State<CoffeeLogListScreen> createState() => _CoffeeLogListScreenState();
}

class _CoffeeLogListScreenState extends State<CoffeeLogListScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LogListCubit>();
    if (cubit.state is LogListInitial) {
      cubit.load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final cubit = context.read<LogListCubit>();
    final currentFilters = switch (cubit.state) {
      LogListLoaded(filters: final f) => f,
      LogListLoading(filters: final f) => f,
      LogListError(filters: final f) => f,
      _ => const LogFilters(),
    };
    cubit.updateFilters(
      currentFilters.copyWith(searchQuery: _searchController.text),
    );
  }

  void _showFilterSheet() {
    final cubit = context.read<LogListCubit>();
    final currentFilters = switch (cubit.state) {
      LogListLoaded(filters: final f) => f,
      LogListLoading(filters: final f) => f,
      LogListError(filters: final f) => f,
      _ => const LogFilters(),
    };
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(
        currentFilters: currentFilters,
        onApply: (filters) {
          cubit.updateFilters(filters);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;
        final isGuest = authState is AuthGuest;

        return BlocBuilder<LogListCubit, LogListState>(
          builder: (context, logState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('커피 기록'),
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
                    child: Builder(
                      builder: (context) {
                        final filters = switch (logState) {
                          LogListLoaded(filters: final f) => f,
                          LogListLoading(filters: final f) => f,
                          LogListError(filters: final f) => f,
                          _ => const LogFilters(),
                        };
                        return SearchFilterBar(
                          searchController: _searchController,
                          onSearch: isGuest ? null : _search,
                          onFilterPressed: isGuest ? null : _showFilterSheet,
                          hintText: '커피, 카페 검색...',
                          enabled: !isGuest,
                          hasActiveFilters:
                              !isGuest &&
                              (filters.minRating != null ||
                                  filters.coffeeType != null),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: switch (logState) {
                      LogListInitial() || LogListLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      LogListLoaded(logs: final logs) =>
                        logs.isEmpty
                            ? EmptyState(
                                icon: Icons.local_cafe_outlined,
                                title: '등록된 커피 기록이 없습니다',
                                subtitle: currentUser != null && !isGuest
                                    ? '오늘 마신 커피를 기록해보세요!'
                                    : '로그인하면 커피를 기록할 수 있습니다.',
                                buttonText: currentUser != null && !isGuest
                                    ? '커피 기록하기'
                                    : null,
                                onButtonPressed: currentUser != null && !isGuest
                                    ? () => context.push('/logs/new')
                                    : null,
                              )
                            : _isGridView
                            ? RefreshIndicator(
                                onRefresh: () =>
                                    context.read<LogListCubit>().reload(),
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.7,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                  itemCount: logs.length,
                                  itemBuilder: (context, index) {
                                    final log = logs[index];
                                    return CoffeeLogCard(
                                      log: log,
                                      onTap: () =>
                                          context.push('/logs/${log.id}'),
                                    );
                                  },
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    context.read<LogListCubit>().reload(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: logs.length,
                                  itemBuilder: (context, index) {
                                    final log = logs[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: CoffeeLogListTile(
                                        log: log,
                                        onTap: () =>
                                            context.push('/logs/${log.id}'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      LogListError(message: final message) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 16),
                            Text('오류가 발생했습니다\n$message'),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: '다시 시도',
                              onPressed: () =>
                                  context.read<LogListCubit>().reload(),
                            ),
                          ],
                        ),
                      ),
                    },
                  ),
                ],
              ),
              floatingActionButton: currentUser != null && !isGuest
                  ? FloatingActionButton(
                      onPressed: () => context.push('/logs/new'),
                      child: const Icon(Icons.add),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final LogFilters currentFilters;
  final void Function(LogFilters) onApply;

  const _FilterSheet({required this.currentFilters, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double? _minRating;
  late String? _coffeeType;
  late String? _sortBy;

  @override
  void initState() {
    super.initState();
    _minRating = widget.currentFilters.minRating;
    _coffeeType = widget.currentFilters.coffeeType;
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
                    _coffeeType = null;
                    _sortBy = null;
                  });
                },
                child: const Text('초기화'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 정렬
          Text('정렬', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip('최신순', 'cafe_visit_date'),
              _buildSortChip('평점순', 'rating'),
            ],
          ),

          const SizedBox(height: 16),

          // 커피 종류
          Text('커피 종류', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CoffeeLog.coffeeTypes.map((type) {
              return FilterChip(
                label: Text(type),
                selected: _coffeeType == type,
                onSelected: (selected) {
                  setState(() {
                    _coffeeType = selected ? type : null;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 최소 평점
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
                  coffeeType: _coffeeType,
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
