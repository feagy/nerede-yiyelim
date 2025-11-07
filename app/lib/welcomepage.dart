import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState () => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _WelcomePageHeader(),
            const _WelcomePageSection(),
            const SizedBox(height: 80),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.mail_outlined, size: 20),
                label: const Text("Continue with mail"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 115, 0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // HERE LOGIN PAGE AND SIGN UP PAGE PAGES
                onPressed: ()=> {}, 
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _WelcomePageHeader extends StatelessWidget {
  const _WelcomePageHeader();


  @override
  Widget build(BuildContext context){
    return  Container(
      height: 300,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("images/loginheader.png")
        )
      ),
    );
  }

}

class _WelcomePageSection extends StatelessWidget {
  const _WelcomePageSection();


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const  EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Discover Your Next Favorite Meal",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 32,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          Text("Discover personalized restaurant recommendations based on your location and preferences. Find the perfect place for every occasion.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: const Color.fromARGB(255, 32, 32, 32),
              fontSize: 16
            ),
          ),
        ],
      ),
    );
  }
}
