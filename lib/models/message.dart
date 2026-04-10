import 'package:flutter/foundation.dart';

@immutable
class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
  );

  @override
  String toString() => 'Message(id: $id, text: $text, isUser: $isUser, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other) ) return true;
    return other is Message &&
      other.id == id &&
      other.text == text &&
      other.isUser == isUser &&
      other.timestamp == timestamp;
  }

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ isUser.hashCode ^ timestamp.hashCode;
}
