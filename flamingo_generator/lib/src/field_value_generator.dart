import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:flamingo_annotation/flamingo_annotation.dart' as annotation;
import 'package:source_gen/source_gen.dart';

class FieldValueGenerator extends Generator {
  final TypeChecker hasFieldValue =
      const TypeChecker.fromRuntime(annotation.Field);
  final TypeChecker hasModelFieldValue =
      const TypeChecker.fromRuntime(annotation.ModelField);
  final TypeChecker hasStorageFieldValue =
      const TypeChecker.fromRuntime(annotation.StorageField);
  final TypeChecker hasSubCollectionValue =
      const TypeChecker.fromRuntime(annotation.SubCollection);
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final values = StringBuffer();
    // ignore: avoid_function_literals_in_foreach_calls
    library.classes.forEach((element) {
      values.writeln(_code(element));
    });
    return values.toString();
  }

  String _code(ClassElement class$) {
    final enumName = '${class$.name}Key';
    return """
     /// Field value key
     enum $enumName {
       ${class$.annotatedWith(hasFieldValue).map((f) => """${f.element.name}, """).join()}
       ${class$.annotatedWith(hasModelFieldValue).map((f) => """${f.element.name}, """).join()}
       ${class$.annotatedWith(hasStorageFieldValue).map((f) => """${f.element.name}, """).join()}
       ${class$.annotatedWith(hasSubCollectionValue).map((f) => """${f.element.name}, """).join()}
     }
     
     extension ${enumName}Extension on $enumName {
       String get value {
          switch (this) {
          ${class$.annotatedWith(hasFieldValue).map((f) => """
            case $enumName.${f.element.name}:
              return \'${f.element.name}\';
          """).join()}${class$.annotatedWith(hasModelFieldValue).map((f) => """
            case $enumName.${f.element.name}:
              return \'${f.element.name}\';
          """).join()}${class$.annotatedWith(hasStorageFieldValue).map((f) => """
            case $enumName.${f.element.name}:
              return \'${f.element.name}\';
          """).join()}${class$.annotatedWith(hasSubCollectionValue).map((f) => """
            case $enumName.${f.element.name}:
              return \'${f.element.name}\';
          """).join()}default:
              return null;
          }
       }
     }
     
     /// For save data
     Map<String, dynamic> _\$toData(${class$.name} doc) {
      final data = <String, dynamic>{};
      ${class$.annotatedWith(hasFieldValue).map((f) => """${_fieldForSave(f)}
          """).join()}
      ${class$.annotatedWith(hasModelFieldValue).map((f) => """${_modelFieldForSave(f)}
          """).join()}
      ${class$.annotatedWith(hasStorageFieldValue).map((f) => """${_storageFieldForSave(f)}
          """).join()}
      return data;
    }
    
    /// For load data
    void _\$fromData(${class$.name} doc, Map<String, dynamic> data) {
      ${class$.annotatedWith(hasFieldValue).map((f) => """${_fieldForLoad(f)}
      """).join()}
      ${class$.annotatedWith(hasModelFieldValue).map((f) => """${_modelFieldForLoad(f)}
      """).join()}
      ${class$.annotatedWith(hasStorageFieldValue).map((f) => """${_storageFieldForLoad(f)}
      """).join()}
    }
    """;
  }

  /// For save
  String _fieldForSave(_AnnotatedElement f) {
    if (f.elementType.type.contains('Increment<')) {
      return '''Helper.writeIncrement(data, doc.${f.element.name}, \'${f.element.name}\');''';
    } else {
      if (f.annotation.read('isWriteNotNull').boolValue) {
        return """Helper.writeNotNull(data, \'${f.element.name}\', doc.${f.element.name});""";
      } else {
        return """Helper.write(data, \'${f.element.name}\', doc.${f.element.name});""";
      }
    }
  }

  String _modelFieldForSave(_AnnotatedElement f) {
    if (f.annotation.read('isWriteNotNull').boolValue) {
      if (f.elementType.isDartCoreList) {
        return """Helper.writeModelListNotNull(data, \'${f.element.name}\', doc.${f.element.name});""";
      } else {
        return """Helper.writeModelNotNull(data, \'${f.element.name}\', doc.${f.element.name});""";
      }
    } else {
      if (f.elementType.isDartCoreList) {
        return """Helper.writeModelList(data, \'${f.element.name}\', doc.${f.element.name});""";
      } else {
        return """Helper.writeModel(data, \'${f.element.name}\', doc.${f.element.name});""";
      }
    }
  }

  String _storageFieldForSave(_AnnotatedElement f) {
    final folderName = f.annotation.read('folderName').isNull
        ? f.element.name
        : f.annotation.read('folderName').stringValue;
    final isSetNull = f.annotation.read('isSetNull').boolValue;
    if (f.annotation.read('isWriteNotNull').boolValue) {
      if (f.elementType.type == 'List<StorageFile>') {
        return """Helper.writeStorageListNotNull(data, \'$folderName\', doc.${f.element.name}, isSetNull: $isSetNull);""";
      } else if (f.elementType.type == 'StorageFile') {
        return """Helper.writeStorageNotNull(data, \'$folderName\', doc.${f.element.name}, isSetNull: $isSetNull);""";
      }
    } else {
      if (f.elementType.type == 'List<StorageFile>') {
        return """Helper.writeStorageList(data, \'$folderName\', doc.${f.element.name}, isSetNull: $isSetNull);""";
      } else if (f.elementType.type == 'StorageFile') {
        return """Helper.writeStorage(data, \'$folderName\', doc.${f.element.name}, isSetNull: $isSetNull);""";
      }
    }
    return '';
  }

  /// For load
  String _fieldForLoad(_AnnotatedElement f) {
    if (f.elementType.type.contains('Increment<')) {
      final _type =
          f.elementType.type.replaceAll('Increment<', '').replaceAll('>', '');
      return '''doc.${f.element.name} = Helper.valueFromIncrement<$_type>(data, \'${f.element.name}\');''';
    } else {
      if (f.elementType.isDartCoreList) {
        if (f.elementType.type.contains('Map')) {
          final mapValueType =
              f.elementType.type.split(', ')[1].replaceAll('>', '');
          return """doc.${f.element.name} = Helper.valueMapListFromKey<String, $mapValueType>(data, \'${f.element.name}\');""";
        }
        final _type =
            f.elementType.type.replaceAll('List<', '').replaceAll('>', '');
        return """doc.${f.element.name} = Helper.valueListFromKey<$_type>(data, \'${f.element.name}\');""";
      } else {
        if (f.elementType.isDartCoreMap) {
          final mapValueType =
              f.elementType.type.split(', ')[1].replaceAll('>', '');
          return """doc.${f.element.name} = Helper.valueMapFromKey<String, $mapValueType>(data, \'${f.element.name}\');""";
        } else if (f.elementType.type == 'Timestamp') {
          return """
          if (data[\'${f.element.name}\'] is Map) {
            doc.${f.element.name} = Helper.timestampFromMap(data, \'${f.element.name}\');
          } else {
            doc.${f.element.name} = Helper.valueFromKey<${f.elementType.type}>(data, \'${f.element.name}\');
          }
          """;
        }
        return """doc.${f.element.name} = Helper.valueFromKey<${f.elementType.type}>(data, \'${f.element.name}\');""";
      }
    }
  }

  String _modelFieldForLoad(_AnnotatedElement f) {
    if (f.elementType.isDartCoreList) {
      final local = '_${f.element.name}';
      final _type =
          f.elementType.type.replaceAll('List<', '').replaceAll('>', '');
      return """
      final $local = Helper.valueMapListFromKey<String, dynamic>(data, \'${f.element.name}\');
      if ($local != null) {
        doc.${f.element.name} = $local.where((d) => d != null).map((d) => $_type(values: d)).toList();
      } else {
        doc.${f.element.name} = null;
      }
      """;
    } else {
      final local = '_${f.element.name}';
      return """
      final $local = Helper.valueMapFromKey<String, dynamic>(data, \'${f.element.name}\');
      if ($local != null) {
        doc.${f.element.name} = ${f.elementType.type}(values: $local);
      } else {
        doc.${f.element.name} = null;
      }
      """;
    }
  }

  String _storageFieldForLoad(_AnnotatedElement f) {
    final folderName = f.annotation.read('folderName').isNull
        ? f.element.name
        : f.annotation.read('folderName').stringValue;
    if (f.elementType.isDartCoreList) {
      return """doc.${f.element.name} = Helper.storageFiles(data, \'$folderName\');""";
    } else {
      return """doc.${f.element.name} = Helper.storageFile(data, \'$folderName\');""";
    }
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

extension DartTypeExtension on DartType {
  String get type {
    return toString().replaceAll('*', '');
  }
}
