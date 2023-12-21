import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Sqflite_Queries.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String? errorMessage;
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-]+@eng\.asu\.edu\.eg$').hasMatch(value)) {
      return 'Enter a valid email address with the domain @eng.asu.edu.eg';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text(
          "Login",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ?  Center(
              child: CircularProgressIndicator(
              color: Colors.blueGrey[700],
            ))
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          child: Image.asset("images/download.png"),
                        ),
                        TextFormField(
                          validator: validateEmail,
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            label: Text("Email"),
                            suffixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: validatePassword,
                          controller: password,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: passwordVisible,
                          decoration: InputDecoration(
                            label: const Text("Password"),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                                icon: Icon(passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off)),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        ),
                        const SizedBox(height: 20),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          onPressed: () async {
                            setState(() {
                              errorMessage = null;
                            });
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
                                isLoading = true;
                                setState(() {});
                                final credential = await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: email.text,
                                        password: password.text);
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(credential.user!.uid)
                                    .get();
                                final userData = userDoc.data();
                                String type = userData!['type'];
                                if (type.compareTo("driver") == 0) {
                                  print("Driver#############");
                                  String firstName = userData['firstName'];
                                  String lastName = userData['lastName'];
                                  String emailDB = email.text;
                                  String phone = userData['phone'];
                                  String ID = credential.user!.uid;

                                  await insertUser(ID, firstName, lastName, phone, emailDB);
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                } else {
                                  print("User#############");
                                  setState(() {
                                    isLoading = false;
                                    errorMessage = 'This account has been registered as a rider';
                                  });
                                  await FirebaseAuth.instance.signOut();
                                }

                                // if (credential.user!.emailVerified) {
                                //   Navigator.pushReplacementNamed(
                                //       context, '/home');
                                // } else {
                                //   isLoading = false;
                                //   setState(() {});
                                //   AwesomeDialog(
                                //     context: context,
                                //     dialogType: DialogType.error,
                                //     animType: AnimType.rightSlide,
                                //     title: 'Unverified Account',
                                //     desc:
                                //         'Please check your email to verify your account',
                                //     btnOkOnPress: () {},
                                //   )..show();
                                // }
                              } on FirebaseAuthException catch (e) {
                                isLoading = false;
                                setState(() {});
                                if (e.code == 'user-not-found') {
                                  setState(() {
                                    errorMessage = 'User not found';
                                  });
                                  print('No user found for that email.');
                                } else if (e.code == 'wrong-password') {
                                  setState(() {
                                    errorMessage = 'Incorrect password';
                                  });
                                  print(
                                      'Wrong password provided for that user.');
                                } else {
                                  setState(() {
                                    errorMessage =
                                        'Account is not found or incorrect password';
                                    print(isLoading);
                                    print(e.code);
                                  });
                                }
                              }
                            }
                          },
                          color: Colors.blueGrey[700],
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            MaterialButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup_s');
                              },
                              child: Text(
                                "Signup here",
                                style: TextStyle(
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                            )
                          ],
                        ),
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
