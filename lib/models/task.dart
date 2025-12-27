import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String? categoryId;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.categoryId,
    this.isCompleted = false,
    required this.createdAt,
  });
}
