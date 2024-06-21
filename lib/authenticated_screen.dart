import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class AuthenticatedScreen extends StatefulWidget {
  const AuthenticatedScreen({super.key});

  @override
  State<AuthenticatedScreen> createState() => _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;
    FirebaseCrashlytics.instance.setUserIdentifier(currentUserId);
    FirebaseAnalytics.instance.setUserId(id: currentUserId);
  }

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
              child: const Text('Force crash'),
              onPressed: () => _forceCrash(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Known bug'),
              onPressed: () => _customCrashReport(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Log Out'),
              onPressed: () => _onLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  void _forceCrash() {
    throw Exception('Forced crach');
  }

  void _customCrashReport() async {
    try {
      throw Exception('Known bug');
    } catch (e, stacktrace) {
      await FirebaseCrashlytics.instance.recordError(
        Exception('Impossible to logout'),
        stacktrace,
      );
    }
  }

  void _onLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (error) {
      print('FirebaseAuthException: $error');
    } catch (error) {
      print('error: $error');
    }
  }
}
