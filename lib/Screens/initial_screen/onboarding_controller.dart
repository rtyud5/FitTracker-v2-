import 'package:flutter/material.dart';
import 'package:fittracker_source/core/session/session_store.dart';

import 'loading_screen.dart';
import 'register_screen.dart';
import 'policy_agreement_screen.dart';
import 'step1_user_info.dart';
import 'step2_lifestyle.dart';
import 'step3_dietary_restrictions.dart';
import 'step4_list_dietary_restriction.dart';
import 'step5_health_goal.dart';
import 'step6_ideal_weight.dart';

enum StepScreen {
  step1UserInfo,
  step2Lifestyle,
  step3DietaryRestriction,
  step4DietaryRestrictions,
  policyAgreement,
  register,
  step5HealthGoal,
  step6IdealWeight,
}

class StepProgressForm extends StatefulWidget {
  const StepProgressForm({super.key});

  @override
  State<StepProgressForm> createState() => _StepProgressFormState();
}

class _StepProgressFormState extends State<StepProgressForm> {
  StepScreen currentScreen = StepScreen.step1UserInfo;

  bool _handledInitialArg = false;
  bool _authenticatedFlow = false;
  bool skipStep4 = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledInitialArg) return;
    _handledInitialArg = true;
    _resolveFlow();
  }

  Future<void> _resolveFlow() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final hasRouteUser =
        (args?['userId']?.toString().isNotEmpty == true) ||
        (args?['username']?.toString().isNotEmpty == true);

    final hasSession = await SessionStore.hasActiveSession();
    _authenticatedFlow = hasRouteUser || hasSession;

    final initialStep = args?['initialStep'];
    if (!mounted) return;

    if (initialStep is int) {
      goToCustomStep(initialStep);
    } else {
      setState(() {
        currentScreen = StepScreen.step1UserInfo;
      });
    }
  }

  int _visibleStepIndex(StepScreen screen) {
    switch (screen) {
      case StepScreen.step1UserInfo:
        return 1;
      case StepScreen.step2Lifestyle:
        return 2;
      case StepScreen.step3DietaryRestriction:
        return 3;
      case StepScreen.step4DietaryRestrictions:
        return 4;
      case StepScreen.step5HealthGoal:
        return 5;
      case StepScreen.step6IdealWeight:
        return 6;
      case StepScreen.policyAgreement:
      case StepScreen.register:
        return 0;
    }
  }

  void goToCustomStep(int stepIndex) {
    setState(() {
      if (_authenticatedFlow) {
        // Already authenticated user: skip policy & register
        switch (stepIndex) {
          case 1:
            currentScreen = StepScreen.step1UserInfo;
            break;
          case 2:
            currentScreen = StepScreen.step2Lifestyle;
            break;
          case 3:
            currentScreen = StepScreen.step3DietaryRestriction;
            break;
          case 4:
            currentScreen = StepScreen.step4DietaryRestrictions;
            break;
          case 6:
            currentScreen = StepScreen.step5HealthGoal;
            break;
          case 7:
            currentScreen = StepScreen.step6IdealWeight;
            break;
          default:
            currentScreen = StepScreen.step1UserInfo;
        }
      } else {
        // New user flow: includes policy & register
        switch (stepIndex) {
          case 1:
            currentScreen = StepScreen.step1UserInfo;
            break;
          case 2:
            currentScreen = StepScreen.step2Lifestyle;
            break;
          case 3:
            currentScreen = StepScreen.step3DietaryRestriction;
            break;
          case 4:
            currentScreen = StepScreen.step4DietaryRestrictions;
            break;
          case 5:
            currentScreen = StepScreen.policyAgreement;
            break;
          case 6:
            currentScreen = StepScreen.register;
            break;
          case 7:
            currentScreen = StepScreen.step5HealthGoal;
            break;
          case 8:
            currentScreen = StepScreen.step6IdealWeight;
            break;
          default:
            currentScreen = StepScreen.step1UserInfo;
        }
      }
    });
  }

  void goToNextStep() {
    setState(() {
      switch (currentScreen) {
        case StepScreen.step1UserInfo:
          currentScreen = StepScreen.step2Lifestyle;
          break;

        case StepScreen.step2Lifestyle:
          currentScreen = StepScreen.step3DietaryRestriction;
          break;

        case StepScreen.step3DietaryRestriction:
          if (skipStep4) {
            currentScreen = _authenticatedFlow
                ? StepScreen.step5HealthGoal
                : StepScreen.policyAgreement;
          } else {
            currentScreen = StepScreen.step4DietaryRestrictions;
          }
          break;

        case StepScreen.step4DietaryRestrictions:
          currentScreen = _authenticatedFlow
              ? StepScreen.step5HealthGoal
              : StepScreen.policyAgreement;
          break;

        case StepScreen.policyAgreement:
          currentScreen = StepScreen.register;
          break;

        case StepScreen.register:
          // After successful registration, user is now authenticated
          _authenticatedFlow = true;
          currentScreen = StepScreen.step5HealthGoal;
          break;

        case StepScreen.step5HealthGoal:
          currentScreen = StepScreen.step6IdealWeight;
          break;

        case StepScreen.step6IdealWeight:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoadingScreen()),
          );
          break;
      }
    });
  }

  void goToPreviousStep() {
    setState(() {
      switch (currentScreen) {
        case StepScreen.step1UserInfo:
          Navigator.pop(context);
          break;

        case StepScreen.step2Lifestyle:
          currentScreen = StepScreen.step1UserInfo;
          break;

        case StepScreen.step3DietaryRestriction:
          currentScreen = StepScreen.step2Lifestyle;
          break;

        case StepScreen.step4DietaryRestrictions:
          currentScreen = StepScreen.step3DietaryRestriction;
          break;

        case StepScreen.policyAgreement:
          currentScreen = skipStep4
              ? StepScreen.step3DietaryRestriction
              : StepScreen.step4DietaryRestrictions;
          break;

        case StepScreen.register:
          currentScreen = StepScreen.policyAgreement;
          break;

        case StepScreen.step5HealthGoal:
          if (_authenticatedFlow) {
            // If user already registered/logged in, go back to dietary step
            currentScreen = skipStep4
                ? StepScreen.step3DietaryRestriction
                : StepScreen.step4DietaryRestrictions;
          } else {
            currentScreen = StepScreen.register;
          }
          break;

        case StepScreen.step6IdealWeight:
          currentScreen = StepScreen.step5HealthGoal;
          break;
      }
    });
  }

  void handleStep3Decision(bool skip) {
    skipStep4 = skip;
  }

  Widget _buildProgressBar() {
    if (currentScreen == StepScreen.policyAgreement ||
        currentScreen == StepScreen.register) {
      return const SizedBox.shrink();
    }

    const totalVisibleSteps = 6;
    final currentStep = _visibleStepIndex(currentScreen);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Row(
        children: List.generate(totalVisibleSteps, (index) {
          final stepNum = index + 1;
          final isCompleted = stepNum < currentStep;
          final isActive = stepNum == currentStep;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isCompleted
                    ? Colors.orange
                    : isActive
                    ? Colors.orange.withAlpha(230)
                    : Colors.grey.shade300,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentScreen) {
      case StepScreen.step1UserInfo:
        return Step1UserInfo(onNext: goToNextStep, onBack: goToPreviousStep);

      case StepScreen.step2Lifestyle:
        return Step2Lifestyle(onNext: goToNextStep, onBack: goToPreviousStep);

      case StepScreen.step3DietaryRestriction:
        return Step3DietaryRestriction(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
          onDecision: handleStep3Decision,
          onSkipToStep: goToCustomStep,
        );

      case StepScreen.step4DietaryRestrictions:
        return Step4ListDietaryRestrictions(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
        );

      case StepScreen.policyAgreement:
        return PolicyAgreementScreen(
          onNext: goToNextStep,
          onPrevious: goToPreviousStep,
        );

      case StepScreen.register:
        return RegisterScreen(
          onNext: goToNextStep,
          onBack: goToPreviousStep,
        );

      case StepScreen.step5HealthGoal:
        return Step5HealthGoal(onNext: goToNextStep, onBack: goToPreviousStep);

      case StepScreen.step6IdealWeight:
        return Step6IdealWeight(
          onNext: goToNextStep,
          onPrevious: goToPreviousStep,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProgressBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildCurrentScreen()),
          ],
        ),
      ),
    );
  }
}
