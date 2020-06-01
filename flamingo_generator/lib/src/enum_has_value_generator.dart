import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

class EnumHasValueGenerator extends Generator {
  final TypeChecker hasValue = const TypeChecker.fromRuntime(Value);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final lib = Library(
        (b) => b..body.addAll(library.enums.map((e) => Code(_codeForEnum(e)))));
    final emitter = DartEmitter();
    return lib.accept(emitter).toString();
  }

  String _codeForEnum(ClassElement enum$) {
    return """
    extension ${enum$.name}ValueExtension on ${enum$.name} {
      String get value {
        switch (this) {
          ${enum$.annotatedWith(hasValue).map((f) => """
          case ${enum$.name}.${f.element.name}:
            return \"${f.annotation.read("value").stringValue}\";
          """).join()}
        default:
          return this.toString();
        }
      }
    }
    """;
  }
}

extension _EnumElementExtension on ClassElement {
  Iterable<AnnotatedElement> annotatedWith(TypeChecker checker) {
    return fields.map((f) {
      final annotation = checker.firstAnnotationOf(f, throwOnUnresolved: true);
      return (annotation != null)
          ? AnnotatedElement(ConstantReader(annotation), f)
          : null;
    }).where((e) => e != null);
  }
}
