/// Loads a single document from a TSV string.
List<Map<String, dynamic>> loadTsv(final String tsv) {
  final lines = tsv.split('\n');
  final header = lines[0].split('\t');
  final data = <List<String>>[];

  lines
      .skip(1)
      .where((final line) => line.isNotEmpty)
      .forEach((final line) => data.add(line.split('\t')));

  return data.map((final row) => Map.fromIterables(header, row)).toList();
}
