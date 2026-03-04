class PhotoEvidence {
  final String id;
  final String inspectionId;
  final String sectionId;
  final String questionId;
  final String localPath;
  final String? remoteUrl;
  final String caption;
  final DateTime timestamp;

  PhotoEvidence({
    required this.id,
    required this.inspectionId,
    required this.sectionId,
    required this.questionId,
    required this.localPath,
    this.remoteUrl,
    this.caption = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'inspectionId': inspectionId,
        'sectionId': sectionId,
        'questionId': questionId,
        'localPath': localPath,
        'remoteUrl': remoteUrl ?? '',
        'caption': caption,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PhotoEvidence.fromJson(Map<String, dynamic> json) => PhotoEvidence(
        id: json['id'] as String,
        inspectionId: json['inspectionId'] as String,
        sectionId: json['sectionId'] as String,
        questionId: json['questionId'] as String,
        localPath: json['localPath'] as String? ?? '',
        remoteUrl: json['remoteUrl'] as String?,
        caption: json['caption'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
}
