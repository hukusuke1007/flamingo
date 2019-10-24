import 'package:json_annotation/json_annotation.dart';
import 'package:flamingo/document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'setting.g.dart';

@JsonSerializable(includeIfNull: false)
class Setting extends Document<Setting> {
  Setting({
    String id,
    DocumentSnapshot documentSnapshot,
    Map<String, dynamic> values,
    CollectionReference parent,
  }): super(id: id, snapshot: documentSnapshot, values: values, parent: parent);

  bool isEnable;

  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);
  Map<String, dynamic> toJson() => _$SettingToJson(this);

  @override
  Map<String, dynamic> toData() {
    return toJson();
  }

  @override
  void fromData(Map<String, dynamic> data) {
    final dummy = Setting.fromJson(data); // TODO まじこれよくない
    this.isEnable = dummy.isEnable;
  }

  void log() {
    print("$id $isEnable $createdAt $updatedAt");
  }
}