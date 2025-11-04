import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/*
  TODO: 1.Implement Email, Password inputs; Login and Signup buttons. 2.Impelements firebase_auth
*/
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState () => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const LoginHeaderPage(),
            const LoginHeadFooterPage(),
          ],
        ),
      ),
    );
  }
}

class LoginHeaderPage extends StatelessWidget {

  const LoginHeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 70),
      padding: const EdgeInsets.only(top: 90),
      alignment: Alignment.center,
      height: 120,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitHeight,
          image: AssetImage("images/image_logo.png")
        )
      ),
      child: Text(
        "NeredeYiyelim?",
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 18,
          color: const Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}

class LoginHeadFooterPage extends StatelessWidget {
  const LoginHeadFooterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Text(
        textAlign: TextAlign.center,
        "Welcome!",
        style: GoogleFonts.lato(
          fontSize: 32,
          color: const Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}