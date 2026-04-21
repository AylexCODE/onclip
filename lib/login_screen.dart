import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackBar(e.message ?? 'Sign in failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user?.uid)
          .set({"uid": userCredential.user?.uid, "name": _nameController.text});
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackBar(e.message ?? 'Sign up failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginAnon() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnackBar(e.message ?? 'Login up failed');
    }finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              // Add this transitionBuilder for the sliding effect
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Slide in from right (Offset 1.0) to center (Offset 0.0)
                final inAnimation = Tween<Offset>(
                  begin: const Offset(-1, 0.0),
                  end: const Offset(0.0, 0.0),
                ).animate(animation);

                // Slide out to the left
                final outAnimation = Tween<Offset>(
                  begin: const Offset(1, 0.0),
                  end: const Offset(0.0, 0.0),
                ).animate(animation);

                return SlideTransition(
                  position: child.key == const ValueKey('login_form')
                      ? inAnimation
                      : outAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _isLoading
                  ? const CircularProgressIndicator(
                      key: ValueKey('loader'),
                      color: Colors.white,
                    )
                  : ClipRRect(
                      key: ValueKey(
                        _isSignUp ? 'signup_form' : 'login_form',
                      ), // Unique keys are critical!
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: SingleChildScrollView(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 15,
                                        sigmaY: 15,
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.85,
                                        padding: const EdgeInsets.all(25),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.cloud_circle,
                                              size: 80,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              _isSignUp
                                                  ? "Create Account"
                                                  : "Cloud Clipboard",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (_isSignUp)
                                              const SizedBox(height: 30),
                                            if (_isSignUp)
                                             TextField(
                                              controller: _nameController,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              cursorColor: Colors.white,
                                              decoration: InputDecoration(
                                                hintStyle: const TextStyle(
                                                  color: Colors.white60,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  color: Colors.white70,
                                                ),
                                                labelText: "Name",
                                                labelStyle: const TextStyle(
                                                  color: Colors.white70,
                                                ),

                                                // 2. Color of the label when the field IS selected (floating at the top)
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                filled: true,
                                                fillColor: Colors.white
                                                    .withValues(alpha: 0.1),
                                                // 1. Border when the field is NOT selected
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                Colors.white30,
                                                            width: 1.0,
                                                          ),
                                                    ),

                                                // 2. Border when the user is typing (active)
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.white,
                                                            width: 2.0,
                                                          ), // Brighter/Thicker
                                                    ),

                                                // 3. The fallback border
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            TextField(
                                              controller: _emailController,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              cursorColor: Colors.white,
                                              decoration: InputDecoration(
                                                hintStyle: const TextStyle(
                                                  color: Colors.white60,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.email_outlined,
                                                  color: Colors.white70,
                                                ),
                                                labelText: "Email",
                                                labelStyle: const TextStyle(
                                                  color: Colors.white70,
                                                ),

                                                // 2. Color of the label when the field IS selected (floating at the top)
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                filled: true,
                                                fillColor: Colors.white
                                                    .withValues(alpha: 0.1),
                                                // 1. Border when the field is NOT selected
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                Colors.white30,
                                                            width: 1.0,
                                                          ),
                                                    ),

                                                // 2. Border when the user is typing (active)
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.white,
                                                            width: 2.0,
                                                          ), // Brighter/Thicker
                                                    ),

                                                // 3. The fallback border
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            TextField(
                                              controller: _passwordController,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                              cursorColor: Colors.white,
                                              obscureText: _obscureText,
                                              decoration: InputDecoration(
                                                hintStyle: const TextStyle(
                                                  color: Colors.white60,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.lock_outline,
                                                  color: Colors.white70,
                                                ),
                                                labelText: "Password",
                                                labelStyle: const TextStyle(
                                                  color: Colors.white70,
                                                ),

                                                // 2. Color of the label when the field IS selected (floating at the top)
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                filled: true,
                                                fillColor: Colors.white
                                                    .withValues(alpha: 0.1),
                                                // 1. Border when the field is NOT selected
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                Colors.white30,
                                                            width: 1.0,
                                                          ),
                                                    ),

                                                // 2. Border when the user is typing (active)
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Colors.white,
                                                            width: 2.0,
                                                          ), // Brighter/Thicker
                                                    ),

                                                // 3. The fallback border
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 25),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: () => _isSignUp
                                                    ? _signUp()
                                                    : _signIn(),

                                                child: Text(
                                                  _isSignUp
                                                      ? "GET STARTED"
                                                      : "SIGN IN",
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            TextButton(
                                              onPressed: () => setState(
                                                () => _isSignUp = !_isSignUp,
                                              ),
                                              child: Text(
                                                _isSignUp
                                                    ? "Already have an account? Login"
                                                    : "New? Create Account",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                              color: Colors.white24,
                                            ),
                                            TextButton(
                                              onPressed: () => _loginAnon(),
                                              child: const Text(
                                                "Browse Anonymously",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      cursorColor: Colors.white,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
