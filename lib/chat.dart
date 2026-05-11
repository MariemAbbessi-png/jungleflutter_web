import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; 
import 'bg.dart';
import 'package:file_picker/file_picker.dart';


class chat extends StatefulWidget {
  const chat({super.key});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  List<Map<String, String>> messages = [];
  List<Map<String, dynamic>> chatHistory = [];
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool showSidebar = false;
  int? currentHistoryIndex;
  String sessionId = Random().nextInt(999999).toString();
  Future<void> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true, 
  );

  if (result != null) {
    final file = result.files.first;

    setState(() {
      messages.add({
        "text": "📎 ${file.name}",
        "sender": "user"
      });
    });

    sendFile(file);
  }
}
Future<void> sendFile(PlatformFile file) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://localhost:3000/chat/upload"),
    );

    request.fields['sessionId'] = sessionId;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        file.bytes!, 
        filename: file.name,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      setState(() {
        messages.add({"text": data["reply"], "sender": "bot"});
      });
    }
  } catch (e) {
    setState(() {
      messages.add({"text": "Erreur upload ", "sender": "bot"});
    });
  }
}
  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add({"text": text, "sender": "user"});
    });

    controller.clear();
    scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/chat"), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": text,
          "sessionId": sessionId, 
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages.add({"text": data["reply"], "sender": "bot"});

      if (currentHistoryIndex != null) {
        chatHistory[currentHistoryIndex!]["messages"] = List.from(messages);
        }
        });
        scrollToBottom();
      }
    } catch (e) {
      setState(() {
        messages.add({"text": "Error ", "sender": "bot"});
      });
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  void newChat() async {
  if (messages.isNotEmpty) {
    chatHistory.add({
      "sessionId": sessionId,
      "messages": List.from(messages),
    });
  }

  await http.post(
    Uri.parse("http://localhost:3000/chat/reset"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"sessionId": sessionId}),
  );

  setState(() {
    messages.clear();
    sessionId = Random().nextInt(999999).toString();
    currentHistoryIndex = null;
  });
}
void loadHistory(int index) {
  final chat = chatHistory[index];

  setState(() {
    messages = List.from(chat["messages"]);
    sessionId = chat["sessionId"];
    currentHistoryIndex = index;
    showSidebar = false;
  });

  scrollToBottom();
}

  void deleteHistory(int index) {
    setState(() {
      chatHistory.removeAt(index);
      if (currentHistoryIndex == index) {
        currentHistoryIndex = null;
      } else if (currentHistoryIndex != null && currentHistoryIndex! > index) {
        currentHistoryIndex = currentHistoryIndex! - 1;
      }
    });
  }

String getPreview(Map<String, dynamic> chat) {
  final msgs = chat["messages"] as List<Map<String, String>>;
  final first = msgs.firstWhere(
    (m) => m["sender"] == "user",
    orElse: () => {"text": "Chat"},
  );
  final text = first["text"] ?? "Chat";
  return text.length > 30 ? "${text.substring(0, 30)}..." : text;
}

  @override
  Widget build(BuildContext context) {
    return bg(
      child: Stack(
        children: [

          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        showSidebar ? Icons.close : Icons.menu,
                        color: Colors.green[800],
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() {
                          showSidebar = !showSidebar;
                        });
                      },
                    ),
                    const SizedBox(width: 6),
                    ClipOval(
                      child: Image.asset(
                        'images/logo.jpeg',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Jungle Chat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: newChat,
                  icon: Icon(Icons.add_comment_outlined, color: Colors.green[700], size: 18),
                  label: Text(
                    "Nouveau chat",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 70, bottom: 75),
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.green[200]),
                        const SizedBox(height: 12),
                        Text(
                          "Démarrer une conversation!",
                          style: TextStyle(color: Colors.green[300], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg["sender"] == "user";
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.green[700]
                                : Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(15),
                              topRight: const Radius.circular(15),
                              bottomLeft: Radius.circular(isUser ? 15 : 0),
                              bottomRight: Radius.circular(isUser ? 0 : 15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
child: msg["text"]!.startsWith("📎")
    ? Row(
        children: [
          Icon(
            msg["text"]!.toLowerCase().endsWith(".png") ||
                    msg["text"]!.toLowerCase().endsWith(".jpg") ||
                    msg["text"]!.toLowerCase().endsWith(".jpeg")
                ? Icons.image
                : Icons.insert_drive_file,
            color: isUser ? Colors.white : Colors.black,
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              msg["text"]!,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      )
    : Text(
        msg["text"]!,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
      ),
                        ),
                      );
                    },
                  ),
          ),

          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                 IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.green[700]),
                  onPressed: pickFile,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      onSubmitted: (val) {
                        if (val.isNotEmpty) sendMessage(val);
                      },
                      decoration: const InputDecoration(
                        hintText: "Écrire un message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.green[700],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        sendMessage(controller.text);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: showSidebar ? 0 : -260,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(3, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.history, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              "Chat History",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            newChat();
                            setState(() => showSidebar = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white54),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "New Chat",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: chatHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, color: Colors.grey[300], size: 45),
                                const SizedBox(height: 10),
                                Text("No history yet", style: TextStyle(color: Colors.grey[400])),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: chatHistory.length,
                            itemBuilder: (context, index) {
                              final reversedIndex = chatHistory.length - 1 - index;
                              final isActive = currentHistoryIndex == reversedIndex;

                              return Dismissible(
                                key: Key("chat_$reversedIndex"),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => deleteHistory(reversedIndex),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  color: Colors.red[100],
                                  child: const Icon(Icons.delete, color: Colors.red),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green[50] : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isActive
                                        ? Border.all(color: Colors.green.shade300, width: 1)
                                        : null,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isActive ? Colors.green[400] : Colors.green[100],
                                      radius: 18,
                                      child: Text(
                                        "${chatHistory.length - index}",
                                        style: TextStyle(
                                          color: isActive ? Colors.white : Colors.green[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      getPreview(chatHistory[reversedIndex]),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                        color: isActive ? Colors.green[800] : Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      "${chatHistory[reversedIndex].length} messages",
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                    onTap: () => loadHistory(reversedIndex),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Swipe left to delete a chat",
                      style: TextStyle(color: Colors.grey[400], fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (showSidebar)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => showSidebar = false),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
        ],
      ),
    );
  }
}