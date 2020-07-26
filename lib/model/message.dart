class Message {
  String key;
  String senderId;
  String senderName;
  String receiverId;
  String message;
  bool seen;
  String timestamp;

  factory Message.fromJson(Map<dynamic, dynamic> json) => Message(
        key: json["key"],
        senderId: json["sender_id"],
        senderName: json["sender_name"],
        receiverId: json["receiver_id"],
        message: json["message"],
        seen: json["seen"],
        createdAt: json["created_at"],
        timestamp: json['timestamp'],
      );

  String createdAt;

  Message(
      {this.key,
      this.senderId,
      this.message,
      this.seen,
      this.createdAt,
      this.receiverId,
      this.senderName,
      this.timestamp});

  Map<String, dynamic> toJson() =>
      {
        "key": key,
        "sender_id": senderId,
        "sender_name": senderName,
        "receiver_id": receiverId,
        "message": message,
        "seen": seen,
        "timestamp": timestamp,
        "created_at": createdAt,
      };
}
