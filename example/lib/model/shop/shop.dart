import 'package:flamingo/flamingo.dart';
import 'cart.dart';

class Shop extends Document<Shop> {
  Shop({
    String id,
    String documentPath,
    String collectionPath,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
    CollectionReference collectionRef,
  }): super(
      id: id,
      documentPath: documentPath,
      collectionPath: collectionPath,
      snapshot: snapshot,
      values: values,
      collectionRef: collectionRef,
  );

  String name;
  Cart cart;
  List<Cart> carts;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', name);
    writeModelNotNull(data, 'cart', cart);
    writeModelListNotNull(data, 'carts', carts);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    name = valueFromKey<String>(data, 'name');
    cart = Cart(values: valueMapFromKey<String, dynamic>(data, 'cart'));
    final _carts = valueMapListFromKey<String, dynamic>(data, 'carts');
    if (_carts != null) {
      carts = _carts
          .where((d) => d != null)
          .map((d) => Cart(values: d))
          .toList();
    }

  }

}