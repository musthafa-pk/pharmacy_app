class NotificationModel {
  int id;
  int pharmacyId;
  String message;
  bool seen;
  DateTime createdDate;

  NotificationModel({
    required this.id,
    required this.pharmacyId,
    required this.message,
    required this.seen,
    required this.createdDate,
  });

  // Factory method to parse JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      pharmacyId: json['pharmacyId'],
      message: json['message'],
      seen: json['view_status'] == "Seen",
      createdDate: DateTime.parse(json['created_date']),
    );
  }
}
