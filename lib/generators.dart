import 'package:json_converter/utils.dart';

class Generator {
  static String generateDtoClass(
    final String className,
    final Map<String, dynamic> jsonMap,
    final bool considerFinalFields,
    final bool considerNullable,
    final bool includeFromJson,
    final bool includeToJson,
    final bool resPrefix,
  ) {
    final constructorFields = jsonMap.entries.map((entry) {
      final fieldName = Utils.toCamelCase(entry.key);
      return '  this.$fieldName;';
    }).join('\n');

    final fields = jsonMap.entries.map(
      (entry) {
        final fieldType = entry.value.runtimeType;
        final fieldName = Utils.toCamelCase(entry.key);
        if (entry.value is List) {
          return '  ${considerFinalFields ? 'final' : ''} List<${Utils.capitalizeFirstLetter(fieldName)}${resPrefix ? 'Res' : ''}Dto?>? $fieldName;';
        } else if (entry.value is Map<String, dynamic>) {
          return '  ${considerFinalFields ? 'final' : ''} ${Utils.capitalizeFirstLetter(fieldName)}${resPrefix ? 'Res' : ''}Dto? $fieldName;';
        } else {
          final dartType = Utils.getDartType(fieldType);
          return '  ${considerFinalFields ? 'final' : ''} $dartType${considerNullable ? '?' : ''} $fieldName;';
        }
      },
    ).join('\n');

    final fromJsonAssignments = includeFromJson
        ? jsonMap.entries.map((entry) {
            if (entry.value is List) {
              final fieldName = Utils.toCamelCase(entry.key);
              return '        $fieldName: json[\'${entry.key}\'].map((final dynamic value) => ${Utils.capitalizeFirstLetter(fieldName)}${resPrefix ? 'Res' : ''}Dto.fromJson(value)).toList(),';
            } else {
              final fieldName = Utils.toCamelCase(entry.key);
              final fieldType = entry.value.runtimeType;
              if (entry.value is Map<String, dynamic>) {
                return '        $fieldName: json[\'${entry.key}\'] != null ? ${Utils.capitalizeFirstLetter(fieldName)}${resPrefix ? 'Res' : ''}Dto.fromJson(json[\'${entry.key}\'] as Map<String, dynamic>) : null,';
              } else {
                final dartType = Utils.getDartType(fieldType);
                return '        $fieldName: json[\'${entry.key}\'] != null ? json[\'${entry.key}\'] as $dartType : null,';
              }
            }
          }).join('\n')
        : '';

    final toJsonAssignments = includeToJson
        ? jsonMap.keys.map((key) => '      \'$key\': ${Utils.toCamelCase(key)},').join('\n')
        : '';

    String codeString = '''
class $className${resPrefix ? 'Res' : ''}Dto {
  $className${resPrefix ? 'Res' : ''}Dto({
${constructorFields.replaceAll(';', ',')}
  });

${includeFromJson ? '  factory $className${resPrefix ? 'Res' : ''}Dto.fromJson(final Map<String, dynamic> json) => $className${resPrefix ? 'Res' : ''}Dto(\n$fromJsonAssignments\n      );' : ''}

${includeToJson ? '''
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
$toJsonAssignments
    };
  }
