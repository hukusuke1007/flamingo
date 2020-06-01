import 'package:flamingo_generator/flamingo_generator.dart';

part 'user.value.g.dart';

class User {
  @FieldValue()
  String name;

  @FieldValue(isWriteNotNull: false)
  String profile;

  @FieldValue()
  int value;
}
