import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../utils/star_path.dart';
import '../utils/time_parser.dart';

class InteractiveCookingPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const InteractiveCookingPage({Key? key, required this.recipe})
    : super(key: key);

  @override
  _InteractiveCookingPageState createState() => _InteractiveCookingPageState();
}

class _InteractiveCookingPageState extends State<InteractiveCookingPage> {
  List<bool> _checkedIngredients = [];
  int _currentStepIndex = 0;
  late PageController _pageController;
  late ConfettiController _confettiController;
  String? _timerValue;
  String? _emergencyContactEmail;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _checkedIngredients = List<bool>.filled(
      widget.recipe['ingredients'].length,
      false,
    );

    _loadProgress();
    _loadEmergencyContact();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // ✅ Load emergency contact info from backend
  Future<void> _loadEmergencyContact() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/cooking-assistant/user/health-conditions?username=user1',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _emergencyContactEmail = data['emergencyContactEmail'];
        });
        print("Emergency Contact Email: $_emergencyContactEmail");
      }
    } catch (e) {
      print("Error loading emergency contact: $e");
    }
  }

  // ✅ Load progress from SharedPreferences
  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _currentStepIndex =
        prefs.getInt('${widget.recipe['name']}_currentStep') ?? 0;

    List<String>? savedIngredients = prefs.getStringList(
      '${widget.recipe['name']}_ingredients',
    );

    if (savedIngredients != null &&
        savedIngredients.length == widget.recipe['ingredients'].length) {
      _checkedIngredients =
          savedIngredients.map((value) => value == 'true').toList();
    }

    // ✅ Extract timer value from current step
    // _timerValue = extractTime(
    //   widget.recipe['steps'][_currentStepIndex]['step'],
    // );
    final time = widget.recipe['steps'][_currentStepIndex]['time'];
    _timerValue = time != null ? extractTime(time) : null;

    setState(() {});
    _pageController.jumpToPage(_currentStepIndex);
  }

  // ✅ Save progress to SharedPreferences
  Future<void> _saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      '${widget.recipe['name']}_currentStep',
      _currentStepIndex,
    );
    await prefs.setStringList(
      '${widget.recipe['name']}_ingredients',
      _checkedIngredients.map((value) => value.toString()).toList(),
    );
  }

  // ✅ Handle ingredient checkbox toggle
  void _toggleIngredient(int index) {
    setState(() {
      _checkedIngredients[index] = !_checkedIngredients[index];
    });
    _saveProgress();
  }

  // ✅ Move to next step or trigger confetti
  void _nextStep() {
    if (_currentStepIndex < widget.recipe['steps'].length - 1) {
      setState(() {
        _currentStepIndex++;
        // _timerValue = extractTime(
        //   widget.recipe['steps'][_currentStepIndex]['time'],
        // );
        final time = widget.recipe['steps'][_currentStepIndex]['time'];
        _timerValue = time != null ? extractTime(time) : null;
      });

      _pageController.animateToPage(
        _currentStepIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveProgress();
    } else {
      _showCompletion(); // ✅ Trigger confetti
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        final time = widget.recipe['steps'][_currentStepIndex]['time'];
        _timerValue = time != null ? extractTime(time) : null;
      });

      _pageController.animateToPage(
        _currentStepIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveProgress();
    }
  }

  // ✅ Show confetti on completion
  void _showCompletion() async {
    _confettiController.play();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Congratulations! Your recipe is ready to serve!"),
      ),
    );

    // ✅ Delay the reset to let confetti finish playing
    await Future.delayed(Duration(seconds: 2));

    // ✅ Reset SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('${widget.recipe['name']}_currentStep');
    await prefs.remove('${widget.recipe['name']}_ingredients');

    // ✅ Reset state after confetti finishes
    setState(() {
      _currentStepIndex = 0;
      _checkedIngredients = List<bool>.filled(
        widget.recipe['ingredients'].length,
        false,
      );
      _timerValue = null;

      // ✅ Dispose and recreate ConfettiController
      _confettiController.dispose();
      _confettiController = ConfettiController(
        duration: const Duration(seconds: 3),
      );
    });

    _pageController.jumpToPage(0);
  }

  // ✅ Send emergency email
  void _sendEmergencyEmail() async {
    final serviceId = dotenv.env['SERVICE_ID'];
    final templateId = dotenv.env['TEMPLATE_ID'];
    final publicKey = dotenv.env['PUBLIC_KEY'];

    if (_emergencyContactEmail == null || _emergencyContactEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Emergency contact not set")),
      );
      return;
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'email': _emergencyContactEmail,
            'user': 'Emergency Contact',
            'message': 'Emergency! Please contact the user immediately.',
          },
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Emergency email sent!")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to send email")));
      }
    } catch (e) {
      print('Error sending email: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send email")));
    }
  }

  void _showMeasuringTipsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.5, // Bigger Dialog
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Measuring Tips",
                  style: TextStyle(
                    fontSize: 24, // Larger Font
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // ✅ 2x2 Grid Layout for Measuring Tips
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // 2 columns
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      // ✅ Table Spoon
                      _buildTipTile(
                        "assets/images/tableSpoon.png",
                        "Table Spoon",
                      ),

                      // ✅ Tea Spoon
                      _buildTipTile("assets/images/teaSpoon.png", "Tea Spoon"),

                      // ✅ Electric Scale
                      _buildTipTile(
                        "assets/images/scale.png",
                        "Electric Scale",
                      ),

                      // ✅ Extra Tip
                      _buildTipTile("assets/images/cup.png", " measuring cup"),
                    ],
                  ),
                ),

                SizedBox(height: 12),

                // ✅ Close Button
                SizedBox(
                  width: double.infinity, // Take full width
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Got It !",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Helper Function for Tip Tile
  Widget _buildTipTile(String imagePath, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100, // Bigger tile size
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, size: 40, color: Colors.red);
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.recipe['ingredients'] as List<dynamic>;
    final steps = widget.recipe['steps'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Interactive Cooking"),
        actions: [
          IconButton(
            icon: Icon(Icons.emergency),
            color: Colors.red,
            onPressed: _sendEmergencyEmail, // ✅ Send emergency email
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ✅ Ingredients Section
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Let's check our ingredients",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.info_outline),
                            onPressed: () {
                              _showMeasuringTipsDialog();
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: ingredients.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              title: Text(ingredients[index]),
                              value: _checkedIngredients[index],
                              onChanged: (bool? value) {
                                _toggleIngredient(index);
                              },
                              activeColor: Colors.blue,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // ✅ Steps Section (Carousel)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's go step by step",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: steps.length,
                          itemBuilder: (context, index) {
                            String stepText = steps[index]['step'] ?? '';
                            String? imageUrl = steps[index]['image'];

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.grey[200],
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (imageUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imageUrl,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            progress,
                                          ) {
                                            if (progress == null) return child;
                                            return CircularProgressIndicator();
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(Icons.error, size: 40),
                                        ),
                                      ),
                                    SizedBox(height: 12),
                                    Text(
                                      stepText,
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ✅ Previous Button (Hidden for first step)
                          if (_currentStepIndex > 0)
                            Expanded(
                              flex:
                                  3, // ✅ Make consistent width with Next button
                              child: ElevatedButton(
                                onPressed: _previousStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Previous"),
                              ),
                            ),

                          if (_timerValue != null) ...[
                            const SizedBox(
                              width: 12,
                            ), // ✅ Add consistent spacing
                            Expanded(
                              flex:
                                  4, // ✅ Timer button slightly wider for balance
                              child: ElevatedButton(
                                onPressed: () {
                                  startTimer(_timerValue!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text("Set Timer ($_timerValue)"),
                              ),
                            ),
                          ],

                          const SizedBox(width: 12), // ✅ Add consistent spacing
                          // ✅ Next/Ready to Serve Button
                          Expanded(
                            flex:
                                3, // ✅ Same as Previous button for consistency
                            child: ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _currentStepIndex ==
                                            widget.recipe['steps'].length - 1
                                        ? Colors.green
                                        : Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _currentStepIndex ==
                                        widget.recipe['steps'].length - 1
                                    ? "Ready to Serve"
                                    : "Next",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ Centered Star-Shaped Confetti
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.1,
              shouldLoop: false,
              emissionFrequency: 0.02,
              createParticlePath: (size) => StarPath.create(size.width),
            ),
          ),
        ],
      ),
    );
  }
}
