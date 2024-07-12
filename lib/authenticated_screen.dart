import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  print('[onBackgroundMessage] We received a backgroundMessage: ${message.notification?.title}');
}

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
    _initNotifications();
  }

  void _initNotifications() async {
    final notificationsSettings = await FirebaseMessaging.instance.requestPermission();
    final status = notificationsSettings.authorizationStatus;
    if (status != AuthorizationStatus.authorized) {
      print('User declined or has not accepted permission');
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();
    print('User FCM token: $token');

    final userId = FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'notificationToken': token,
      });
    } catch (error) {
      print('Errro writting on Firestore: $error');
    }

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      print('[onMessage] RemoteMessage: ${remoteMessage.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      final title = remoteMessage.notification?.title;
      final data = remoteMessage.data;

      if (data.keys.contains('article_id')) {
        final articleId = data['article_id'];

        /// Navigate to the article detail screen
      }

      print('[onMessageOpenedApp] Got notification with title: $title');
    });
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
        Exception('Impossible to logout 2'),
        stacktrace,
        fatal: true,
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
