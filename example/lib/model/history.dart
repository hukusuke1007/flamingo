//import 'package:json_annotation/json_annotation.dart';
//import 'package:flutter_app_validation/flamingo/document.dart';
//
//part 'history.g.dart';
//
//@JsonSerializable(includeIfNull: false)
//class History extends Document<History> {
//  History({String id}) : super(id: id);
//
//  String uid;
//  String name;
//
//  factory History.fromJson(Map<String, dynamic> json) => _$HistoryFromJson(json);
//  Map<String, dynamic> toJson() => _$HistoryToJson(this);
//
//  void log() {
//    print("$id $uid $name $createdAt $updatedAt");
//  }
//}