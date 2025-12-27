import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../controllers/category_controller.dart';
import '../helpera/routes.dart';
import '../helpera/themes.dart';
import '../widgets/add_task_dialog.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final categoryController = Get.find<CategoryController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('tasks'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Get.toNamed(AppRoutes.CATEGORIES),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GetBuilder<TaskController>(
              builder: (controller) => GetBuilder<CategoryController>(
                builder: (_) => DropdownButtonFormField<String?>(
                  value: controller.selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'category'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('all'.tr)),
                    ...Get.find<CategoryController>()
                        .categories
                        .map((cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
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
                  ],
                  onChanged: (value) => controller.setFilter(value),
                ),
              ),
            ),
          ),
          GetBuilder<TaskController>(
            builder: (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('all'.tr, taskController.filteredTasks.length,
                      AppColors.info),
                  _buildStat('completed'.tr,
                      taskController.completedTasks.length, AppColors.success),
                  _buildStat('pending'.tr, taskController.pendingTasks.length,
                      AppColors.warning),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GetBuilder<TaskController>(
              builder: (_) {
                final tasks = taskController.filteredTasks;
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt,
                            size: 64, color: AppColors.iconSubtle),
                        const SizedBox(height: 16),
                        Text('no_tasks'.tr,
                            style: TextStyle(color: AppColors.textSubtleDark)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final category =
                        categoryController.getCategory(task.categoryId ?? '');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) =>
                              taskController.toggleComplete(task.id),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description.isNotEmpty)
                              Text(task.description, maxLines: 2),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (category != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(category.colorValue)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      category.name,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(category.colorValue)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  DateFormat.yMMMd().format(task.createdAt),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('edit'.tr),
                              onTap: () => Future.delayed(
                                const Duration(milliseconds: 100),
                                () => Get.dialog(AddTaskDialog(task: task)),
                              ),
                            ),
                            PopupMenuItem(
                              child: Text('delete'.tr,
                                  style:
                                      const TextStyle(color: AppColors.error)),
                              onTap: () => _deleteTask(task.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(const AddTaskDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(count.toString(),
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _deleteTask(String id) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          title: Text('delete'.tr),
          content: Text('delete_confirm'.tr),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
            TextButton(
              onPressed: () {
                Get.find<TaskController>().deleteTask(id);
                Get.back();
              },
              child: Text('delete'.tr,
                  style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    });
  }
}
