import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../domain/catalogs/brew_method_catalog.dart';
import '../../l10n/l10n.dart';
import '../../models/bean_recipe.dart';
import '../../services/bean_recipe_service.dart';
import '../../widgets/common/common_widgets.dart';

class BeanRecipeFormScreen extends StatefulWidget {
  const BeanRecipeFormScreen({super.key, this.recipe, this.service});

  final BeanRecipe? recipe;
  final BeanRecipeService? service;

  @override
  State<BeanRecipeFormScreen> createState() => _BeanRecipeFormScreenState();
}

class _BeanRecipeFormScreenState extends State<BeanRecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _recipeController;
  late String _selectedBrewMethod;
  bool _isSubmitting = false;

  bool get isEditing => widget.recipe != null;

  BeanRecipeService get _service =>
      widget.service ?? getIt<BeanRecipeService>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe?.name ?? '');
    _recipeController = TextEditingController(
      text: widget.recipe?.recipe ?? '',
    );
    _selectedBrewMethod =
        widget.recipe?.brewMethod ?? BrewMethodCatalog.pourOver;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recipeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requiredLogin)));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (isEditing) {
        await _service.updateRecipe(
          widget.recipe!.copyWith(
            name: _nameController.text.trim(),
            brewMethod: _selectedBrewMethod,
            recipe: _recipeController.text.trim(),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await _service.createRecipe(
          BeanRecipe(
            id: '',
            userId: authState.user.id,
            name: _nameController.text.trim(),
            brewMethod: _selectedBrewMethod,
            recipe: _recipeController.text.trim(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? context.l10n.beanRecipeUpdated
                : context.l10n.beanRecipeCreated,
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.beanRecipeSaveFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.l10n.beanRecipeEditTitle
              : context.l10n.beanRecipeCreateTitle,
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: Text(context.l10n.save),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('bean_recipe_name_field'),
                    controller: _nameController,
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: const Key('bean_recipe_brew_dropdown'),
                    initialValue: _selectedBrewMethod,
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
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedBrewMethod = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('bean_recipe_text_field'),
                    controller: _recipeController,
                    minLines: 4,
                    maxLines: 8,
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
        ),
      ),
    );
  }
}
