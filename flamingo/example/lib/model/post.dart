import 'package:flamingo/flamingo.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart';

part 'post.flamingo.dart';

class Post extends Document<Post> {
  Post({String id}) : super(id: id);

  @StorageField()
  StorageFile file;

  @StorageField()
  List<StorageFile> files;

  @override
  Map<String, dynamic> toData() => _$toData(this);

  @override
  void fromData(Map<String, dynamic> data) => _$fromData(this, data);

  void log() {
    print('$id ${file?.toJson()} $files');
  }
}
