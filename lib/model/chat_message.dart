class ChatMessage {
  String key;
  String senderId;
  String message;
  bool seen;
  String createdAt;
  String timestamp;

  String senderName;
  String receiverId;

  ChatMessage({this.key, this.senderId, this.message, this.seen, this.createdAt, this.receiverId, this.senderName, this.timestamp});

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) => ChatMessage(
      key: json["key"],
      senderId: json["sender_id"],
      message: json["message"],
      seen: json["seen"],
      createdAt: json["created_at"],
      timestamp: json['timestamp'],
      senderName: json["senderName"],
      receiverId: json["receiverId"]);

  Map<String, dynamic> toJson() => {
        "key": key,
        "sender_id": senderId,
        "message": message,
        "receiverId": receiverId,
        "seen": seen,
        "created_at": createdAt,
        "senderName": senderName,
        "timestamp": timestamp
      };
}
