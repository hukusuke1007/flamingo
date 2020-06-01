import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flamingo/flamingo.dart';
import 'address.dart';
import 'medal.dart';

class Owner extends Document<Owner> {
  Owner({
    String id,
    DocumentSnapshot snapshot,
    Map<String, dynamic> values,
  }): super(id: id, snapshot: snapshot, values: values);

  String name;
  Address address;
  List<Medal> medals;

  /// For save data
  @override
  Map<String, dynamic> toData() {
    final data = <String, dynamic>{};
    writeNotNull(data, 'name', name);
    writeModelNotNull(data, 'address', address);
    writeModelListNotNull(data, 'medals', medals);
    return data;
  }

  /// For load data
  @override
  void fromData(Map<String, dynamic> data) {
    name = valueFromKey<String>(data, 'name');
    address = Address(values: valueMapFromKey<String, String>(data, 'address'));
    medals = valueMapListFromKey<String, String>(data, 'medals')
        .where((d) => d != null)
        .map((d) => Medal(values: d))
        .toList();
  }

}