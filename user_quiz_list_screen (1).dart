import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'quiz_attempt_screen.dart';
import 'dart:math';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('quizzes');
  List<Map<String, dynamic>> quizzes = [];
  bool isLoading = true;

  final List<Color> lightColors = [
    Colors.orange.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.amber.shade100,
    Colors.indigo.shade100,
  ];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  void _fetchQuizzes() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> loadedQuizzes = [];

        data.forEach((key, value) {
          loadedQuizzes.add({
            'id': key,
            'title': value['title'],
            'description': value['description'],
            'color': lightColors[_random.nextInt(lightColors.length)],
          });
        });

        setState(() {
          quizzes = loadedQuizzes;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quiz List",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Matching theme
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : quizzes.isEmpty
                ? const Center(
                    child: Text(
                      "No quizzes available",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.only(bottom: 15),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          tileColor: quizzes[index]['color'],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Text(
                            quizzes[index]['title'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              quizzes[index]['description'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.deepPurple,
                            size: 30,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizAttemptScreen(
                                  quizId: quizzes[index]['id'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
