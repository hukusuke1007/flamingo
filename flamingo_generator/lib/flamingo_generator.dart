import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/field_value_generator.dart';

Builder fieldValueBuilder(BuilderOptions options) =>
    PartBuilder([FieldValueGenerator()], '.flamingo.dart');
