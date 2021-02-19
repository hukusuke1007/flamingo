import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'address.flamingo.dart';

class Address extends Model {
  Address({
    this.postCode,
    this.country,
    Map<String, dynamic>? values,
  }) : super(values: values);

  @Field()
  String? postCode;

  @Field()
  String? country;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
