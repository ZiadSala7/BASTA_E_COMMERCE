# 📱 Flutter Authentication & User Flow Guide
**Target Audience:** Mobile Developers (Flutter/Dart)
**Base URL:** `https://your-api-domain.com/api/users` 

This document outlines how to integrate the Node.js backend authentication into the Flutter app. The backend uses **Stateless JWT Authentication**.

---

## 🏗️ 1. Global Setup & Best Practices

### A. Token Storage
Do **NOT** store the JWT in `shared_preferences` as it is not encrypted. Use the `flutter_secure_storage` package to store the token securely.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Save token
await storage.write(key: 'jwt_token', value: token);

// Read token
String? token = await storage.read(key: 'jwt_token');