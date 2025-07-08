class MessageModel {
  final String message;
  final String senderId;
  final String receiverId;
  final String senderEmail;
  final DateTime timestamp;

  MessageModel({
    required this.message,
    required this.senderId,
    required this.timestamp,
    required this.receiverId,
    required this.senderEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'timestamp1': timestamp,
      'receiverId': receiverId,
      'senderEmail': senderEmail,
    };
  }
}
