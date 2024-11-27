class ApiResponse {
  final bool success;
  final int status;
  final dynamic content;
  final String? timestamp;

  ApiResponse({required this.success, required this.status, this.content, this.timestamp});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 500,
      content: json['content'],
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}