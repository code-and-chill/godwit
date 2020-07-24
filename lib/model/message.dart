class Message {
  String key;
  String senderId;
  String message;
  bool seen;
  String createdAt;
  String timestamp;

  String senderName;
  String receiverId;

  Message(
      {this.key,
      this.senderId,
      this.message,
      this.seen,
      this.createdAt,
      this.receiverId,
      this.senderName,
      this.timestamp});

  factory Message.fromJson(Map<dynamic, dynamic> json) =>
      Message(
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
