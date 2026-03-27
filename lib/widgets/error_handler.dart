import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

/// Handles API errors globally: shows a SnackBar and logs out on token expiry.
void handleApiError(BuildContext context, Object error) {
  if (error is TokenExpiredException) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expirée. Veuillez vous reconnecter.'),
        backgroundColor: Colors.orange,
      ),
    );
    context.read<AuthService>().logout();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.red,
      ),
    );
  }
}
