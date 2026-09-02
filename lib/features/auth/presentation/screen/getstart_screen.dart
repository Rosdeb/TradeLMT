import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raminups/components/AppText/appText.dart';
import 'package:raminups/core/constants/app_constants.dart';
import '../../../../components/GridentButton/Appbutton.dart';
import '../../../../components/desktop_app/desktop_app_bar.dart';
import '../providers/getStart_providers.dart';
import '../providers/authproviders.dart';
import '../../../home/presentation/providers/dashboard_providers.dart';
import '../../../home/presentation/providers/trade_limit_state.dart';
import '../../../home/presentation/providers/connection_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';

import 'package:shared_preferences/shared_preferences.dart';

class GetstartScreen extends ConsumerStatefulWidget {
  const GetstartScreen({super.key});

  @override
  ConsumerState<GetstartScreen> createState() => _GetstartScreenState();
}

class _GetstartScreenState extends ConsumerState<GetstartScreen> {
  final TextEditingController _loginEmailController = TextEditingController(text: "");
  final TextEditingController _loginPasswordController = TextEditingController(text: "");

  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();

  void _refreshAccountData() {
    ref.invalidate(userProfileProvider);
    ref.invalidate(tradeLimitStateProvider);
    ref.invalidate(brokerConnectionsProvider);
    ref.invalidate(activeTabProvider);
    ref.invalidate(isTradeLimitLockedProvider);
    ref.invalidate(remainingTradesProvider);
    ref.invalidate(tradeLimitCountProvider);
    ref.invalidate(lockDurationProvider);
    ref.invalidate(selectedPlatformsProvider);
  }

  Future<void> _handleSignUp() async {
    try {
      await ref.read(authProvider.notifier).accountSignUp(
        _signupNameController.text,
        _signupEmailController.text,
        _signupPasswordController.text,
      );
      _refreshAccountData();
      if (mounted) {
        context.goNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (ref.read(authProvider)) return;
    try {
      print("Starting login process...");
      await ref.read(authProvider.notifier).login(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
      print("Login successful, checking mounted...");
      _refreshAccountData();
      if (mounted) {
        print("Mounted! Navigating to ${AppPaths.home}");
        context.goNamed(AppRoutes.home);
      } else {
        print("Widget is no longer mounted!");
      }
    } catch (e) {
      print("Login error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(onboardingStepProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const CustomLightTitleBar(),

          Expanded(
            child: Row(
              children: [
                // ==========================================
                // LEFT SIDE: STATIC SPLASH IMAGE PANEL
                // ==========================================
                Image.asset("assets/images/splash_pic.png"),

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
                        child: SelectionArea(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildCurrentStateView(context,currentStep, ref),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStateView(BuildContext context,int step, WidgetRef ref) {
    switch (step) {
      case 0:
        return _buildWelcomeView(ref);
      case 1:
        return _buildLoginView(context,ref);
      case 2:
        return _buildCreateAccountView(ref);
      case 3:
        return _buildForgotPasswordView(ref); // New step added here
      case 4:
        return _buildVerifyPasswordView(ref);
      case 5:
        return _buildNewPasswordView(ref);
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
  Widget _buildLoginView(BuildContext context, WidgetRef ref) {
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

        _buildTextField(label: "Email Address", hint: "Enter your email", icon: Icons.email_outlined, controller: _loginEmailController),
        const SizedBox(height: 16),
        _buildTextField(label: "Password", hint: "••••••••", icon: Icons.lock_outline, isObscure: true, controller: _loginPasswordController,),

        // Forgot Password trigger text
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () =>
            ref.read(onboardingStepProvider.notifier).state = 3,
            style: TextButton.styleFrom(
              enabledMouseCursor: SystemMouseCursors.click, // 👈 hand cursor
            ),
            child: const Text(
              "Forgot Password?",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GradientButton(
            isLoading: ref.watch(authProvider),
            text: "Login",
            onTap: _handleLogin,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("New to the platform? ", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            TextButton(
              style: TextButton.styleFrom(
                enabledMouseCursor: SystemMouseCursors.click, // 👈 hand cursor
              ),
              onPressed: () => ref.read(onboardingStepProvider.notifier).state = 2,
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
          onPressed: () => ref.read(onboardingStepProvider.notifier).state = 1,
        ),
        const SizedBox(height: 10),
        const Text(
          "Join TradeLMT",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text("Start securing your risk parameters today.", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 24),

        _buildTextField(label: "Full Name", hint: "John Doe", icon: Icons.person_outline, controller: _signupNameController),
        const SizedBox(height: 16),
        _buildTextField(label: "Email Address", hint: "john@example.com", icon: Icons.email_outlined, controller: _signupEmailController),
        const SizedBox(height: 16),
        _buildTextField(label: "Password", hint: "Create password", icon: Icons.lock_outline, isObscure: true, controller: _signupPasswordController),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GradientButton(
            isLoading: ref.watch(authProvider),
            text: "Create Account",
            onTap: _handleSignUp,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // NEW VIEW 3: FORGOT PASSWORD CARD
  // ==========================================
  Widget _buildForgotPasswordView(WidgetRef ref) {
    return Column(
      key: const ValueKey('forgot_password'),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => ref.read(onboardingStepProvider.notifier).state = 1, // Go back to login
        ),
        const SizedBox(height: 10),
        const Text(
          "Reset Password",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your registered email address below to recover your account.",
          style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),

        _buildTextField(
          label: "Email Address",
          hint: "Enter your email",
          icon: Icons.email_outlined,
        ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GradientButton(
            text: "Send Reset Link",
            onTap: () {
              ref.read(onboardingStepProvider.notifier).state = 4;
              // Trigger your password reset system logic here
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyPasswordView(WidgetRef ref) {
    return Column(
      key: const ValueKey('verify_otp'), // Updated key for animation uniqueness
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => ref.read(onboardingStepProvider.notifier).state = 3, // Go back to Forgot Password email entry
        ),
        const SizedBox(height: 10),
        const Text(
          "Verify Code",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter the 6-digit verification code sent to your email address.",
          style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),

        // Single text field for simple OTP entry as requested earlier
        _buildTextField(
          label: "Verification Code",
          hint: "Enter 6-digit code",
          icon: Icons.domain_verification_outlined,
        ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GradientButton(
            text: "Verify Code",
            onTap: () {
              ref.read(onboardingStepProvider.notifier).state = 5;
              // Verify OTP logic, then move to update password step or home workspace
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordView(WidgetRef ref) {
    return Column(
      key: const ValueKey('set_new_password'), // Updated key for animation uniqueness
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => ref.read(onboardingStepProvider.notifier).state = 3, // Go back to Forgot Password email entry
        ),
        const SizedBox(height: 10),
        const Text(
          "New Password",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          "Create a secure password for your workspace environment.",
          style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 32),

        // Single text field for simple OTP entry as requested earlier
        _buildTextField(
          label: "New Password",
          hint: "••••••••",
          icon: Icons.lock_outline,
          isObscure: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Confirm New Password",
          hint: "••••••••",
          icon: Icons.lock_clock_outlined,
          isObscure: true,
        ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: GradientButton(
            text: "Update Password",
            onTap: () {
              // After updating password successfully, return to sign in workflow
              ref.read(onboardingStepProvider.notifier).state = 1;
            },
          ),
        ),
      ],
    );
  }

  // Reusable text input field element
  Widget _buildTextField({required String label, required String hint, required IconData icon, bool isObscure = false, TextEditingController? controller}) {
    bool obscureText = isObscure;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
                suffixIcon: isObscure
                    ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      )
                    : null,
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
      },
    );
  }
}