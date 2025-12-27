import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../controllers/category_controller.dart';
import '../models/task.dart';
import '../helpera/themes.dart';
import 'add_category_dialog.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? task;
  const AddTaskDialog({super.key, this.task});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _selectedCategoryId = widget.task!.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final taskController = Get.find<TaskController>();
    final isEdit = widget.task != null;

    return AlertDialog(
      title: Text(isEdit ? 'edit_task'.tr : 'add_task'.tr),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: !isEdit,
              decoration: InputDecoration(
                labelText: 'title'.tr,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'description'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            GetBuilder<CategoryController>(
              builder: (_) {
                final items = [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No Category'),
                  ),
                  ...categoryController.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(cat.colorValue),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(cat.name),
                              ],
                            ),
                          )),
                  const DropdownMenuItem<String>(
                    value: 'add_new_category_option',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline,
                            color: AppColors.info, size: 20),
                        SizedBox(width: 8),
                        Text('Add New Category',
                            style: TextStyle(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ];

                return DropdownButtonFormField<String?>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'category'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: items,
                  onChanged: (value) async {
                    if (value == 'add_new_category_option') {
                      setState(() => _selectedCategoryId = null);
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (context.mounted) {
                        Get.dialog(
                          AddCategoryDialog(
                            onCategoryAdded: (newId) {
                              setState(() {
                                _selectedCategoryId = newId;
                              });
                            },
                          ),
                        );
                      }
                    } else {
                      setState(() => _selectedCategoryId = value);
                    }
                  },
                );
              },
            ),
          ],
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
              final newTask = Task(
                id: widget.task?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                categoryId: _selectedCategoryId,
                isCompleted: widget.task?.isCompleted ?? false,
                createdAt: widget.task?.createdAt ?? DateTime.now(),
              );

              if (isEdit) {
                taskController.updateTask(newTask);
              } else {
                taskController.addTask(newTask);
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
