import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON to DTO Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const JsonToDtoConverter(),
    );
  }
}

class JsonToDtoConverter extends StatefulWidget {
  const JsonToDtoConverter({Key? key}) : super(key: key);

  @override
  _JsonToDtoConverterState createState() => _JsonToDtoConverterState();
}

class _JsonToDtoConverterState extends State<JsonToDtoConverter> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _considerDataKey = false;
  bool _considerNullable = true;
  bool _includeFromJson = true;
  bool _includeToJson = false;
  String _dtoClass = '';
  String _entityClass = '';
  String _mappers = '';

  void _convertJsonToDto() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final jsonString = _jsonController.text;
    final baseClassName = _capitalizeFirstLetter(_classNameController.text);
    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      Map<String, dynamic> targetJsonMap;

      if (_considerDataKey && jsonMap.containsKey('data')) {
        targetJsonMap = jsonMap['data'];
      } else {
        targetJsonMap = jsonMap;
      }

      final dtoClass = _generateDtoClass(baseClassName, targetJsonMap);
      final entityClass = _generateEntityClass(baseClassName, targetJsonMap);
      final mappers = _generateMapperExtensions(baseClassName, targetJsonMap);

      setState(() {
        _dtoClass = dtoClass;
        _entityClass = entityClass;
        _mappers = mappers;
      });
    } catch (e) {
      setState(() {
        _dtoClass = 'Error parsing JSON: $e';
        _entityClass = '';
        _mappers = '';
      });
    }
  }

  String _generateDtoClass(String className, Map<String, dynamic> jsonMap) {
    final fields = jsonMap.entries.map((entry) {
      final fieldType = entry.value.runtimeType;
      final fieldName = _toCamelCase(entry.key);
      if (entry.value is Map<String, dynamic>) {
        return '  ${_capitalizeFirstLetter(fieldName)}Dto? $fieldName;';
      } else {
        final dartType = _getDartType(fieldType);
        return '  $dartType${_considerNullable ? '?' : ''} $fieldName;';
      }
    }).join('\n');

    final fromJsonAssignments = _includeFromJson
        ? jsonMap.entries.map((entry) {
      final fieldName = _toCamelCase(entry.key);
      final fieldType = entry.value.runtimeType;
      if (entry.value is Map<String, dynamic>) {
        return '        $fieldName: json[\'${entry.key}\'] != null ? ${_capitalizeFirstLetter(fieldName)}Dto.fromJson(json[\'${entry.key}\'] as Map<String, dynamic>) : null,';
      } else {
        final dartType = _getDartType(fieldType);
        return '        $fieldName: json[\'${entry.key}\'] != null ? json[\'${entry.key}\'] as $dartType : null,';
      }
    }).join('\n')
        : '';

    final toJsonAssignments = _includeToJson
        ? jsonMap.keys.map((key) => '      \'$key\': ${_toCamelCase(key)},').join('\n')
        : '';

    final nestedClasses = jsonMap.entries
        .where((entry) => entry.value is Map<String, dynamic>)
        .map((entry) {
      final nestedClassName = _capitalizeFirstLetter(entry.key);
      return _generateDtoClass(nestedClassName, entry.value as Map<String, dynamic>);
    }).join('\n');

    return '''
class ${className}Dto {
  ${className}Dto({
${fields.replaceAll(';', ',')}
  });

${_includeFromJson ? '  factory ${className}Dto.fromJson(Map<String, dynamic> json) => ${className}Dto(\n$fromJsonAssignments\n      );' : ''}

${_includeToJson ? '''
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
$toJsonAssignments
    };
  }
