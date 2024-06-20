import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UnAuthenticatedScreen extends StatefulWidget {
  const UnAuthenticatedScreen({super.key});

  @override
  State<UnAuthenticatedScreen> createState() => _UnAuthenticatedScreenState();
}

class _UnAuthenticatedScreenState extends State<UnAuthenticatedScreen> {
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Je suis PAS authentifié !'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 30,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _pseudoController,
                  decoration: const InputDecoration(
                    hintText: 'Pseudo',
                  ),
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Login'),
                  onPressed: _login,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('SignUp'),
                  onPressed: _signUp,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final pseudo = _pseudoController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    print('Pseudo: $pseudo, email: $email, password: $password');

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      print('FirebaseAuthException: $error');
    } catch (error) {
      print('Error: $error');
    }
  }

  void _signUp() async {
    final pseudo = _pseudoController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    print('Pseudo: $pseudo, email: $email, password: $password');

    try {
      final userCredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredentials.user?.uid;

      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'pseudo': pseudo
        });
      } catch(error) {
        print('Error writting in firestore: $error');
      }


    } on FirebaseAuthException catch (error) {
      print('FirebaseAuthException: $error');
    } catch (error) {
      print('Error: $error');
    }
  }
}
