import 'package:app/database/services/localdbservice.dart';
import 'package:app/pages/detailedrestaurantpage.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final db = await LocalServices.getDatabase();
                  final accounts = await db.accountDao.findAllAccounts();
                  if (accounts.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  } else {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return SafeArea(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Container(
                                      width: 36,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: accounts.length,
                                        itemBuilder: (context, index) {
                                          final account = accounts[index];

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.12),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(12),
                                                      bottomLeft: Radius.circular(12),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context, account);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            account.email,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .displayMedium
                                                                ?.copyWith(
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            account.userName,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .displaySmall
                                                                ?.copyWith(
                                                                  color: Colors.grey.shade600,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    final db =
                                                        await LocalServices.getDatabase();
                                                    await db.accountDao
                                                        .removeAccount(account);

                                                    final currentUser =
                                                        AuthService().currentUser;

                                                    if (currentUser != null &&
                                                        currentUser.uid == account.id) {
                                                      await AuthService().signOut();
                                                    }

                                                    setState(() {
                                                      accounts.removeAt(index);
                                                    });

                                                    if (accounts.isEmpty) {
                                                      Navigator.pop(context);
                                                      Navigator.pushReplacementNamed(
                                                        context,
                                                        "/signup",
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 56,
                                                    height: 64,
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius: const BorderRadius.only(
                                                        topRight: Radius.circular(12),
                                                        bottomRight: Radius.circular(12),
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            shadowColor:Color.fromARGB(255, 221, 133, 2),
                                            elevation: 8,
                                          ),
                                          child: Text(
                                            "Hızlı giriş olmadan devam et",
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                    .then((selectedAccount) async {
                      if (selectedAccount != null) {
                        try {
                          await AuthService().signIn(
                            email: selectedAccount.email,
                            password: selectedAccount.password,
                          );
                          Navigator.pushReplacementNamed(context, "/home");
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "E-postanız ya da şifreniz hatalı! Lütfen, tekrar deneyiniz.",
                              ),
                            ),
                          );
                        }
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      }
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePageHeader extends StatelessWidget {
  const _WelcomePageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("images/loginheader.png"),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bir sonraki favori yemeğini bul!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Kişiselleştirilmiş yorumlar ve puanlar ile sana, sana yakın olan en iyi restorantları getiriyoruz.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: const Color.fromARGB(255, 32, 32, 32),
            ),
          ),
        ],
      ),
    );
  }
}
