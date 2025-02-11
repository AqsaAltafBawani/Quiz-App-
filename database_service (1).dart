import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('quizzes');

  /// Add a new quiz with questions
  Future<void> addQuizWithQuestions(String title, String description,
      List<Map<String, dynamic>> questions) async {
    final newQuizRef = _database.push();
    await newQuizRef.set({
      "title": title,
      "description": description,
      "questions": questions,
    });
  }

  /// Fetch all quizzes
  Stream<List<Map<String, dynamic>>> getQuizzes() {
    return _database.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((entry) {
        return {
          'id': entry.key,
          'title': entry.value['title'],
          'description': entry.value['description'],
          'questions': entry.value['questions'] ?? [],
        };
      }).toList();
    });
  }

  /// Delete a quiz by ID
  Future<void> deleteQuiz(String quizId) async {
    await _database.child(quizId).remove();
  }

  /// Update a quiz title & description
  Future<void> updateQuiz(
      String quizId, String newTitle, String newDescription) async {
    await _database.child(quizId).update({
      "title": newTitle,
      "description": newDescription,
    });
  }

  /// Get quiz questions by quiz ID
  Future<List<Map<String, dynamic>>> getQuizQuestions(String quizId) async {
    final snapshot = await _database.child(quizId).child('questions').get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as List<dynamic>;
    return data.map((question) => Map<String, dynamic>.from(question)).toList();
  }
}
