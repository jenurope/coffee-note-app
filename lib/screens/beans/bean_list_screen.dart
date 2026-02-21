import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/bean/bean_filters.dart';
import '../../cubits/bean/bean_list_cubit.dart';
import '../../cubits/bean/bean_list_state.dart';
import '../../domain/catalogs/roast_level_catalog.dart';
import '../../l10n/l10n.dart';
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
  final _scrollController = ScrollController();
  BeanFilters _filters = const BeanFilters();
  bool _isGridView = true;
  bool _isPagingLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    final cubit = context.read<BeanListCubit>();
    if (cubit.state is BeanListInitial) {
      cubit.load();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_isPagingLoading) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      final cubit = context.read<BeanListCubit>();
      if (!cubit.hasMore) return;
      _loadMore(cubit);
    }
  }

  Future<void> _loadMore(BeanListCubit cubit) async {
    setState(() {
      _isPagingLoading = true;
    });
    await cubit.loadMore();
    if (!mounted) return;
    setState(() {
      _isPagingLoading = false;
    });
  }

  void _search() {
    final newFilters = _filters.copyWith(searchQuery: _searchController.text);
    setState(() {
      _filters = newFilters;
      _isPagingLoading = false;
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
            _isPagingLoading = false;
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
                title: Text(context.l10n.beansScreenTitle),
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
                      onSearch: isGuest ? null : _search,
                      onFilterPressed: isGuest ? null : _showFilterSheet,
                      hintText: context.l10n.beansSearchHint,
                      enabled: !isGuest,
                      hasActiveFilters:
                          !isGuest &&
                          (_filters.minRating != null ||
                              _filters.roastLevel != null),
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
                title: context.l10n.beansEmptyTitle,
                subtitle: isAuthenticated && !isGuest
                    ? context.l10n.beansEmptySubtitleAuth
                    : context.l10n.beansEmptySubtitleGuest,
                buttonText: isAuthenticated && !isGuest
                    ? context.l10n.beansRecordButton
                    : null,
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
            Text(
              context.l10n.errorOccurredWithMessage(
                UserErrorMessage.localize(context.l10n, message),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: context.l10n.retry,
              onPressed: () => context.read<BeanListCubit>().reload(),
            ),
          ],
        ),
      ),
    };
  }

  Widget _buildBeanList(List<CoffeeBean> beans) {
    final listWidget = _isGridView
        ? RefreshIndicator(
            onRefresh: () async => context.read<BeanListCubit>().reload(),
            child: GridView.builder(
              controller: _scrollController,
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
          )
        : RefreshIndicator(
            onRefresh: () async => context.read<BeanListCubit>().reload(),
            child: ListView.builder(
              controller: _scrollController,
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

    return Stack(
      children: [
        Positioned.fill(child: listWidget),
        if (_isPagingLoading)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: IgnorePointer(
              child: _PaginationLoadingIndicator(
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
      ],
    );
  }
}

class _PaginationLoadingIndicator extends StatelessWidget {
  final Color backgroundColor;

  const _PaginationLoadingIndicator({required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(width: 10),
            Text('추가 항목 불러오는 중...'),
          ],
        ),
      ),
    );
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
    final l10n = context.l10n;
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
                l10n.filter,
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
                child: Text(l10n.reset),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(l10n.sort, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip(l10n.sortNewest, 'created_at'),
              _buildSortChip(l10n.sortByRating, 'rating'),
              _buildSortChip(l10n.sortByName, 'name'),
            ],
          ),

          const SizedBox(height: 16),

          Text(l10n.roastLevel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CoffeeBean.roastLevels.map((level) {
              return FilterChip(
                label: Text(RoastLevelCatalog.label(l10n, level)),
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

          Text(l10n.minRating, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [3.0, 4.0, 4.5].map((rating) {
              return FilterChip(
                label: Text(l10n.ratingAtLeast(rating)),
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
            text: l10n.apply,
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
