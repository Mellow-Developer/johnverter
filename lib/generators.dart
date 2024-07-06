import 'package:json_converter/utils.dart';

class Generator {
  static String generateRequestDtoClass(
    final String className,
    final dynamic jsonMap,
    final bool considerFinalFields,
    final bool considerNullable,
    final bool includeToJson,
    final bool reqPrefix,
  ) {
    if (jsonMap is Map<String, dynamic>) {
      final constructorFields = jsonMap.entries.map((entry) {
        final fieldName = Utils.toCamelCase(entry.key);
        return '  this.$fieldName;';
      }).join('\n');

      final fields = jsonMap.entries.map(
        (entry) {
          final fieldType = entry.value.runtimeType;
          final fieldName = Utils.toCamelCase(entry.key);
          if (entry.value is List) {
            return '  ${considerFinalFields ? 'final' : ''} List<${Utils.capitalizeFirstLetter(fieldName)}${reqPrefix ? 'Req' : ''}Dto?>? $fieldName;';
          } else if (entry.value is Map<String, dynamic>) {
            return '  ${considerFinalFields ? 'final' : ''} ${Utils.capitalizeFirstLetter(fieldName)}${reqPrefix ? 'Req' : ''}Dto? $fieldName;';
          } else {
            final dartType = Utils.getDartType(fieldType);
            return '  ${considerFinalFields ? 'final' : ''} $dartType${considerNullable ? '?' : ''} $fieldName;';
          }
        },
      ).join('\n');

      String toJsonAssignments = '';
      if (includeToJson) {
        jsonMap.forEach(
          (key, value) {
            if (value is Map<String, dynamic>) {
              toJsonAssignments = '$toJsonAssignments      \'$key\': ${key.toLowerCase()}?.toJson(),';
            } else {
              toJsonAssignments = '$toJsonAssignments      \'$key\': ${Utils.toCamelCase(key)}${value is List ? '?.map((e) => e?.toJson()).toList()' : ''},';
            }
          },
        );
      }

      String codeString = '''
class $className${reqPrefix ? 'Req' : ''}Dto {
  $className${reqPrefix ? 'Req' : ''}Dto({
${constructorFields.replaceAll(';', ',')}
  });

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
            final nestedCodeString = generateRequestDtoClass(Utils.capitalizeFirstLetter(key),
                value.firstOrNull, considerFinalFields, considerNullable, includeToJson, reqPrefix);

            codeString = codeString + nestedCodeString;
          } else if (value is Map<String, dynamic>) {
            final nestedCodeString = generateRequestDtoClass(Utils.capitalizeFirstLetter(key),
                value, considerFinalFields, considerNullable, includeToJson, reqPrefix);

            codeString = codeString + nestedCodeString;
          }
        },
      );

      return codeString;
    } else {
      /// Type is something else not json
      final fieldName = Utils.toCamelCase(className);

      final constructorFields = '  this.${className.toLowerCase()};';

      String fields = '';

      final fieldType = jsonMap.runtimeType;

      if (jsonMap is List) {
        fields =
            '  ${considerFinalFields ? 'final' : ''} List<${Utils.capitalizeFirstLetter(fieldName)}${reqPrefix ? 'Req' : ''}Dto?>? $fieldName;';
      } else if (jsonMap is Map<String, dynamic>) {
        fields =
            '  ${considerFinalFields ? 'final' : ''} ${Utils.capitalizeFirstLetter(fieldName)}${reqPrefix ? 'Req' : ''}Dto? $fieldName;';
      } else {
        final dartType = Utils.getDartType(fieldType);
        fields =
            '  ${considerFinalFields ? 'final' : ''} $dartType${considerNullable ? '?' : ''} ${className.toLowerCase()};';
      }

      final toJsonAssignments = includeToJson
          ? '      \'${className.toLowerCase()}\': ${className.toLowerCase()}${jsonMap is List ? '?.map((e) => e?.toJson()).toList()' : jsonMap is Map<String, dynamic> ? '?.toJson()' : ''},'
          : '';

      String codeString = '''
class $className${reqPrefix ? 'Req' : ''}Dto {
  $className${reqPrefix ? 'Req' : ''}Dto({
${constructorFields.replaceAll(';', ',')}
  });

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

      return codeString;
    }
  }

  static String generateRequestEntityClass() {
    return '';
  }

  static String generateMappers() {
    return '';
  }

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