''' : ''}

$fields
}

''';

    jsonMap.forEach(
      (key, value) {
        if (value is List) {
          final nestedCodeString = generateDtoClass(
            Utils.capitalizeFirstLetter(key),
            value.firstOrNull,
            considerFinalFields,
            considerNullable,
            includeFromJson,
            includeToJson,
            resPrefix,
          );

          codeString = codeString + nestedCodeString;
        } else if (value is Map<String, dynamic>) {
          final nestedCodeString = generateDtoClass(
            Utils.capitalizeFirstLetter(key),
            value,
            considerFinalFields,
            considerNullable,
            includeFromJson,
            includeToJson,
            resPrefix,
          );

          codeString = codeString + nestedCodeString;
        }
      },
    );

    return codeString;
  }

  static String generateEntityClass(
    final String className,
    final Map<String, dynamic> jsonMap,
    final bool considerFinalFields,
    final bool considerNullable,
    final bool includeFromJson,
    final bool includeToJson,
    final bool resPrefix,
  ) {
    final constructorFields = jsonMap.entries.map((entry) {
      final fieldName = Utils.toCamelCase(entry.key);
      return '  this.$fieldName;';
    }).join('\n');

    final fields = jsonMap.entries.map((entry) {
      final fieldType = entry.value.runtimeType;
      final fieldName = Utils.toCamelCase(entry.key);
      if (entry.value is List) {
        return '  ${considerFinalFields ? 'final' : ''} List<${Utils.capitalizeFirstLetter(fieldName)}${resPrefix ? 'Res' : ''}Entity?>? $fieldName;';
      } else if (entry.value is Map<String, dynamic>) {
        return '  ${considerFinalFields ? 'final' : ''} ${Utils.capitalizeFirstLetter(fieldName)}${resPrefix ? 'Res' : ''}Entity? $fieldName;';
      } else {
        final dartType = Utils.getDartType(fieldType);
        return '  ${considerFinalFields ? 'final' : ''} $dartType${considerNullable ? '?' : ''} $fieldName;';
      }
    }).join('\n');

    String codeString = '''
class $className${resPrefix ? 'Res' : ''}Entity {
  $className${resPrefix ? 'Res' : ''}Entity({
${constructorFields.replaceAll(';', ',')}
  });

$fields
}

''';

    jsonMap.forEach(
      (key, value) {
        if (value is List) {
          final nestedCodeString = generateEntityClass(
            Utils.capitalizeFirstLetter(key),
            value.firstOrNull,
            considerFinalFields,
            considerNullable,
            includeFromJson,
            includeToJson,
            resPrefix,
          );

          codeString = codeString + nestedCodeString;
        } else if (value is Map<String, dynamic>) {
          final nestedCodeString = generateEntityClass(
            Utils.capitalizeFirstLetter(key),
            value,
            considerFinalFields,
            considerNullable,
            includeFromJson,
            includeToJson,
            resPrefix,
          );

          codeString = codeString + nestedCodeString;
        }
      },
    );

    return codeString;
  }

  static String generateMapperExtensions(
    String className,
    Map<String, dynamic> jsonMap,
    final bool resPrefix,
  ) {
    final fields = jsonMap.entries.map((entry) {
      final fieldName = Utils.toCamelCase(entry.key);
      final fieldValue = entry.value;
      if (fieldValue is List) {
        final nestedFieldName = Utils.toCamelCase(entry.key);
        return '      $fieldName: $nestedFieldName?.map((final ${Utils.capitalizeFirstLetter(fieldName)}${resPrefix ? 'Res' : ''}Dto? e) => e?.mapToEntity()).toList(),';
      } else if (fieldValue is Map<String, dynamic>) {
        final nestedFieldName = Utils.toCamelCase(entry.key);
        return '      $fieldName: $nestedFieldName?.mapToEntity(),';
      } else {
        return '      $fieldName: $fieldName,';
      }
    }).join('\n');

    String codeString = '''
extension $className${resPrefix ? 'Res' : ''}DtoMapper on $className${resPrefix ? 'Res' : ''}Dto {
  $className${resPrefix ? 'Res' : ''}Entity mapToEntity() {
    return $className${resPrefix ? 'Res' : ''}Entity(
$fields
    );
  }
}

''';

    jsonMap.forEach(
      (key, value) {
        if (value is List) {
          final nestedCodeString = generateMapperExtensions(
            Utils.capitalizeFirstLetter(key),
            value.firstOrNull,
            resPrefix,
          );

          codeString = codeString + nestedCodeString;
        } else if (value is Map<String, dynamic>) {
          final nestedCodeString = generateMapperExtensions(
            Utils.capitalizeFirstLetter(key),
            value,
            resPrefix,
          );

          codeString = codeString + nestedCodeString;
        }
      },
    );

    return codeString;
  }
}
