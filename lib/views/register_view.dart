import 'package:flutter/material.dart';
import 'package:flutter_primeiro_app/constants/routes.dart';
import 'package:flutter_primeiro_app/firebase_options.dart';
import 'package:flutter_primeiro_app/services/auth/auth_exceptions.dart';
import 'package:flutter_primeiro_app/services/auth/auth_service.dart';
import 'package:flutter_primeiro_app/utilities/decoration/text_form_field_decoration.dart';
import 'package:flutter_primeiro_app/utilities/dialogs/error_dialog.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(children: [
                      // TextField(
                      //   controller: _email,
                      //   enableSuggestions: false,
                      //   autocorrect: false,
                      //   keyboardType: TextInputType.emailAddress,
                      //   // ignore: prefer_const_constructors
                      //   decoration: InputDecoration(
                      //     hintText: "Enter your email here",
                      //   ),
                      // ),
                      // TextField(
                      //   controller: _password,
                      //   enableSuggestions: false,
                      //   autocorrect: false,
                      //   obscureText: true,
                      //   // ignore: prefer_const_constructors
                      //   decoration: InputDecoration(
                      //     hintText: "Enter your password here",
                      //   ),
                      // ),
                      buildTextFormFieldEmail(_email),
                      buildTextFormFieldPassword(_password),
                      TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                  
                          try {
                            await AuthService.firebase().createUser(
                              email: email,
                              password: password,
                            );
                            await AuthService.firebase().sendEmailVerification();
                            Navigator.of(context).pushNamed(verifyEmailRoute);
                          } on WeekPasswordAuthException {
                            await showErrorDialog(context, "Weak password");
                          } on EmailAlreadyInUseAuthException {
                            await showErrorDialog(context, "Email already in use");
                          } on InvalidEmailAuthException {
                            await showErrorDialog(
                                context, "This is an invalid email address");
                          } on GenericAuthException {
                            await showErrorDialog(context, "Registration error");
                          }
                        },
                        child: const Text("Register"),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                loginRoute, (Route<dynamic> route) => false);
                          },
                          child: const Text("Already registered? Login here!"))
                    ]),
                );
              default:
                return const Text("Loading...");
            }
          },
        ));
  }
}
