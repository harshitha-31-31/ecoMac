import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../services/groq_service.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState(messages: [], isLoading: false)) {
    _loadMessages();
  }

  // Load messages from database on init
  Future<void> _loadMessages() async {
    try {
      final messages = await DatabaseService.instance.getAllMessages();
      state = state.copyWith(messages: messages);
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = Message(
      id: Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Save to database
    await DatabaseService.instance.insertMessage(userMessage);

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final groq = GroqService();
      final response = await groq.sendMessage(text);
      final aiMessage = Message(
        id: Uuid().v4(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Save AI response to database
      await DatabaseService.instance.insertMessage(aiMessage);

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      final errorMessage = Message(
        id: Uuid().v4(),
        text: 'Error: $e. Check API key.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      await DatabaseService.instance.insertMessage(errorMessage);
      state = state.copyWith(messages: [...state.messages, errorMessage]);
    }
  }

  Future<void> clearChat() async {
    await DatabaseService.instance.deleteAllMessages();
    state = ChatState(messages: [], isLoading: false);
  }

  // Export methods
  Future<void> exportToWhatsApp() async {
    await ExportService.instance.shareToWhatsApp();
  }

  Future<String> saveToDevice() async {
    return await ExportService.instance.saveToDevice();
  }

  Future<void> shareFiles() async {
    await ExportService.instance.shareFiles();
  }

  Future<Map<String, dynamic>> getChatStatistics() async {
    return await ExportService.instance.getChatStatistics();
  }
}

class ChatState {
  final List<Message> messages;
  final bool isLoading;

  const ChatState({
    required this.messages,
    required this.isLoading,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) => ChatNotifier());

