/// Not exactly RFC 4810
class CsvParser {
  const CsvParser({this.separator = ';'});
  final String separator;

  static List<String> _splitLine(final String line) {
    var buff = <String>[''];
    var inQuotationMark = false;

    for (var i = 0; i < line.length; i++) {
      if (!inQuotationMark) {
        if (line[i] == ',') {
          buff = [...buff, ''];
          continue;
        }
      }
      if (line[i] == '"') {
        inQuotationMark = !inQuotationMark;
        continue;
      }
      buff.last += line[i];
    }
    return buff;
  }

  List<Map<String, dynamic>> parse(final List<String> csv) {
    var lineNumber = 0;
    late final List<String> header;
    final content = <List<String>>[];

    csv.forEach((final line) {
      if (lineNumber == 0) {
        header = _splitLine(line);
      } else {
        content.add(_splitLine(line));
      }
      lineNumber++;
    });

    return content.map((final e) => Map.fromIterables(header, e)).toList();
  }
}
