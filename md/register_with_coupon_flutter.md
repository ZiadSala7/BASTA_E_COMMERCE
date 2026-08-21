# Flutter: Register with Coupon Code

This document outlines the implementation of a user registration flow that includes an optional (or required) coupon/referral code field in a Flutter application.

## 1. UI Implementation

The UI requires standard registration fields along with an additional text field for the coupon code.

```dart
import 'package:flutter/material.dart';

class RegisterWithCouponScreen extends StatefulWidget {
  @override
  _RegisterWithCouponScreenState createState() => _RegisterWithCouponScreenState();
}

class _RegisterWithCouponScreenState extends State<RegisterWithCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _couponController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // TODO: Call your API here
      final email = _emailController.text;
      final password = _passwordController.text;
      final coupon = _couponController.text; // Can be empty

      try {
        await ApiService.registerUser(
          email: email,
          password: password,
          couponCode: coupon.isNotEmpty ? coupon : null,
        );
        // Handle success (navigate to home or login)
      } catch (e) {
        // Handle error (show snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password too short' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _couponController,
                decoration: InputDecoration(
                  labelText: 'Coupon Code (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white) 
                    : Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 2. API Integration

When making the backend request, include the coupon code in the payload. Here is an example using the `http` package.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.yourdomain.com';

  static Future<void> registerUser({
    required String email,
    required String password,
    String? couponCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        if (couponCode != null) 'coupon_code': couponCode,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // Decode error message from backend if possible
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to register');
    }
  }
}
```

## 3. Validating the Coupon Code (Optional)

If you want to validate the coupon code *before* the user submits the registration form (e.g., to show a green checkmark or an "Invalid code" error), you can add an API call triggered by an `onChanged` delay or an "Apply" button next to the coupon text field.

### Adding an "Apply" Button inline
```dart
Row(
  children: [
    Expanded(
      child: TextFormField(
        controller: _couponController,
        decoration: InputDecoration(labelText: 'Coupon Code'),
      ),
    ),
    TextButton(
      onPressed: () => _validateCoupon(_couponController.text),
      child: Text('Apply'),
    )
  ],
)
```

## Best Practices
- **Security:** Never validate a coupon code purely on the client-side. The backend must always perform the final validation during the registration request.
- **User Feedback:** Clearly indicate whether the coupon was applied successfully or if it is invalid/expired.
- **Optionality:** Usually, coupon codes are optional. Make sure your UI and API treat it as a nullable field unless it's a closed beta requiring an invite code.
