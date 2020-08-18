import 'flamingo.dart';

class RunTransaction {
  static Future<T> scope<T>(TransactionHandler<T> transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    return Flamingo.instance.firestore
        .runTransaction<T>(transactionHandler, timeout: timeout);
  }
}
