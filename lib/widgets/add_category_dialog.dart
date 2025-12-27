import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../models/category.dart';
import '../helpera/themes.dart';

class AddCategoryDialog extends StatefulWidget {
  final Category? category;
  final Function(String)? onCategoryAdded;

  const AddCategoryDialog({super.key, this.category, this.onCategoryAdded});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? 'edit_category'.tr : 'add_category'.tr),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'name'.tr,
            border: const OutlineInputBorder(),
          ),
          validator: (v) => v?.trim().isEmpty ?? true ? 'required'.tr : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('cancel'.tr),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final controller = Get.find<CategoryController>();

              if (isEditing) {
                // Update
                final updatedCategory = widget.category!;
                updatedCategory.name = _nameController.text.trim();
                updatedCategory.save();
                controller.update(); // Refresh UI
              } else {
                // Add
                final newCategory = Category(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text.trim(),
                  colorValue: categoryColors[
                          DateTime.now().second % categoryColors.length]
                      .value,
                );
                controller.addCategory(newCategory);
                widget.onCategoryAdded?.call(newCategory.id);
              }
              Get.back();
            }
          },
          child: Text('save'.tr),
        ),
      ],
    );
  }
}
