import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
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
    _timerValue = extractTime(
      widget.recipe['steps'][_currentStepIndex]['step'],
    );

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
        _timerValue = extractTime(
          widget.recipe['steps'][_currentStepIndex]['step'],
        );
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

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.recipe['ingredients'] as List<dynamic>;
    final steps = widget.recipe['steps'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text("Interactive Cooking")),
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
                      Text(
                        "Ingredients",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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

                // ✅ Steps Section (Carousel)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Steps",
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
                            // ✅ Extract step value from map
                            String stepText =
                                steps[index]['step'] ?? 'Step not available';

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.grey[200],
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    stepText,
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          if (_timerValue != null)
                            ElevatedButton(
                              onPressed: () {
                                startTimer(_timerValue!);
                              },
                              child: Text("Set Timer ($_timerValue)"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.all(12),
                              ),
                            ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _nextStep,
                              child: Text(
                                _currentStepIndex == steps.length - 1
                                    ? "Ready to Serve"
                                    : "Next",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _currentStepIndex == steps.length - 1
                                        ? Colors.green
                                        : Colors.blue,
                                padding: EdgeInsets.all(12),
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
