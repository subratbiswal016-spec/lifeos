import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ai_repository.dart';

class AiState {
  final bool isTyping;
  final List<Map<String, dynamic>> messages;
  final String? error;

  AiState({
    this.isTyping = false, 
    this.messages = const [
      {
        "isAi": true,
        "text": "Namaste! I am your LifeOS AI Coach. Kaise help kar sakta hoon aaj?",
        "time": "10:00 AM"
      }
    ], 
    this.error
  });

  AiState copyWith({bool? isTyping, List<Map<String, dynamic>>? messages, String? error}) {
    return AiState(
      isTyping: isTyping ?? this.isTyping,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}

class AiProviderNotifier extends StateNotifier<AiState> {
  final AiRepository _repository;

  AiProviderNotifier(this._repository) : super(AiState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message locally
    final newMessages = List<Map<String, dynamic>>.from(state.messages);
    newMessages.add({
      "isAi": false,
      "text": text,
      "time": "Now"
    });

    state = state.copyWith(messages: newMessages, isTyping: true, error: null);

    // Call backend
    final response = await _repository.sendMessage(text);
    
    if (response.success && response.data != null) {
      final updatedMessages = List<Map<String, dynamic>>.from(state.messages);
      // updatedMessages.add({
      //   "isAi": true,
      //   "text": response.data!['reply'],
      //   "time": "Now",
      //   "animate": true
      // });
      state = state.copyWith(isTyping: false, messages: updatedMessages);
    } else {
      state = state.copyWith(isTyping: false, error: response.error ?? 'Failed to reach AI');
    }
  }
}

final aiProvider = StateNotifierProvider<AiProviderNotifier, AiState>((ref) {
  return AiProviderNotifier(ref.watch(aiRepositoryProvider));
});
