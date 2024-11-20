import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_services.dart';
import '../../login/presentation/ui/widget/custom_email_field.dart';
import '../../login/presentation/ui/widget/custom_password_field.dart';


// Provider for managing login state
final loginProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Reset error messages
    setState(() {
      _emailErrorMessage = null;
      _passwordErrorMessage = null;
    });

    if (email.isEmpty) {
      setState(() {
        _emailErrorMessage = 'Email field is empty';
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _passwordErrorMessage = 'Password field is empty';
      });
      return;
    }

    ref.read(loginProvider.notifier).state = true;

    final result = await AuthService.login(email, password);

    ref.read(loginProvider.notifier).state = false;

    setState(() {
      if (result == 'Email not found') {
        _emailErrorMessage = 'Email is incorrect';
      } else if (result == 'Incorrect password') {
        _passwordErrorMessage = 'Password is incorrect';
      } else if (result == 'success') {
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result!)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60.0),
              const Center(
                child: Text(
                  'Welcome Back,',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PlaypenSans',
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Text(
                  'Please enter your login credentials.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[700],
                    fontFamily: 'PlaypenSans',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40.0),
              // Email field
              CustomEmailField(
                controller: _emailController,
                errorText: _emailErrorMessage,
              ),
              const SizedBox(height: 20.0),
              // Password field
              CustomPasswordField(
                controller: _passwordController,
                isObscure: _isObscure,
                toggleVisibility: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
                errorText: _passwordErrorMessage,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
