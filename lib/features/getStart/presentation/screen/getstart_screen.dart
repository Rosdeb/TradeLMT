import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raminups/components/AppText/appText.dart';
import '../../../../components/GridentButton/Appbutton.dart';
import '../providers/getStart_providers.dart';

// Import the step provider created in Step 1
// (Assuming it's in the same file or imported explicitly)

class GetstartScreen extends ConsumerWidget {
  const GetstartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the current active UI panel layout index dynamically
    final currentStep = ref.watch(onboardingStepProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // ==========================================
          // LEFT SIDE: STATIC SPLASH IMAGE PANEL
          // ==========================================
         Image.asset("assets/images/splash_pic.png",),


          // ==========================================
          // RIGHT SIDE: DYNAMIC WORKFLOW PANEL
          // ==========================================
          Expanded(
            flex: 10,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  // Wrap everything inside a SelectionArea for excellent desktop mouse behavior
                  child: SelectionArea(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      // Swaps components automatically when step changes
                      child: _buildCurrentStateView(currentStep, ref),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Decides which interactive layout configuration to paint
  Widget _buildCurrentStateView(int step, WidgetRef ref) {
    switch (step) {
      case 0:
        return _buildWelcomeView(ref);
      case 1:
        return _buildLoginView(ref);
      case 2:
        return _buildCreateAccountView(ref);
      default:
        return _buildWelcomeView(ref);
    }
  }

  // ==========================================
  // VIEW 0: WELCOME CARD
  // ==========================================
  Widget _buildWelcomeView(WidgetRef ref) {
    return Column(
      key: const ValueKey('welcome'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome to ",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black, height: 1.2),
        ),
        const SizedBox(height: 8),
        Image.asset(
          "assets/icons/app_logo.png",
          height: 40,
          width: 100,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 24),
        const Text(
          "Master Your Discipline",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.2, letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        Text(
          "Connect your trading APIs simultaneously. Define strict execution guardrails, track your metrics across platforms, and automate locks to permanently eliminate overtrading.",
          style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 48),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 220,
            height: 54,
            child: GradientButton(
              text: "Get Start",
              onTap: () {
                // Update Riverpod state instead of calling setState
                ref.read(onboardingStepProvider.notifier).state = 1;
              },
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 1: LOGIN CARD
  // ==========================================
  Widget _buildLoginView(WidgetRef ref) {
    return Column(
      key: const ValueKey('login'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sign In",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text("Access your TradeLMT execution workspace.", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 32),

        _buildTextField(label: "Email Address", hint: "Enter your email", icon: Icons.email_outlined),
        const SizedBox(height: 16),
        _buildTextField(label: "Password", hint: "••••••••", icon: Icons.lock_outline, isObscure: true),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GradientButton(
            text: "Login",
            onTap: () {
              // Authentication logic execution path goes here
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("New to the platform? ", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            TextButton(
              onPressed: () => ref.read(onboardingStepProvider.notifier).state = 2, // Route state to register
              child: const Text("Create an account", style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
            )
          ],
        )
      ],
    );
  }

  // ==========================================
  // VIEW 2: CREATE ACCOUNT CARD
  // ==========================================
  Widget _buildCreateAccountView(WidgetRef ref) {
    return Column(
      key: const ValueKey('register'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => ref.read(onboardingStepProvider.notifier).state = 1, // Route back to login
        ),
        const SizedBox(height: 10),
        const Text(
          "Join TradeLMT",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text("Start securing your risk parameters today.", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 24),

        _buildTextField(label: "Full Name", hint: "John Doe", icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(label: "Email Address", hint: "john@example.com", icon: Icons.email_outlined),
        const SizedBox(height: 16),
        _buildTextField(label: "Password", hint: "Create password", icon: Icons.lock_outline, isObscure: true),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GradientButton(
            text: "Create Account",
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // Reusable text input field element
  Widget _buildTextField({required String label, required String hint, required IconData icon, bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          obscureText: isObscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }
}