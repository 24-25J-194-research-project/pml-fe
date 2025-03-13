import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class PMLPage extends StatefulWidget {
  @override
  _PMLPageState createState() => _PMLPageState();
}

class _PMLPageState extends State<PMLPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _chatHistory = []; // Stores chat messages
  String _response = "Ask me about cooking!";
  late stt.SpeechToText _speech;
  FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _historyMode = false;

  @override
  void initState() {
    super.initState();
    _initializeAssistant();
    // _loadSettings();
    _speech = stt.SpeechToText();

    _loadSettings().then((_) {
      if (_historyMode) {
        _loadConversationHistory();
      }
    });
  }

  // Load History Mode setting
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _historyMode = prefs.getBool('historyMode') ?? false;
    });
  }

  void _initializeAssistant() async {
    try {
      await ApiService.createAssistant("user1");
    } catch (e) {
      print("Error: $e");
    }
  }

  void _loadConversationHistory() async {
    try {
      final response = await ApiService.getConversationHistory("user1");
      setState(() {
        _chatHistory = List<Map<String, String>>.from(
          response['conversationHistory'].map(
            (item) => {
              "role": item["role"].toString(),
              "text": item["content"].toString(),
            },
          ),
        );
      });

      // ✅ Longer delay ensures full scroll extent is available
      _scrollToBottom();
    } catch (e) {
      print("Error loading conversation history: $e");
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  void _startListening() async {
    bool hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) {
      print("Microphone permission denied");
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print("Status: $status");
          if (status == "notListening") {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print("Error: ${error.errorMsg}");
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 10),
          pauseFor: Duration(seconds: 5),
          localeId: "en_US",
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    String message = _messageController.text;
    setState(() {
      _response = "Thinking...";
      if (_historyMode) {
        _chatHistory.add({"role": "user", "text": message});
      }
    });

    try {
      String reply = await ApiService.interactWithAssistant("user1", message);
      setState(() {
        _response = reply;
        if (_historyMode) {
          _chatHistory.add({"role": "assistant", "text": reply});
          _scrollToBottom(); // ✅ Ensure full scroll after response
        }
      });
    } catch (e) {
      setState(() => _response = "Error: $e");
    }

    _messageController.clear();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _speakResponse() async {
    if (_response.isNotEmpty) {
      await _flutterTts.speak(_response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dementia Cooking Assistant"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              context
                  .push('/settings')
                  .then((_) => _loadSettings()); // Use GoRouter
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child:
                  _historyMode
                      ? ListView.builder(
                        controller: _scrollController,
                        itemCount: _chatHistory.length,
                        itemBuilder: (context, index) {
                          final message = _chatHistory[index];
                          bool isUser = message["role"] == "user";
                          return Align(
                            alignment:
                                isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    isUser
                                        ? Colors.blueAccent
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message["text"]!,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                      : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _response,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: "Ask me something..."),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text("Send"),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: Colors.red,
                  ),
                  onPressed: _startListening,
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.blue),
                  onPressed: _speakResponse,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
