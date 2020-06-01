import 'package:cloud_firestore/cloud_firestore.dart';
import 'flamingo.dart';

class RunTransaction {
  static void scope(TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    Flamingo.instance.firestore.runTransaction(transactionHandler, timeout: timeout);
  }
}
