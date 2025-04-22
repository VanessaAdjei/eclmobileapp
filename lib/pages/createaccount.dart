import 'package:eclapp/pages/signinpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'otp.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _termsAgreed = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _signUp(String name, String email, String password, String confirmPassword, String phoneNumber) async {
    email = email.trim();
    password = password.trim();
    confirmPassword = confirmPassword.trim();
    phoneNumber = phoneNumber.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      _showError("All fields are required");
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showError("Please enter a valid email address");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match");
      return;
    }

    bool signUpSuccess = await AuthService.signUp(name, email, password, phoneNumber);

    if (signUpSuccess) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OtpVerificationScreen(email: email)),

      );
    } else {
      _showError("Signup failed. Try again.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                'assets/images/png.png',
                height: 150,
                width: 150,
              ),
              Column(
                children: [
                  const Text(
                    'Welcome to the Ernest Chemist App',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.green),
                  ),
                  const Text(
                    'Sign up to shop our products seamlessly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildTextField('Your name', Icons.person_outline, nameController),
                    const SizedBox(height: 10),
                    _buildTextField('Enter your email', Icons.email_outlined, emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    _buildTextField('Enter your number', Icons.phone, phoneNumberController, keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    _buildPasswordField('Enter your password', Icons.lock_outline, passwordController, _passwordVisible, () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    }),
                    const SizedBox(height: 10),
                    _buildPasswordField('Confirm your password', Icons.lock_outline, confirmPasswordController, _confirmPasswordVisible, () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    }),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAgreed,
                          onChanged: (value) {
                            setState(() {
                              _termsAgreed = value!;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                        Expanded(
                          child: const Text(
                            'By agreeing to the terms and conditions, you are entering into a legally binding contract.',
                            softWrap: true,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: _termsAgreed
                        ? () {
                      String name = nameController.text.trim();
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();
                      String confirmPassword = confirmPasswordController.text.trim();
                      String phoneNumber = phoneNumberController.text.trim();

                      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && phoneNumber.isNotEmpty) {
                        _signUp(name, email, password, confirmPassword, phoneNumber);
                      } else {
                        _showError("All fields are required");
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                child: const Text(
                  'Already Have an account? Login',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green), // Green icon
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green), // Green border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade700), // Darker green focused border
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, IconData icon, TextEditingController controller, bool isVisible, VoidCallback onPressed) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green), // Green icon
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.green), // Green icon
          onPressed: onPressed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green), // Green border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade700), // Darker green focused border
        ),
      ),
    );
  }
}