''' : ''}

${fields}
}

$nestedClasses
''';
  }

  String _getElementType(List list) {
    if (list.isEmpty) {
      return 'dynamic';
    } else {
      return _getDartType(list.first.runtimeType);
    }
  }

  String _capitalizeFirstLetter(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  String _generateEntityClass(String className, Map<String, dynamic> jsonMap) {
    final fields = jsonMap.entries.map((entry) {
      final fieldType = entry.value.runtimeType;
      final fieldName = _toCamelCase(entry.key);
      if (entry.value is Map<String, dynamic>) {
        return '  ${_capitalizeFirstLetter(fieldName)}Entity? $fieldName;';
      } else {
        final dartType = _getDartType(fieldType);
        return '  $dartType${_considerNullable ? '?' : ''} $fieldName;';
      }
    }).join('\n');

    final nestedClasses =
        jsonMap.entries.where((entry) => entry.value is Map<String, dynamic>).map((entry) {
      final nestedClassName = _capitalizeFirstLetter(entry.key);
      return _generateEntityClass(nestedClassName, entry.value as Map<String, dynamic>);
    }).join('\n');

    return '''
class ${className}Entity {
  ${className}Entity({
${fields.replaceAll(';', ',')}
  });

${fields}
}

$nestedClasses
''';
  }

  String _generateMapperExtensions(String className, Map<String, dynamic> jsonMap) {
    final fields = jsonMap.entries.map((entry) {
      final fieldName = _toCamelCase(entry.key);
      final fieldValue = entry.value;
      if (fieldValue is Map<String, dynamic>) {
        final nestedClassName = _capitalizeFirstLetter(entry.key);
        final nestedFieldName = _toCamelCase(entry.key);
        return '      $fieldName: $nestedFieldName.mapToEntity(),';
      } else {
        return '      $fieldName: $fieldName,';
      }
    }).join('\n');

    final nestedMappers =
        jsonMap.entries.where((entry) => entry.value is Map<String, dynamic>).map((entry) {
      final nestedClassName = _capitalizeFirstLetter(entry.key);
      return _generateMapperExtensions(nestedClassName, entry.value as Map<String, dynamic>);
    }).join('\n');

    return '''
extension ${className}DtoMapper on ${className}Dto {
  ${className}Entity mapToEntity() {
    return ${className}Entity(
$fields
    );
  }
}

$nestedMappers
''';
  }

  String _getDartType(Type type) {
    switch (type) {
      case String:
        return 'String';
      case int:
        return 'int';
      case double:
        return 'double';
      case bool:
        return 'bool';
      case List:
        return 'List';
      default:
        return 'dynamic';
    }
  }

  String _toCamelCase(String text) {
    final parts = text.split('_');
    final camelCaseText =
        parts.first + parts.skip(1).map((part) => part[0].toUpperCase() + part.substring(1)).join();
    return camelCaseText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON to DTO Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(
                  labelText: 'Enter Base Class Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a base class name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jsonController,
                decoration: const InputDecoration(
                  labelText: 'Enter JSON here',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter JSON';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _considerDataKey,
                    onChanged: (bool? value) {
                      setState(() {
                        _considerDataKey = value ?? false;
                      });
                    },
                  ),
                  const Text('Consider only keys inside the "data" key'),
                  const SizedBox(width: 16),
                  Checkbox(
                    value: _considerNullable,
                    onChanged: (bool? value) {
                      setState(() {
                        _considerNullable = value ?? false;
                      });
                    },
                  ),
                  const Text('Make fields nullable'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _includeFromJson,
                    onChanged: (bool? value) {
                      setState(() {
                        _includeFromJson = value ?? true;
                      });
                    },
                  ),
                  const Text('Include fromJson method'),
                  const SizedBox(width: 16),
                  Checkbox(
                    value: _includeToJson,
                    onChanged: (bool? value) {
                      setState(() {
                        _includeToJson = value ?? false;
                      });
                    },
                  ),
                  const Text('Include toJson method'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _convertJsonToDto,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => const Color(0xFF6200EE),
                        ),
                        padding: MaterialStateProperty.resolveWith(
                          (states) => const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      child: const Text('Convert'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildContainer(
                      title: 'DTOs',
                      content: _dtoClass,
                      onCopyPressed: () => _copyToClipboard(_dtoClass),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildContainer(
                      title: 'Entities',
                      content: _entityClass,
                      onCopyPressed: () => _copyToClipboard(_entityClass),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildContainer(
                      title: 'Mappers',
                      content: _mappers,
                      onCopyPressed: () => _copyToClipboard(_mappers),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContainer({
    required String title,
    required String content,
    required VoidCallback onCopyPressed,
  }) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
        color: title == 'DTOs'
            ? Colors.blueAccent.withAlpha(50)
            : title == 'Entities'
                ? Colors.red.withAlpha(50)
                : Colors.green.withAlpha(50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onCopyPressed,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Colors.white,
                    ),
                  ),
                  child: const Text('Copy'),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 370,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}
