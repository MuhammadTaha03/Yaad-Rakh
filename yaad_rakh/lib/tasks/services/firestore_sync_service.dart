// lib/tasks/services/firestore_sync_service.dart

import 'dart:developer';
import '../models/task.dart';

class FirestoreSyncService {
  Future<void> pushTask(Task task) async {
    log("FirestoreSyncService: Silent background push triggered for task '${task.title}'.");
  }

  Future<void> deleteTask(String taskId) async {
    log("FirestoreSyncService: Silent background delete sync triggered for task ID $taskId.");
  }

  Future<List<Task>> fetchAll(String uid) async {
    log("FirestoreSyncService: Silent pull triggered for user $uid.");
    return [];
  }
}
