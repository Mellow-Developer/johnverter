import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_converter/generators.dart';
import 'package:json_converter/utils.dart';

class RequestDtoGenerator extends StatefulWidget {
  const RequestDtoGenerator({super.key});

  @override
  State<RequestDtoGenerator> createState() => _RequestDtoGeneratorState();
}

class _RequestDtoGeneratorState extends State<RequestDtoGenerator> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _considerFinalFields = true;
  bool _considerNullable = true;
  bool _includeToJson = true;
  bool _reqPrefix = true;
  String _dtoClass = '';
  String _entityClass = '';
  String _mappers = '';

  void _convertJsonToDto() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final jsonString = _jsonController.text;
    final baseClassName = Utils.capitalizeFirstLetter(_classNameController.text);
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString.startsWith('[')
          ? jsonString.substring(jsonString.indexOf('{'), jsonString.indexOf('}') + 1).toString()
          : jsonString);
      Map<String, dynamic> targetJsonMap;

      targetJsonMap = jsonMap;

      final dtoClass = Generator.generateRequestDtoClass(
        baseClassName,
        targetJsonMap,
        _considerFinalFields,
        _considerNullable,
        _includeToJson,
        _reqPrefix,
      );
      final entityClass = Generator.generateRequestEntityClass(
        baseClassName,
        targetJsonMap,
        _considerFinalFields,
        _considerNullable,
        _reqPrefix,
      );
      final mappers = Generator.generateRequestMapperExtensions(
        baseClassName,
        targetJsonMap,
        _reqPrefix,
      );

      setState(() {
        _dtoClass = dtoClass;
        _entityClass = entityClass;
        _mappers = mappers;
      });
    } catch (e) {
      setState(() {
        _dtoClass = 'Error parsing JSON: $e';
        _entityClass = 'Error parsing JSON: $e';
        _mappers = 'Error parsing JSON: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Colors.white,
        title: const Text(
          'Request DTO generator',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ListView(
                      shrinkWrap: true,
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
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Switch(
                              value: _considerFinalFields,
                              onChanged: (bool? value) {
                                setState(() {
                                  _considerFinalFields = value ?? false;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Use final fields',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: _considerNullable,
                              onChanged: (bool? value) {
                                setState(() {
                                  _considerNullable = value ?? false;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Make fields nullable',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: _reqPrefix,
                              onChanged: (bool? value) {
                                setState(() {
                                  _reqPrefix = value ?? false;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Add Req prefix',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Switch(
                              value: _includeToJson,
                              onChanged: (bool? value) {
                                setState(() {
                                  _includeToJson = value ?? false;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Include toJson method',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _convertJsonToDto,
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.white,
                          ),
                          side: MaterialStateProperty.resolveWith(
                                (states) => const BorderSide(
                              color: Colors.black26,
                              width: 2,
                            ),
                          ),
                          elevation: MaterialStateProperty.resolveWith((states) => 1),
                          padding: MaterialStateProperty.resolveWith(
                                (states) => const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          shape: MaterialStateProperty.resolveWith(
                                (states) =>
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          )),
                      child: const Text(
                        'Convert',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildContainer(
                      title: 'DTOs',
                      content: _dtoClass,
                      onCopyPressed: () => _copyToClipboard(_dtoClass),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: _buildContainer(
                      title: 'Entities',
                      content: _entityClass,
                      onCopyPressed: () => _copyToClipboard(_entityClass),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
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
                    shape: MaterialStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: Text(
                    'Copy $title',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
    if (content.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: content));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text(
            'Copied to clipboard',
            style: TextStyle(color: Colors.teal),
          ),
          backgroundColor: Colors.greenAccent,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
