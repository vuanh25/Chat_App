import 'dart:io';
import 'dart:developer';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/helper/dialog.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  handleGoogleClick() {
    Dialogs.showProgressBar(context, 'Signing in...');
    signInWithGoogle().then((user) async {
      Navigator.pop(context);

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\nsignInWithGoogle: ${e.toString()}');
      Dialogs.showSnackbar(context, 'Something went wrong! (Check Internet!)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to App Chat'),
      ),
      body: Stack(children: [
        Column(
          children: [
            Positioned(
              child: Padding(
                padding: const EdgeInsets.all(90),
                child: Center(child: Image.asset('images/icon.png')),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 73, 46, 77),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: () {
                handleGoogleClick();
              },
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'images/google.png',
                  width: 50,
                  height: 50,
                ),
              ),
              label: RichText(
                text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 19),
                    children: [
                      TextSpan(text: 'Sign In with '),
                      TextSpan(
                          text: 'Google',
                          style: TextStyle(fontWeight: FontWeight.w500))
                    ]),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
