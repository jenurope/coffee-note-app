import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../domain/catalogs/brew_method_catalog.dart';
import '../../l10n/l10n.dart';
import '../../models/bean_recipe.dart';
import '../../services/bean_recipe_service.dart';
import '../../widgets/common/common_widgets.dart';

class BeanRecipeManageScreen extends StatefulWidget {
  const BeanRecipeManageScreen({super.key, this.service});

  final BeanRecipeService? service;

  @override
  State<BeanRecipeManageScreen> createState() => _BeanRecipeManageScreenState();
}

class _BeanRecipeManageScreenState extends State<BeanRecipeManageScreen> {
  bool _didLoad = false;
  bool _isLoading = false;
  String? _errorMessageKey;
  List<BeanRecipe> _recipes = const <BeanRecipe>[];

  BeanRecipeService get _service =>
      widget.service ?? getIt<BeanRecipeService>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _load();
  }

  Future<void> _load() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _recipes = const <BeanRecipe>[];
        _isLoading = false;
        _errorMessageKey = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessageKey = null;
    });

    try {
      final items = await _service.getRecipes(authState.user.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _recipes = items;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessageKey = 'beanRecipeLoadFailed';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createRecipe() async {
    await _upsertRecipe();
  }

  Future<void> _editRecipe(BeanRecipe recipe) async {
    await _upsertRecipe(existing: recipe);
  }

  Future<void> _upsertRecipe({BeanRecipe? existing}) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requiredLogin)));
      return;
    }

    final draft = await _showRecipeDialog(existing: existing);
    if (draft == null || !mounted) {
      return;
    }

    try {
      if (existing == null) {
        await _service.createRecipe(
          BeanRecipe(
            id: '',
            userId: authState.user.id,
            name: draft.name,
            brewMethod: draft.brewMethod,
            recipe: draft.recipe,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await _service.updateRecipe(
          existing.copyWith(
            name: draft.name,
            brewMethod: draft.brewMethod,
            recipe: draft.recipe,
            updatedAt: DateTime.now(),
          ),
        );
      }

      if (!mounted) {
        return;
      }
      await _load();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? context.l10n.beanRecipeCreated
                : context.l10n.beanRecipeUpdated,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.beanRecipeSaveFailed)),
      );
    }
  }

  Future<void> _deleteRecipe(BeanRecipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.beanRecipeDeleteTitle),
        content: Text(context.l10n.beanRecipeDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _service.deleteRecipe(recipe.id);
      if (!mounted) {
        return;
      }
      await _load();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.beanRecipeDeleted)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.beanRecipeDeleteFailed)),
      );
    }
  }

  Future<_BeanRecipeDraft?> _showRecipeDialog({BeanRecipe? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final recipeController = TextEditingController(
      text: existing?.recipe ?? '',
    );
    var selectedBrewMethod = existing?.brewMethod ?? BrewMethodCatalog.pourOver;

    final result = await showDialog<_BeanRecipeDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(
              existing == null
                  ? context.l10n.beanRecipeCreateTitle
                  : context.l10n.beanRecipeEditTitle,
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('bean_recipe_name_field'),
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.beanRecipeNameLabel,
                        hintText: context.l10n.beanRecipeNameHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.beanRecipeNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: const Key('bean_recipe_brew_dropdown'),
                      initialValue: selectedBrewMethod,
                      decoration: InputDecoration(
                        labelText: context.l10n.brewMethodLabel,
                      ),
                      items: BrewMethodCatalog.codes
                          .map(
                            (code) => DropdownMenuItem<String>(
                              value: code,
                              child: Text(
                                BrewMethodCatalog.label(context.l10n, code),
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          selectedBrewMethod = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('bean_recipe_text_field'),
                      controller: recipeController,
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: context.l10n.recipeLabel,
                        hintText: context.l10n.recipeHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.recipeRequired;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    _BeanRecipeDraft(
                      name: nameController.text.trim(),
                      brewMethod: selectedBrewMethod,
                      recipe: recipeController.text.trim(),
                    ),
                  );
                },
                child: Text(context.l10n.save),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    recipeController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.beanRecipeManageTitle)),
            body: EmptyState(
              icon: Icons.lock_outline,
              title: context.l10n.requiredLogin,
              subtitle: context.l10n.beanRecipeLoginRequired,
              buttonText: context.l10n.loginNow,
              onButtonPressed: () {
                context.read<AuthCubit>().exitGuestMode();
                context.go('/auth/login');
              },
            ),
          );
        }

        if (_isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.beanRecipeManageTitle)),
            body: const Center(child: CircularProgressIndicator()),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _createRecipe,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.beanRecipeAddAction),
            ),
          );
        }

        if (_errorMessageKey != null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.beanRecipeManageTitle)),
            body: EmptyState(
              icon: Icons.error_outline,
              title: context.l10n.beanRecipeLoadFailed,
              buttonText: context.l10n.retry,
              onButtonPressed: _load,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _createRecipe,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.beanRecipeAddAction),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.beanRecipeManageTitle)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _createRecipe,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.beanRecipeAddAction),
          ),
          body: _recipes.isEmpty
              ? EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: context.l10n.beanRecipeEmptyTitle,
                  subtitle: context.l10n.beanRecipeEmptySubtitle,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recipes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          recipe.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                BrewMethodCatalog.label(
                                  context.l10n,
                                  recipe.brewMethod,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recipe.recipe,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        onTap: () => _editRecipe(recipe),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: context.l10n.edit,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editRecipe(recipe),
                            ),
                            IconButton(
                              tooltip: context.l10n.delete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteRecipe(recipe),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _BeanRecipeDraft {
  const _BeanRecipeDraft({
    required this.name,
    required this.brewMethod,
    required this.recipe,
  });

  final String name;
  final String brewMethod;
  final String recipe;
}
