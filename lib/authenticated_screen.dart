import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticatedScreen extends StatelessWidget {
  const AuthenticatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Je suis authentifié !'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Coucou ${currentUser?.email}',
            ),
            const SizedBox(height: 10),
            Text(
              'ID: ${currentUser?.uid}',
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Log Out'),
              onPressed: () => _onLogout(context),
            )
          ],
        ),
      ),
    );
  }

  void _onLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch(error) {
      print('FirebaseAuthException: $error');
    } catch(error) {
      print('error: $error');
    }
  }
}
