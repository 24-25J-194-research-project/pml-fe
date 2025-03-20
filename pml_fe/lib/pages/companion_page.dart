import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

class CompanionPage extends StatefulWidget {
  @override
  _CompanionPageState createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _chatHistory = [];
  String _response = "How are you feeling today?";
  late stt.SpeechToText _speech;
  FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _historyMode = false;

  @override
  void initState() {
    super.initState();
    _initializeCompanion();
    _speech = stt.SpeechToText();

    _loadSettings().then((_) {
      if (_historyMode) {
        _loadConversationHistory();
      }
    });
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _historyMode = prefs.getBool('historyMode') ?? false;
    });
  }

  void _initializeCompanion() async {
    try {
      await ApiService.createCompanion("user1");
    } catch (e) {
      print("Error: $e");
    }
  }

  void _loadConversationHistory() async {
    try {
      final response = await ApiService.getCompanionHistory("user1");
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
      String reply = await ApiService.interactWithCompanion("user1", message);
      setState(() {
        _response = reply;
        if (_historyMode) {
          _chatHistory.add({"role": "assistant", "text": reply});
          _scrollToBottom();
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
        backgroundColor: Colors.blue.shade50,
        elevation: 0,
        title: Text(
          "Your Virtual Companion",
          style: GoogleFonts.bebasNeue(fontSize: 30, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              context.push('/settings').then((_) => _loadSettings());
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/sky.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
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

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  isUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  Padding(
                                    padding: EdgeInsets.only(right: 8, top: 8),
                                    child: Icon(
                                      Icons.sentiment_very_satisfied, // 😊 Icon
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),

                                Flexible(
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
                                        color:
                                            isUser
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),

                                if (isUser)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8, top: 4),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                              ],
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
                decoration: InputDecoration(labelText: "Ask me anything..."),
              ),

              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _sendMessage,
                      child: Text("SEND TO COMPANION"),
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
      ),
    );
  }
}
