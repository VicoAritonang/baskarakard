import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class LatihanPage extends StatefulWidget {
  const LatihanPage({super.key});

  @override
  State<LatihanPage> createState() => _LatihanPageState();
}

class _LatihanPageState extends State<LatihanPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool loading = true;
  bool quizCompleted = false;
  bool showAnswer = false;
  bool? isCorrect;

  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Animation controllers for feedback
  late AnimationController _correctAnimationController;
  late Animation<double> _correctAnimation;

  late AnimationController _wrongAnimationController;
  late Animation<double> _wrongAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _correctAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _correctAnimation = CurvedAnimation(
      parent: _correctAnimationController,
      curve: Curves.elasticOut,
    );

    _wrongAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _wrongAnimation =
        Tween<double>(begin: -10.0, end: 10.0).animate(CurvedAnimation(
      parent: _wrongAnimationController,
      curve: Curves.elasticIn,
    ));

    _wrongAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _wrongAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _wrongAnimationController.forward();
      }
    });

    _loadQuestions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _correctAnimationController.dispose();
    _wrongAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      loading = true;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('soal').get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          loading = false;
        });
        return;
      }

      final loadedQuestions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'soal': data['soal'] ?? 'No question available',
          'opsi1': data['opsi1'] ?? '',
          'opsi2': data['opsi2'] ?? '',
          'opsi3': data['opsi3'] ?? '',
          'opsi4': data['opsi4'] ?? '',
          'kunci': data['kunci'] ?? '',
        };
      }).toList();

      // Fisher-Yates shuffle algorithm to randomize questions
      final random = Random();
      for (var i = loadedQuestions.length - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = loadedQuestions[i];
        loadedQuestions[i] = loadedQuestions[j];
        loadedQuestions[j] = temp;
      }

      setState(() {
        questions = loadedQuestions;
        loading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        loading = false;
      });
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkAnswer(String selectedOption) {
    if (showAnswer) return; // Prevent multiple selections

    final currentQuestion = questions[currentQuestionIndex];
    final correctAnswer = currentQuestion['kunci'];

    final correct = selectedOption == correctAnswer;

    setState(() {
      showAnswer = true;
      isCorrect = correct;

      if (correct) {
        score++;
        _correctAnimationController.forward();
      } else {
        _wrongAnimationController.forward();
      }
    });

    // After a delay, move to the next question or show results
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            showAnswer = false;
            isCorrect = null;
          });
          _correctAnimationController.reset();
          _wrongAnimationController.reset();
          _pageController.animateToPage(
            currentQuestionIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          setState(() {
            quizCompleted = true;
          });
        }
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      quizCompleted = false;
      showAnswer = false;
      isCorrect = null;
    });
    _pageController.jumpToPage(0);
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF5F5FF),
            ],
          ),
        ),
        child: loading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Memuat soal latihan...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : quizCompleted
                ? _buildResultScreen()
                : questions.isEmpty
                    ? _buildEmptyQuestionsScreen()
                    : _buildQuizScreen(),
      ),
    );
  }

  Widget _buildEmptyQuestionsScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada soal latihan tersedia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan coba lagi nanti atau hubungi administrator',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadQuestions,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              Text(
                'Soal ${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Questions and options
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Q',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    question['soal'] ?? 'No question',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Pilih jawaban yang benar:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildOptionItem('opsi1', question),
                            _buildOptionItem('opsi2', question),
                            _buildOptionItem('opsi3', question),
                            _buildOptionItem('opsi4', question),
                          ],
                        ),
                      ),
                    ),

                    if (showAnswer) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: AnimatedBuilder(
                          animation:
                              isCorrect! ? _correctAnimation : _wrongAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isCorrect!
                                  ? 1.0 + (_correctAnimation.value * 0.2)
                                  : 1.0,
                              child: Transform.translate(
                                offset: isCorrect!
                                    ? Offset.zero
                                    : Offset(_wrongAnimation.value, 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isCorrect! ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    isCorrect!
                                        ? 'Benar! Kamu hebat!'
                                        : 'Ups, jawabannya adalah: ${question['kunci']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem(String optionKey, Map<String, dynamic> question) {
    final option = question[optionKey] ?? '';
    final isSelected = showAnswer && option == question['kunci'];
    final isWrongSelected =
        showAnswer && isCorrect == false && option == question['kunci'];

    // Define colors based on state
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black87;

    if (showAnswer) {
      if (option == question['kunci']) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
      } else if (isWrongSelected) {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      }
    }

    return GestureDetector(
      onTap: () {
        if (!showAnswer) {
          _checkAnswer(option);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: showAnswer
                      ? (option == question['kunci'])
                          ? Colors.green
                          : Colors.grey.shade200
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: showAnswer
                        ? (option == question['kunci'])
                            ? Colors.green
                            : Colors.grey.shade400
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: showAnswer && option == question['kunci']
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: (showAnswer && option == question['kunci'])
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (score / questions.length) * 100;
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 60 && percentage < 80;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy or medal icon based on score
            Icon(
              isExcellent
                  ? Icons.emoji_events
                  : isGood
                      ? Icons.star
                      : Icons.sentiment_satisfied,
              size: 100,
              color: isExcellent
                  ? Colors.amber
                  : isGood
                      ? Colors.orange
                      : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),

            // Score display
            const Text(
              'Hasil Latihan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '$score/${questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Motivational message
            Text(
              isExcellent
                  ? 'Luar biasa! Kamu sangat menguasai materi ini!'
                  : isGood
                      ? 'Bagus! Kamu cukup menguasai materi ini'
                      : 'Terus semangat belajar, kamu pasti bisa!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Restart button
            ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Mulai Lagi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Return to diary button
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Diary'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
