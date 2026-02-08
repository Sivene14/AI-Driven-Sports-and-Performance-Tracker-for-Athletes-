import 'package:flutter/material.dart';
import 'openrouter_service.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  final openRouter = OpenRouterService("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");

  Future<void> sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": input});
      _controller.clear();
    });

    try {
      final reply = await openRouter.askOpenRouter(input);
      if (!mounted) return;
      setState(() {
        messages.add({"role": "assistant", "text": reply});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.add({"role": "assistant", "text": "Error: $e"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Sports Tracker - Assistant"),
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.blueAccent
                          : (isDark ? Colors.grey[800] : Colors.grey[300]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: theme.cardColor, // ✅ adapts to dark/light theme
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: theme.textTheme.bodyMedium, // ✅ text adapts to theme
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: theme.colorScheme.secondary),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}