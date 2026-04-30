import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool agreedToTerms = false;

  static const Color goldColor = Color(0xFFE5AC07);
  static const Color fieldColor = Color(0x73000000); // black with 0.45 opacity

  // ─── Beautiful Snackbar ───────────────────────────────────────────────────
  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: Duration(seconds: 3),
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
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
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

  // ─── Firebase error parser ────────────────────────────────────────────────
  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'Email sign-up is currently disabled. Contact support.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  InputDecoration _fieldDecoration(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
      prefixIcon: Icon(icon, color: goldColor, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color.fromARGB(255, 17, 17, 17).withOpacity(0.45),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: goldColor, width: 1.5),
      ),
    );
  }

  Future<void> signUpWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _showMessage('Google sign-in successful!', success: true);
      await Future.delayed(Duration(milliseconds: 800));
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      _showMessage(_parseFirebaseError(e));
    } catch (e) {
      _showMessage('Google sign-in failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: goldColor, size: 22),
              ),
              SizedBox(height: 24),

              Text(
                "Create Account",
                style: TextStyle(
                  color: goldColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Join our AI Adaptive Honeypot",
                style: TextStyle(color: Colors.grey[400], fontSize: 15),
              ),
              SizedBox(height: 32),

              // First Name
              TextField(
                controller: firstNameController,
                style: TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: goldColor,
                decoration: _fieldDecoration(
                  "First Name",
                  Icons.person_outline,
                ),
              ),
              SizedBox(height: 14),

              // Last Name
              TextField(
                controller: lastNameController,
                style: TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: goldColor,
                decoration: _fieldDecoration("Last Name", Icons.person_outline),
              ),
              SizedBox(height: 14),

              // Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: goldColor,
                decoration: _fieldDecoration(
                  "Email Address",
                  Icons.email_outlined,
                ),
              ),
              SizedBox(height: 14),

              // Password
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: goldColor,
                decoration: _fieldDecoration(
                  "Password",
                  Icons.lock_outline,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => obscurePassword = !obscurePassword),
                    child: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: obscurePassword ? Colors.grey[600] : goldColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14),

              // Confirm Password
              TextField(
                controller: confirmController,
                obscureText: obscureConfirm,
                style: TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: goldColor,
                decoration: _fieldDecoration(
                  "Confirm Password",
                  Icons.lock_outline,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => obscureConfirm = !obscureConfirm),
                    child: Icon(
                      obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: obscureConfirm ? Colors.grey[600] : goldColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18),

              // Terms & Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => agreedToTerms = !agreedToTerms),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: agreedToTerms ? goldColor : Colors.transparent,
                        border: Border.all(
                          color: agreedToTerms ? goldColor : Colors.grey[600]!,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: agreedToTerms
                          ? Icon(Icons.check, color: Colors.black, size: 14)
                          : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "I agree to the ",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          // ── Validation ──────────────────────────────────
                          if (firstNameController.text.trim().isEmpty ||
                              lastNameController.text.trim().isEmpty) {
                            _showMessage('Please enter your full name.');
                            return;
                          }
                          if (emailController.text.trim().isEmpty) {
                            _showMessage('Please enter your email address.');
                            return;
                          }
                          if (!agreedToTerms) {
                            _showMessage(
                              'Please agree to the Terms & Conditions.',
                            );
                            return;
                          }
                          if (passwordController.text !=
                              confirmController.text) {
                            _showMessage('Passwords do not match.');
                            return;
                          }
                          if (passwordController.text.length < 6) {
                            _showMessage(
                              'Password must be at least 6 characters.',
                            );
                            return;
                          }

                          setState(() => isLoading = true);
                          try {
                            final userCredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userCredential.user!.uid)
                                .set({
                                  'firstName': firstNameController.text.trim(),
                                  'lastName': lastNameController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            _showMessage(
                              'Account created successfully! Welcome 🎉',
                              success: true,
                            );
                            await Future.delayed(Duration(milliseconds: 1200));
                            if (mounted)
                              Navigator.pushReplacementNamed(context, '/login');
                          } on FirebaseAuthException catch (e) {
                            _showMessage(_parseFirebaseError(e));
                            setState(() => isLoading = false);
                          } catch (e) {
                            _showMessage(
                              'Something went wrong. Please try again.',
                            );
                            setState(() => isLoading = false);
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 28),

              // Already have account
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: goldColor,
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
}
