import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dashboard_screen.dart';

// ─── Shared Design Constants ──────────────────────────────────────────────────
const Color kGold = Color(0xFFE5AC07);
const Color kFieldBg = Color(0x73000000); // black ~45% opacity
const Color kDarkBg = Colors.black;

// ─── Shared Snackbar Helper ───────────────────────────────────────────────────
void showMessage(BuildContext context, String message, {bool success = false}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      content: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: success ? Colors.greenAccent : Colors.redAccent,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (success ? Colors.greenAccent : Colors.redAccent)
                  .withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (success ? Colors.greenAccent : Colors.redAccent)
                    .withOpacity(0.15),
              ),
              child: Icon(
                success ? Icons.check_rounded : Icons.close_rounded,
                color: success ? Colors.greenAccent : Colors.redAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Shared Field Decoration ──────────────────────────────────────────────────
InputDecoration sharedFieldDecoration(
  String hint,
  IconData icon, {
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
    prefixIcon: Icon(icon, color: kGold, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: kFieldBg,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kGold, width: 1.5),
    ),
  );
}

// ==================== LOGIN SCREEN ====================

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signInWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage(context, 'Please fill in all fields.');
      return;
    }

    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await _postLoginCheck(userCredential);
    } on FirebaseAuthException catch (e) {
      showMessage(context, _friendlyAuthError(e.code));
    } catch (e) {
      showMessage(context, 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    setState(() => isLoading = true);
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        await googleSignIn.signOut();
        if (mounted) {
          showMessage(context, 'No account found. Please sign up first.');
        }
        return;
      }

      await _postLoginCheck(userCredential);
    } on FirebaseAuthException catch (e) {
      showMessage(context, _friendlyAuthError(e.code));
    } catch (e) {
      showMessage(context, 'Google login failed. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _postLoginCheck(UserCredential userCredential) async {
    await SessionService.createSession();

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!mounted) return;

    final data = doc.data();
    final twoFAEnabled = data?['twoFactorEnabled'] == true;
    final phone = data?['phone'] as String?;

    showMessage(context, 'Welcome back! Login successful.', success: true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (twoFAEnabled && phone != null && phone.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TwoFactorVerifyScreen(phoneNumber: phone),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: kGold, size: 22),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: kGold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Login to your account',
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),
              const SizedBox(height: 32),

              // Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: kGold,
                decoration: sharedFieldDecoration(
                  'Email Address',
                  Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 14),

              // Password
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: kGold,
                decoration: sharedFieldDecoration(
                  'Password',
                  Icons.lock_outline,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _obscurePassword ? Colors.grey[600] : kGold,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: kGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _signInWithEmail,
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Divider with "or"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[800])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[800])),
                ],
              ),
              const SizedBox(height: 20),

              // Social buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    icon: Icons.facebook,
                    onTap: () => showMessage(
                      context,
                      'Facebook login coming soon!',
                      success: false,
                    ),
                  ),
                  const SizedBox(width: 20),
                  _socialButton(
                    icon: Icons.g_mobiledata,
                    onTap: isLoading ? null : signInWithGoogle,
                  ),
                  const SizedBox(width: 20),
                  _socialButton(
                    icon: Icons.apple,
                    onTap: () =>
                        showMessage(context, 'Apple login coming soon!'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sign up link
              Center(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/signup'),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: kGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kFieldBg,
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Icon(icon, color: kGold, size: 28),
      ),
    );
  }
}

// ==================== FORGOT PASSWORD SCREEN ====================

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: kGold, size: 22),
              ),
              const SizedBox(height: 24),

              const Text(
                'Forgot Password',
                style: TextStyle(
                  color: kGold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Enter your email or phone number\nand we'll send a verification code.",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: kGold,
                keyboardType: TextInputType.emailAddress,
                decoration: sharedFieldDecoration(
                  'Email Address',
                  Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: kGold,
                keyboardType: TextInputType.phone,
                decoration: sharedFieldDecoration(
                  'Phone (e.g. +1234567890)',
                  Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _sendVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Send Verification Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendVerification() async {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (email.isEmpty && phone.isEmpty) {
      showMessage(context, 'Please enter your email or phone number.');
      return;
    }

    setState(() => isLoading = true);

    if (phone.isNotEmpty) {
      await _sendPhoneCode(phone, email);
    } else {
      await _sendEmailCode(email);
    }
  }

  Future<void> _sendPhoneCode(String phoneNumber, String email) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            UserCredential userCredential = await FirebaseAuth.instance
                .signInWithCredential(credential);
            String userEmail = email;
            if (userEmail.isEmpty && userCredential.user != null) {
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .get();
              if (userDoc.exists) userEmail = userDoc.get('email') ?? '';
            }
            if (userEmail.isNotEmpty && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SetNewPasswordScreen(
                    email: userEmail,
                    phoneCredential: credential,
                  ),
                ),
              );
            }
          } catch (e) {
            if (mounted) setState(() => isLoading = false);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() => isLoading = false);
            showMessage(context, 'Verification failed: ${e.message}');
          }
        },
        codeSent: (String vId, int? resendToken) {
          if (mounted) setState(() => isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerifyCodeScreen(
                verificationId: vId,
                contactInfo: phoneNumber,
                isPhone: true,
                email: email,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        showMessage(context, 'Something went wrong. Please try again.');
      }
    }
  }

  Future<void> _sendEmailCode(String email) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => isLoading = false);
        showMessage(context, 'No account found with this email address.');
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => isLoading = false);

      showMessage(
        context,
        'Password reset link sent to $email. Check your inbox.',
        success: true,
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, 'Something went wrong. Please try again.');
    }
  }
}

