import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'medal.flamingo.dart';

class Medal extends Model {
  Medal({
    this.name,
    Map<String, dynamic>? values,
  }) : super(values: values);

  @Field()
  String? name;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
