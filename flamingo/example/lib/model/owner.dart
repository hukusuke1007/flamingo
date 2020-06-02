import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

import 'address.dart';
import 'medal.dart';

part 'owner.flamingo.dart';

class Owner extends Document<Owner> {
  Owner({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }) : super(id: id, snapshot: snapshot, values: values);

  @Field()
  String name;

  @ModelField()
  Address address;

  @ModelField()
  List<Medal> medals;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);
}
