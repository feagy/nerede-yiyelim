import 'package:app/database/services/localdbservice.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text("Hesap ile Devam Et"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 115, 0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final db =  await LocalServices.getDatabase();
                  final accounts = await db.accountDao.findAllAccounts();
                  if (accounts.isEmpty) {
                    Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignupPage()),);
                  } else {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.7, // %70
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// LİSTE
                                Flexible(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    shrinkWrap: true,
                                    itemCount: accounts.length,
                                    itemBuilder: (context, index) {
                                      final account = accounts[index];

                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context, account);
                                                  },
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(12),
                                                    bottomLeft: Radius.circular(12),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          account.email,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          account.userName,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  final db = await LocalServices.getDatabase();
                                                  await db.accountDao.removeAccount(account);
                                                  Navigator.pop(context);

                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("Hesap hızlı erişimden silindi"),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 60,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(12),
                                                      bottomRight: Radius.circular(12),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        "Hızlı giriş olmadan Devam et",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    .then((selectedAccount) async {
                      if (selectedAccount != null) {
                        try{
                          await AuthService().signIn(email: selectedAccount.email, password: selectedAccount.password);
                          Navigator.pushReplacementNamed(context, "/home");
                        } on FirebaseAuthException catch(e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("E-postanız ya da şifreniz hatalı! Lütfen, tekrar deneyiniz.")));
                        }
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      }
                    });
                  }
                }, 
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
          Text("Bir sonraki favori yemeğini bul!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: const Color.fromARGB(255, 0, 0, 0)
            )
          ),
          const SizedBox(height: 8),
          Text("Kişiselleştirilmiş yorumlar ve puanlar ile sana, sana yakın olan en iyi restorantları getiriyoruz.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: const Color.fromARGB(255, 32, 32, 32),
            )
          ),
        ],
      ),
    );
  }
}