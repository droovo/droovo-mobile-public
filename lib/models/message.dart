class Message {
  final String uid;
  final String senderId;
  final String message;
  final DateTime time;

  const Message({
    required this.uid,
    required this.senderId,
    required this.message,
    required this.time,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        uid: json['uid'] as String,
        senderId: json['senderId'] as String,
        message: json['message'] as String,
        time: DateTime.parse(json['time'] as String),
      );
}

class Group {
  final String id;
  final String name;
  final List<Message> chats;

  const Group({
    required this.id,
    required this.name,
    this.chats = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        name: json['name'] as String,
        chats: (json['chats'] as List<dynamic>? ?? [])
            .map((m) => Message.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}
