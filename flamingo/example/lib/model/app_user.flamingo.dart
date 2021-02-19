// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// FieldValueGenerator
// **************************************************************************

/// Field value key
enum AppUserKey {
  name,
  username,
  firstName,
  lastName,
  email,
  phoneNumber,
  photoUrl,
  newMessagesCount,
}

extension AppUserKeyExtension on AppUserKey {
  String get value {
    switch (this) {
      case AppUserKey.name:
        return 'name';
      case AppUserKey.username:
        return 'username';
      case AppUserKey.firstName:
        return 'firstName';
      case AppUserKey.lastName:
        return 'lastName';
      case AppUserKey.email:
        return 'email';
      case AppUserKey.phoneNumber:
        return 'phoneNumber';
      case AppUserKey.photoUrl:
        return 'photoUrl';
      case AppUserKey.newMessagesCount:
        return 'newMessagesCount';
      default:
        throw Exception('Invalid data key. key: FieldValueGenerator');
    }
  }
}

/// For save data
Map<String, dynamic> _$toData(AppUser doc) {
  final data = <String, dynamic>{};
  Helper.writeNotNull(data, 'name', doc.name);
  Helper.writeNotNull(data, 'username', doc.username);
  Helper.writeNotNull(data, 'firstName', doc.firstName);
  Helper.writeNotNull(data, 'lastName', doc.lastName);
  Helper.writeNotNull(data, 'email', doc.email);
  Helper.writeNotNull(data, 'phoneNumber', doc.phoneNumber);
  Helper.writeNotNull(data, 'photoUrl', doc.photoUrl);
  Helper.writeIncrement(data, doc.newMessagesCount, 'newMessagesCount');

  return data;
}

/// For load data
void _$fromData(AppUser doc, Map<String, dynamic> data) {
  doc.name = Helper.valueFromKey<String>(data, 'name');
  doc.username = Helper.valueFromKey<String>(data, 'username');
  doc.firstName = Helper.valueFromKey<String>(data, 'firstName');
  doc.lastName = Helper.valueFromKey<String>(data, 'lastName');
  doc.email = Helper.valueFromKey<String>(data, 'email');
  doc.phoneNumber = Helper.valueFromKey<String>(data, 'phoneNumber');
  doc.photoUrl = Helper.valueFromKey<String>(data, 'photoUrl');
  doc.newMessagesCount =
      Helper.valueFromIncrement<int>(data, 'newMessagesCount');
}
