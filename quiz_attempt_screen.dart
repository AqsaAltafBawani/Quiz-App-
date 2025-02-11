import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'score_screen.dart';

class QuizAttemptScreen extends StatefulWidget {
  final String quizId;

  const QuizAttemptScreen({super.key, required this.quizId});

  @override
  _QuizAttemptScreenState createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('quizzes');
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  void _fetchQuestions() async {
    final snapshot =
        await _database.child(widget.quizId).child('questions').get();
    if (snapshot.exists) {
      final data = snapshot.value as List<dynamic>;
      setState(() {
        questions = data.map((q) {
          return {
            'question': q['question'],
            'options': q['options'],
            'correctAnswer': q['correctAnswer'],
          };
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkAnswer(String selectedOption) {
    final correctAnswerIndex = questions[currentQuestionIndex]['correctAnswer'];
    final options = questions[currentQuestionIndex]['options'];

    if (selectedOption == options[correctAnswerIndex]) {
      setState(() {
        score++;
      });
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreScreen(
            score: score,
            totalQuestions: questions.length,
          ),
        ),
      );
    }
  }

  void _goBack() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attempt Quiz"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.orange], // Stylish gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : questions.isEmpty
                  ? const Text(
                      "No Questions Available",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Q${currentQuestionIndex + 1}: ${questions[currentQuestionIndex]['question']}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ...questions[currentQuestionIndex]['options']
                                .map<Widget>((option) => Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: ElevatedButton(
                                        onPressed: () => _checkAnswer(option),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.deepPurple.shade200,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                        ),
                                        child: Text(
                                          option,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _goBack,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade300,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("Back"),
                                ),
                                ElevatedButton(
                                  onPressed: () => _checkAnswer(''),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Next"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
