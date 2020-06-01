import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

class FieldValueGenerator extends Generator {
  final TypeChecker hasValue = const TypeChecker.fromRuntime(FieldValue);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final lib = Library(
        (b) => b..body.addAll(library.classes.map((e) => Code(_code(e)))));
    final emitter = DartEmitter();
    return lib.accept(emitter).toString();
  }

  String _code(ClassElement class$) {
    return """
    void toData() {
      ${class$.annotatedWith(hasValue).map((f) => """
          print(\'${class$.name} ${f.elementType.toString()} ${f.element.name} ${f.annotation.read("isWriteNotNull").boolValue}\');
          """).join()}
    }
    """;
  }
}

extension _FieldGeneratorExtension on ClassElement {
  Iterable<_AnnotatedElement> annotatedWith(TypeChecker checker) {
    return fields.map((f) {
      final annotation = checker.firstAnnotationOf(f, throwOnUnresolved: true);
      return (annotation != null)
          ? _AnnotatedElement(f.type, ConstantReader(annotation), f)
          : null;
    }).where((e) => e != null);
  }
}

class _AnnotatedElement {
  const _AnnotatedElement(this.elementType, this.annotation, this.element);
  final DartType elementType;
  final ConstantReader annotation;
  final Element element;
}
