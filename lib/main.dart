import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      //FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setUserProperty(name: 'name', value: 'toto');
    FirebaseAnalytics.instance.setUserProperty(name: 'age', value: '42');

    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      for (final element in event.docs) {
        print(element.data());
      }
    });
  }

  void _incrementCounter() {
    FirebaseAnalytics.instance.logEvent(
      name: 'button_clicked',
      parameters: {
        'counter': _counter,
      },
    );

    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Oups, une erreur est survenue'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs;
          if (documents == null || documents.isEmpty) {
            return const Center(
              child: Text('Oups, liste vide'),
            );
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data();
              if(data == null) return const SizedBox();
              final userData = data as Map<String, dynamic>;
              return ListTile(
                title: Text(userData['name'] as String),
                subtitle: Text(userData['age'].toString()),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _onFirestoreButtonTap,
            tooltip: 'Firestore',
            child: const Icon(Icons.supervised_user_circle),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onFirestoreButtonTap() async {
    /// Création d'un document

    try {
      final documentReference = await FirebaseFirestore.instance.collection('users').add({
        'name': 'Ousmane',
        'age': 54,
      });

      print('Document généré : ${documentReference.id}');
    } catch (error) {
      print('Oups, erreur: $error');
    }

    /// Modification d'un document
    //
    // try {
    //   const userId = '3SLiErOWJsBCNlG6bQn0';
    //   await FirebaseFirestore.instance.collection('users').doc(userId).update({
    //     'age': '30',
    //   });
    // } catch(error) {
    //   print('Oups, erreur: $error');
    // }

    /// Suppression d'un document

    // try {
    //   const userId = '1tPhBXjw9cmE3TDohyQ1';
    //   await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    // } catch(error) {
    //   print('Oups, erreur: $error');
    // }
  }
}
