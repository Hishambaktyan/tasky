class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;

  TaskModel({
    this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'priority': priority,
    'due_date': dueDate.millisecondsSinceEpoch,
    'is_completed': isCompleted ? 1 : 0,
    'completed_at': completedAt?.millisecondsSinceEpoch,
  };

  factory TaskModel.fromMap(Map<String, dynamic> m) => TaskModel(
    id: m['id'] as int,
    title: m['title'] as String,
    description: (m['description'] as String?) ?? '',
    category: m['category'] as String,
    priority: m['priority'] as String,
    dueDate: DateTime.fromMillisecondsSinceEpoch(m['due_date'] as int),
    isCompleted: m['is_completed'] == 1,
    completedAt: m['completed_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(m['completed_at'] as int),
  );
}