// ==================== VERIFY CODE SCREEN ====================

class VerifyCodeScreen extends StatefulWidget {
  final String verificationId;
  final String contactInfo;
  final bool isPhone;
  final String email;

  const VerifyCodeScreen({
    required this.verificationId,
    required this.contactInfo,
    required this.isPhone,
    required this.email,
  });

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  int seconds = 60;
  Timer? timer;
  bool isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    codeController.dispose();
    super.dispose();
  }

  void _verifyCode() async {
    if (seconds == 0) {
      showMessage(context, 'Code expired. Please request a new one.');
      return;
    }

    final enteredCode = codeController.text.trim();
    if (enteredCode.isEmpty) {
      showMessage(context, 'Please enter the verification code.');
      return;
    }

    setState(() => isVerifying = true);

    if (widget.isPhone) {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: enteredCode,
        );
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );

        String userEmail = widget.email;
        if (userEmail.isEmpty && userCredential.user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
          if (userDoc.exists) userEmail = userDoc.get('email') ?? '';
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SetNewPasswordScreen(
                email: userEmail,
                phoneCredential: credential,
              ),
            ),
          );
        }
      } catch (e) {
        setState(() => isVerifying = false);
        showMessage(context, 'Invalid code. Please try again.');
      }
    } else {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('password_reset_codes')
            .doc(widget.email)
            .get();

        if (doc.exists &&
            doc.get('code') == enteredCode &&
            doc.get('used') != true) {
          await doc.reference.update({'used': true});
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SetNewPasswordScreen(
                  email: widget.email,
                  phoneCredential: null,
                ),
              ),
            );
          }
        } else {
          setState(() => isVerifying = false);
          showMessage(context, 'Invalid code. Please try again.');
        }
      } catch (e) {
        setState(() => isVerifying = false);
        showMessage(context, 'Something went wrong. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: kGold, size: 22),
              ),
              const SizedBox(height: 24),

              const Text(
                'Verify Code',
                style: TextStyle(
                  color: kGold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'We sent a code to:',
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                widget.contactInfo,
                style: const TextStyle(
                  color: kGold,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: codeController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: kGold,
                keyboardType: TextInputType.number,
                decoration: sharedFieldDecoration(
                  'Enter 6-digit code',
                  Icons.pin_outlined,
                ),
              ),
              const SizedBox(height: 16),

              // Timer
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: seconds > 0 ? kGold : Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    seconds > 0
                        ? 'Code expires in ${seconds}s'
                        : 'Code expired',
                    style: TextStyle(
                      color: seconds > 0 ? Colors.grey[400] : Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Verify Code',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),

              if (seconds == 0) ...[
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: "Didn't receive it? ",
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        children: const [
                          TextSpan(
                            text: 'Request New Code',
                            style: TextStyle(
                              color: kGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SET NEW PASSWORD SCREEN ====================

class SetNewPasswordScreen extends StatefulWidget {
  final String email;
  final PhoneAuthCredential? phoneCredential;

  const SetNewPasswordScreen({required this.email, this.phoneCredential});

  @override
  _SetNewPasswordScreenState createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _updatePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showMessage(context, 'Please fill in all fields.');
      return;
    }
    if (newPassword != confirmPassword) {
      showMessage(context, "Passwords don't match.");
      return;
    }
    if (newPassword.length < 6) {
      showMessage(context, 'Password must be at least 6 characters.');
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null && widget.phoneCredential != null) {
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          widget.phoneCredential!,
        );
        user = userCredential.user;
      }

      if (user != null) {
        await user.updatePassword(newPassword);
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          showMessage(
            context,
            'Password updated successfully! Please login.',
            success: true,
          );
          await Future.delayed(const Duration(milliseconds: 1200));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        }
      } else {
        setState(() => isLoading = false);
        showMessage(
          context,
          'Session expired. Please go back and request a new code.',
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      showMessage(context, 'Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: kGold, size: 22),
              ),
              const SizedBox(height: 24),

              const Text(
                'Set New Password',
                style: TextStyle(
                  color: kGold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email.isNotEmpty
                    ? 'For account: ${widget.email}'
                    : 'Create a strong new password',
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: newPasswordController,
                obscureText: _obscureNew,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: kGold,
                decoration: sharedFieldDecoration(
                  'New Password',
                  Icons.lock_outline,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureNew = !_obscureNew),
                    child: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _obscureNew ? Colors.grey[600] : kGold,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: kGold,
                decoration: sharedFieldDecoration(
                  'Confirm Password',
                  Icons.lock_outline,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _obscureConfirm ? Colors.grey[600] : kGold,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
