import '../flamingo.dart';

// ignore: avoid_classes_with_only_static_members
class RunTransaction {
  static Future<T> scope<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    return Flamingo.instance.firestore
        .runTransaction<T>(transactionHandler, timeout: timeout);
  }
}
