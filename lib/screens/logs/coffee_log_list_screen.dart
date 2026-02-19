import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/user_error_message.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/log/log_filters.dart';
import '../../cubits/log/log_list_cubit.dart';
import '../../cubits/log/log_list_state.dart';
import '../../domain/catalogs/coffee_type_catalog.dart';
import '../../l10n/l10n.dart';
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
                title: Text(context.l10n.logsScreenTitle),
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
                          hintText: context.l10n.logsSearchHint,
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
                                title: context.l10n.logsEmptyTitle,
                                subtitle: currentUser != null && !isGuest
                                    ? context.l10n.logsEmptySubtitleAuth
                                    : context.l10n.logsEmptySubtitleGuest,
                                buttonText: currentUser != null && !isGuest
                                    ? context.l10n.logsRecordButton
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
                            Text(
                              context.l10n.errorOccurredWithMessage(
                                UserErrorMessage.localize(
                                  context.l10n,
                                  message,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: context.l10n.retry,
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
                    _coffeeType = null;
                    _sortBy = null;
                  });
                },
                child: Text(l10n.reset),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 정렬
          Text(l10n.sort, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip(l10n.sortNewest, 'cafe_visit_date'),
              _buildSortChip(l10n.sortByRating, 'rating'),
            ],
          ),

          const SizedBox(height: 16),

          // 커피 종류
          Text(l10n.coffeeType, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CoffeeLog.coffeeTypes.map((type) {
              return FilterChip(
                label: Text(CoffeeTypeCatalog.label(l10n, type)),
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
