import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController carModel = TextEditingController();
  TextEditingController carColor = TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

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
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    } else if (!RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(value)) {
      return 'Enter a valid 11-digit phone number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String originalPassword) {
    // Validation for password confirmation
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    } else if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateCarModel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Car model is required';
    }
    return null;
  }

  String? validateCarColor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Car color is required';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    confirmPasswordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Signup",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: firstName,
                        validator: validateFirstName,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          label: Text("First Name"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: lastName,
                        validator: validateLastName,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          label: Text("Last Name"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: email,
                        validator: validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.email),
                          label: Text("Email"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: phone,
                        validator: validatePhone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.phone),
                          label: Text("Phone Number"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: carModel,
                        validator: validateCarModel,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.car_rental),
                          label: Text("Car Model"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: carColor,
                        validator: validateCarColor,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.color_lens_rounded),
                          label: Text("Car Color"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: password,
                        validator: validatePassword,
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
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: confirmPassword,
                        validator: (value) =>
                            validateConfirmPassword(value, password.text),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: confirmPasswordVisible,
                        decoration: InputDecoration(
                          label: const Text("Confirm Password"),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  confirmPasswordVisible =
                                      !confirmPasswordVisible;
                                });
                              },
                              icon: Icon(confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off)),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            errorMessage = null;
                          });

                          if (_formKey.currentState?.validate() ?? false) {
                            isLoading = true;
                            setState(() {});
                            print("Form is Valid");
                            // Do signup logic
                            try {
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: email.text,
                                password: password.text,
                              );
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(credential.user!.uid)
                                  .set({
                                    'firstName': firstName.text,
                                    'lastName': lastName.text,
                                    'phone': phone.text,
                                    'type': 'driver',
                                    'carModel': carModel.text,
                                    'carColor': carColor.text
                                  })
                                  .then((value) => print("Driver Added"))
                                  .catchError((error) =>
                                      print("Failed to add user: $error"));
                              // await credential.user!.sendEmailVerification();
                              await FirebaseAuth.instance.signOut();
                              isLoading = false;
                              setState(() {});
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.rightSlide,
                                title: 'Success',
                                desc:
                                    'Your account has been created successfully',
                                btnOkOnPress: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/login', (route) => false);
                                },
                              )..show();
                            } on FirebaseAuthException catch (e) {
                              isLoading = false;
                              setState(() {});
                              if (e.code == 'weak-password') {
                                setState(() {
                                  errorMessage =
                                      "The password provided is too weak.";
                                });
                                print('The password provided is too weak.');
                              } else if (e.code == 'email-already-in-use') {
                                print(
                                    'The account already exists for this email.');
                                setState(() {
                                  errorMessage =
                                      "An account already exists for this email.";
                                });
                              }
                            } catch (e) {
                              print(e);
                            }
                          }
                        },
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account"),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.popAndPushNamed(context, '/login');
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false);
                            },
                            child: Text(
                              "  Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
              )),
            ),
    );
  }
}
