import 'package:flutter/material.dart';

import 'package:fittracker_source/Screens/active_screen/journal/journal_screen.dart';
import 'package:fittracker_source/Screens/initial_screen/welcome_screen.dart';
import 'package:fittracker_source/services/loading_flow_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isProcessing = true;
  Map<String, dynamic>? _userProfile;
  String _processingMessage = 'Syncing your profile...';

  @override
  void initState() {
    super.initState();
    _runLoadingFlow();
  }

  Future<void> _runLoadingFlow() async {
    try {
      await _updateMessage('Syncing your profile...');
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateMessage('Validating saved data...');
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateMessage('Calculating your nutrition targets...');
      final result = await LoadingFlowService.run();

      if (!mounted) return;
      if (!result.isSuccess) {
        setState(() {
          _isProcessing = false;
          _processingMessage = result.error ?? 'Unknown error';
        });
        return;
      }

      setState(() {
        _userProfile = result.profile;
        _isProcessing = false;
        _processingMessage = 'Ready';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _processingMessage = 'Error processing data: $e';
      });
    }
  }

  Future<void> _updateMessage(String message) async {
    if (!mounted) return;
    setState(() => _processingMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F5F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                if (_isProcessing)
                  _LoadingCard(message: _processingMessage)
                else if (_userProfile == null)
                  _ErrorCard(message: _processingMessage)
                else
                  _SuccessCard(profile: _userProfile!),
                const SizedBox(height: 30),
                const Text(
                  'There is no 1-size-fits-all diet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomPaint(
                    painter: _ChartPainter(
                      userWeight: (_userProfile?['weight'] as num?)?.toDouble(),
                      targetWeight: (_userProfile?['targetWeight'] as num?)?.toDouble(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'FitTracker finds what works for you to reach your personal goals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 40),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F5F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'Assets/Images/imagePage9.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: (_isProcessing || _userProfile == null)
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const JournalScreen()),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProcessing ? Colors.grey : Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Start Your Journey',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String message;

  const _LoadingCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Restart Setup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _SuccessCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Hello ${profile['name'] ?? 'there'}! 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your personalized nutrition plan is ready',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                title: 'BMI',
                value: '${profile['bmi']?.toStringAsFixed(1) ?? 'N/A'}',
                icon: '📊',
                background: Colors.blue.shade100,
              ),
              _StatCard(
                title: 'Daily Calories',
                value: '${profile['dailyCalories'] ?? 'N/A'}',
                icon: '🔥',
                background: Colors.orange.shade100,
              ),
              _StatCard(
                title: 'Protein Target',
                value: '${profile['macroTargets']?['protein'] ?? 'N/A'}g',
                icon: '💪',
                background: Colors.green.shade100,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final Color background;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final double? userWeight;
  final double? targetWeight;

  _ChartPainter({required this.userWeight, required this.targetWeight});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()..color = Colors.black87;
    final targetPaint = Paint()..color = Colors.orange.shade400;

    final start = Offset(size.width * 0.2, size.height * 0.7);
    final end = Offset(size.width * 0.8, size.height * 0.3);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.15, end.dx, end.dy);

    canvas.drawPath(path, linePaint);
    canvas.drawCircle(start, 8, pointPaint);
    canvas.drawCircle(end, 8, targetPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: userWeight != null ? '${userWeight!.toStringAsFixed(1)} kg' : 'Current',
      style: const TextStyle(color: Colors.black87, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(start.dx - 24, start.dy + 12));

    textPainter.text = TextSpan(
      text: targetWeight != null ? '${targetWeight!.toStringAsFixed(1)} kg' : 'Goal',
      style: const TextStyle(color: Colors.black87, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(end.dx - 18, end.dy - 28));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
