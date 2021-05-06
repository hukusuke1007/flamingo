import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'cart.dart';

part 'shop.flamingo.dart';

class Shop extends Document<Shop> {
  Shop({
    String? id,
    String? documentPath,
    String? collectionPath,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? values,
    CollectionReference<Map<String, dynamic>>? collectionRef,
  }) : super(
          id: id,
          documentPath: documentPath,
          collectionPath: collectionPath,
          snapshot: snapshot,
          values: values,
          collectionRef: collectionRef,
        );

  @Field()
  String? name;

  @ModelField()
  Cart? cart;

  @ModelField()
  List<Cart>? carts;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
