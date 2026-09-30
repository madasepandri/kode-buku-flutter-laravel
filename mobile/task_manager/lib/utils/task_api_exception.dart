class TaskApiException implements Exception {
  const TaskApiException(this.message);

  final String message;
}
