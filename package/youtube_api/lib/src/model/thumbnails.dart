import 'dart:convert';

import 'package:youtube_api/src/model/thumbnail.dart';

/// Contains thumbnail in three sizes.
/// small, medium, and high resolution
class Thumbnails {
  final Thumbnail small;
  final Thumbnail medium;
  final Thumbnail high;
  Thumbnails({
    required this.small,
    required this.medium,
    required this.high,
  });

  Thumbnails copyWith({
    Thumbnail? small,
    Thumbnail? medium,
    Thumbnail? high,
  }) {
    return Thumbnails(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      high: high ?? this.high,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'default': small.toMap(),
      'medium': medium.toMap(),
      'high': high.toMap(),
    };
  }

  factory Thumbnails.fromMap(Map<String, dynamic> map) {
    return Thumbnails(
      small: Thumbnail.fromMap(map['default']),
      medium: Thumbnail.fromMap(map['medium']),
      high: Thumbnail.fromMap(map['high']),
    );
  }

  factory Thumbnails.fromJson(String source) =>
      Thumbnails.fromMap(json.decode(source));

  @override
  String toString() => jsonEncode(this.toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Thumbnails &&
        other.small == small &&
        other.medium == medium &&
        other.high == high;
  }

  @override
  int get hashCode => small.hashCode ^ medium.hashCode ^ high.hashCode;
}
