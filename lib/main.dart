import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_primeiro_app/constants/routes.dart';
import 'package:flutter_primeiro_app/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_primeiro_app/services/auth/bloc/auth_event.dart';
import 'package:flutter_primeiro_app/services/auth/bloc/auth_state.dart';
import 'package:flutter_primeiro_app/services/auth/firebase_auth_provider.dart';
import 'package:flutter_primeiro_app/views/login_view.dart';
import 'package:flutter_primeiro_app/views/notes/create_update_note_view.dart';
import 'package:flutter_primeiro_app/views/notes/notes_view.dart';
import 'package:flutter_primeiro_app/views/register_view.dart';
import 'package:flutter_primeiro_app/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
            foregroundColor: Colors.purple,
          ))),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      }));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state){
        if(state is AuthStateLoggedIn){
          return const NotesView();
        }
        else if(state is AuthStateNeedsVerification){
          return const VerifyEmailView();
        }
        else if(state is AuthStateLoggedOut){
          return const LoginView();
        }
        else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      }
    );
  }
}
