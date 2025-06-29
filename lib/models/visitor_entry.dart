class VisitorEntry {
  final int? id;
  final String licensePlate;
  final String houseNumber;
  final String? timestamp;

  VisitorEntry({
    this.id,
    required this.licensePlate,
    required this.houseNumber,
    this.timestamp,
  });

  factory VisitorEntry.fromJson(Map<String, dynamic> json) {
    return VisitorEntry(
      id: json['id'],
      licensePlate: json['license_plate'] ?? '',
      houseNumber: json['house_number'] ?? '',
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_plate': licensePlate,
      'house_number': houseNumber,
      'timestamp': timestamp,
    };
  }
}

class ApiResponse {
  final String? message;
  final String? error;
  final VisitorEntry? entry;
  final List<VisitorEntry>? entries;
  final int? total;

  ApiResponse({this.message, this.error, this.entry, this.entries, this.total});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      message: json['message'],
      error: json['error'],
      entry:
          json['entry'] != null ? VisitorEntry.fromJson(json['entry']) : null,
      entries:
          json['entries'] != null
              ? (json['entries'] as List)
                  .map((e) => VisitorEntry.fromJson(e))
                  .toList()
              : null,
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error,
      'entry': entry?.toJson(),
      'entries': entries?.map((e) => e.toJson()).toList(),
      'total': total,
    };
  }
}
