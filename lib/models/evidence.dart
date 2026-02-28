class CustodyEvent {
  final String event;
  final String time;

  CustodyEvent({
    required this.event,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        "event": event,
        "time": time,
      };

  factory CustodyEvent.fromJson(Map<String, dynamic> json) {
    return CustodyEvent(
      event: json["event"],
      time: json["time"],
    );
  }
}

class Evidence {
  final String imagePath;
  final String hash;
  final String evidenceId;
  final String timestamp;

  // ✅ NEW
  final String caption;
  final String description;

  List<CustodyEvent> custody;

  Evidence({
    required this.imagePath,
    required this.hash,
    required this.evidenceId,
    required this.timestamp,
    required this.caption,
    required this.description,
    required this.custody,
  });

  // ================= JSON SAVE =================
  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'hash': hash,
        'evidenceId': evidenceId,
        'timestamp': timestamp,
        'caption': caption,
        'description': description,
        'custody': custody.map((e) => e.toJson()).toList(),
      };

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      imagePath: json['imagePath'],
      hash: json['hash'],
      evidenceId: json['evidenceId'],
      timestamp: json['timestamp'],
      caption: json['caption'] ?? "",
      description: json['description'] ?? "",
      custody: (json['custody'] as List)
          .map((e) => CustodyEvent.fromJson(e))
          .toList(),
    );
  }
}