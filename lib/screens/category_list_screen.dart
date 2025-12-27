import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../helpera/themes.dart';
import '../widgets/add_category_dialog.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(title: Text('categories'.tr)),
      body: GetBuilder<CategoryController>(
        builder: (controller) {
          if (controller.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category, size: 64, color: AppColors.iconSubtle),
                  const SizedBox(height: 16),
                  Text('no_categories'.tr,
                      style: TextStyle(color: AppColors.textSubtleDark)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final taskCount = taskController.tasks
                  .where((t) => t.categoryId == category.id)
                  .length;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(category.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text('$taskCount ${'tasks'.tr}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('edit'.tr),
                        onTap: () => Future.delayed(
                          const Duration(milliseconds: 100),
                          () =>
                              Get.dialog(AddCategoryDialog(category: category)),
                        ),
                      ),
                      PopupMenuItem(
                        child: Text('delete'.tr,
                            style: const TextStyle(color: AppColors.error)),
                        onTap: () => Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _deleteCategory(category.id),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(const AddCategoryDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteCategory(String id) {
    Get.dialog(
      AlertDialog(
        title: Text('delete'.tr),
        content: Text('delete_confirm'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              final taskController = Get.find<TaskController>();
              for (var task in taskController.tasks) {
                if (task.categoryId == id) {
                  task.categoryId = null;
                  task.save();
                }
              }
              Get.find<CategoryController>().deleteCategory(id);
              Get.back();
            },
            child: Text('delete'.tr,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
