import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'app_user.flamingo.dart';

class AppUser extends Document<AppUser> {
  @Field()
  String? name;
  @Field()
  String? username;
  @Field()
  String? firstName;
  @Field()
  String? lastName;
  @Field()
  String? email;
  @Field()
  String? phoneNumber;
  @Field()
  String? photoUrl;

  @Field()
  Increment<int> newMessagesCount = Increment<int>();
  // @SubCollection()
  // Collection<Token> tokens;
  AppUser(
      {String? id, DocumentSnapshot? snapshot, Map<String, dynamic>? values})
      : super(
            id: id,
            snapshot: snapshot,
            values: values,
            collectionRef:
                Flamingo.instance.rootReference.collection('app_users')) {
    // tokens = Collection(this, AppUserKey.tokens.value);
  }

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  /// Call after create, update, delete.
  @override
  void onCompleted(ExecuteType executeType) {
    newMessagesCount = newMessagesCount.onRefresh();
  }
}
