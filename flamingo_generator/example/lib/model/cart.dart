import 'package:flamingo/flamingo.dart';
import 'package:flamingo_generator/flamingo_generator.dart';

part 'cart.value.g.dart';

class Cart extends Model {
  Cart({
    Map<String, dynamic> values,
  }) : super(values: values);

  @Field()
  String itemA;

  @Field()
  int itemB;

  @Field()
  double itemC;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
