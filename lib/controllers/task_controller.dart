import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

import '../helpera/constants.dart';

class TaskController extends GetxController {
  late Box<Task> taskBox;
  String? selectedCategoryId;

  @override
  void onInit() {
    super.onInit();
    taskBox = Hive.box<Task>(AppConstants.boxTasks);
  }

  List<Task> get tasks => taskBox.values.toList();

  List<Task> get filteredTasks {
    if (selectedCategoryId == null) {
      return tasks;
    }
    return tasks.where((t) => t.categoryId == selectedCategoryId).toList();
  }

  List<Task> get completedTasks =>
      filteredTasks.where((t) => t.isCompleted).toList();
  List<Task> get pendingTasks =>
      filteredTasks.where((t) => !t.isCompleted).toList();

  void addTask(Task task) {
    taskBox.put(task.id, task);
    update();
    Get.snackbar('Success', 'Task added', snackPosition: SnackPosition.BOTTOM);
  }

  void updateTask(Task task) {
    taskBox.put(task.id, task);
    update();
    Get.snackbar('Success', 'Task updated',
        snackPosition: SnackPosition.BOTTOM);
  }

  void deleteTask(String id) {
    taskBox.delete(id);
    update();
    Get.snackbar('Success', 'Task deleted',
        snackPosition: SnackPosition.BOTTOM);
  }

  void toggleComplete(String id) {
    final task = taskBox.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
      update();
    }
  }

  void setFilter(String? categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  Task? getTask(String id) => taskBox.get(id);
}
