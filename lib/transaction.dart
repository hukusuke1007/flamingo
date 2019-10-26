import 'package:cloud_firestore/cloud_firestore.dart' show TransactionHandler;
import 'flamingo.dart';

class Transaction {
  static run(TransactionHandler transactionHandler, {Duration timeout = const Duration(seconds: 5)}) {
    Flamingo.instance.firestore.runTransaction(transactionHandler);
  }
}