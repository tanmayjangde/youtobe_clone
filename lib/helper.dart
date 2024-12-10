import 'package:flutter/material.dart';

class Helper {
  static Future<T?> handleRequest<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      debugPrint('Error occurred: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
