import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'cart.flamingo.dart';

class Cart extends Model {
  Cart({
    this.ref,
    this.collectionRef,
    Map<String, dynamic> values,
  }) : super(values: values);

  @Field()
  String ref;

  @Field()
  String collectionRef;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
