class Utils {
  static String capitalizeFirstLetter(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  static String getDartType(Type type) {
    switch (type) {
      case const (String):
        return 'String';
      case const (int):
        return 'int';
      case const (double):
        return 'double';
      case const (bool):
        return 'bool';
      case const (List):
        return 'List';
      default:
        return 'dynamic';
    }
  }

  static String toCamelCase(String text) {
    final parts = text.split('_');
    final camelCaseText =
        parts.first + parts.skip(1).map((part) => part[0].toUpperCase() + part.substring(1)).join();
    return camelCaseText;
  }
}
