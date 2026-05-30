import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';

class AICoachScreen extends ConsumerStatefulWidget {
  const AICoachScreen({super.key});

  @override
  ConsumerState<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends ConsumerState<AICoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    "How is my health today?",
    "Papa ki health kaisi hai?",
    "Which subject is weak?",
    "Show my study pattern",
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Use a small delay to let the ListView rebuild with the new item first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _messageController.clear();
    ref.read(aiProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiColor = const Color(0xFF6C63FF);
    final aiState = ref.watch(aiProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: aiColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: aiColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('LifeOS AI Coach', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: theme.colorScheme.background,
        elevation: 1,
      ),
      body: Column(
        children: [
          if (aiState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.red.withOpacity(0.2), // Error color
              child: Text(
                aiState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                // Auto-scroll whenever messages change or typing state changes
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: aiState.messages.length + (aiState.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == aiState.messages.length && aiState.isTyping) {
                      return _buildThinkingBubble(theme, aiColor);
                    }
                    final msg = aiState.messages[index];
                    return _buildMessageBubble(msg, theme, aiColor);
                  },
                );
              },
            ),
          ),
          _buildSuggestions(theme, aiColor),
          _buildInputBox(theme, aiColor),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble(ThemeData theme, Color aiColor) {
    return FadeInUp(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('LifeOS AI is thinking', style: TextStyle(color: theme.colorScheme.onBackground, fontStyle: FontStyle.italic)),
              const SizedBox(width: 8),
              SizedBox(
                width: 20,
                child: TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: 3),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Text('.' * value, style: TextStyle(fontWeight: FontWeight.bold, color: aiColor));
                  },
                  onEnd: () {
                    // Loop animation is handled by rebuilding or a true typing indicator package in prod
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, ThemeData theme, Color aiColor) {
    final isAi = msg['isAi'];
    final bool animate = msg['animate'] == true;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAi ? theme.colorScheme.surface : aiColor,
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomLeft: isAi ? const Radius.circular(0) : const Radius.circular(20),
              bottomRight: isAi ? const Radius.circular(20) : const Radius.circular(0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: animate
              ? TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: msg['text'].length),
                  duration: Duration(milliseconds: msg['text'].length * 50),
                  builder: (context, value, child) {
                    return Text(
                      msg['text'].substring(0, value),
                      style: TextStyle(
                        color: isAi ? theme.colorScheme.onBackground : Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    );
                  },
                  onEnd: () {
                    // Turn off animation in the state map so it doesn't replay on scroll
                    msg['animate'] = false; 
                  },
                )
              : Text(
                  msg['text'],
                  style: TextStyle(
                    color: isAi ? theme.colorScheme.onBackground : Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme, Color aiColor) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(_suggestions[index]),
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(color: aiColor.withOpacity(0.3)),
              labelStyle: TextStyle(color: aiColor, fontWeight: FontWeight.w600),
              onPressed: () => _sendMessage(_suggestions[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBox(ThemeData theme, Color aiColor) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: theme.colorScheme.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: aiColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.send1, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
