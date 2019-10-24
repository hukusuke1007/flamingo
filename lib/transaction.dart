import 'package:cloud_firestore/cloud_firestore.dart';
import 'flamingo.dart';

class Transaction {
  static run(TransactionHandler transactionHandler, {Duration timeout = const Duration(seconds: 5)}) {
    Firestore db = firestore();
    db.runTransaction(transactionHandler);
  }
}