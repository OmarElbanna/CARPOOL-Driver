import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AccountScreen extends StatefulWidget {
  final Function() updateCallback;

  const AccountScreen({Key? key, required this.updateCallback})
      : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phone = TextEditingController();
  bool passwordVisible = true;
  late User user;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
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

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text(
          "My Account",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('User data not found');
          }
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          firstName.text = userData['firstName'];
          lastName.text = userData['lastName'];
          phone.text = userData['phone'];

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: Image.asset("images/download.png"),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: validateName,
                      controller: firstName,
                      // initialValue: userData['firstName'],
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        label: Text("First Name"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: validateName,
                      controller: lastName,
                      keyboardType: TextInputType.name,
                      // initialValue: userData['lastName'],
                      decoration: const InputDecoration(
                        label: Text("Last Name"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: validatePhone,
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      // initialValue: userData['phone'],
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.phone),
                        label: Text("Phone Number"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // TextFormField(
                    //   initialValue: "123456789",
                    //   keyboardType: TextInputType.visiblePassword,
                    //   obscureText: passwordVisible,
                    //   decoration: InputDecoration(
                    //     label: const Text("Password"),
                    //     suffixIcon: IconButton(
                    //         onPressed: () {
                    //           setState(() {
                    //             passwordVisible = !passwordVisible;
                    //           });
                    //         },
                    //         icon: Icon(passwordVisible
                    //             ? Icons.visibility
                    //             : Icons.visibility_off)),
                    //     border: const OutlineInputBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(5))),
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({
                                'firstName': firstName.text,
                                'lastName': lastName.text,
                                'phone': phone.text
                              })
                              .then((value) => AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.success,
                                    animType: AnimType.rightSlide,
                                    title: 'Success',
                                    desc: 'Successfully updated user account',
                                    btnOkOnPress: () {},
                                  )..show())
                              .catchError((error) => AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    animType: AnimType.rightSlide,
                                    title: 'Error',
                                    desc:
                                        'Something wrong happened, please try again later',
                                    btnOkOnPress: () {},
                                  )..show());
                          widget.updateCallback();
                        }
                      },
                      color: Colors.blueGrey[700],
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
