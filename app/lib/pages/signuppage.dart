import 'package:app/functions/additionalfunc.dart';
import 'package:app/global/universaltheme.dart';
import 'package:app/pages/loginpage.dart';
import 'package:app/services/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomTabState = Provider.of<BottomTabState>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _SignupHeaderPage(),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Takma-ad",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: "Takma-ad gir",
                      hintStyle: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.normal,
                          ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.from(
                            alpha: 1,
                            red: 1,
                            green: 0.451,
                            blue: 0,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "E-posta",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "E-posta gir",
                      hintStyle: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.normal,
                          ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF7300)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Şifre",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Şifre gir",
                      hintStyle: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.normal,
                          ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF7300)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7300),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    try {
                      await AuthService().createAccount(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      try {
                        if (await signInAndSaveAccount(
                          email: _emailController.text,
                          password: _passwordController.text,
                          username: _usernameController.text,
                        )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Hesabınızı hızlı girişe kayıt ettik. Bundan sonra doğrudan hızlı giriş ile girebilirsiniz.",
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Hızlı girişe hesabı saklarken hata ile karşılaştık!",
                              ),
                            ),
                          );
                        }
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
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Hesap oluştururken yaparken bir hata ile karşılaştık!",
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Hesap Oluştur",
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bir hesabın var mı?",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      "Giriş Yap",
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: const Color(0xFFFF7300)),
                    ),
                  ),
                  Text(
                    "ya da",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      bottomTabState.setTab(0);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        "/home",
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Devam Et",
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: const Color(0xFFFF7300)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupHeaderPage extends StatelessWidget {
  const _SignupHeaderPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.only(top: 90),
          height: 120,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: AssetImage("images/image_logo.png"),
            ),
          ),
          child: Text(
            "Nerede Yiyelim?",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Sana yakın en iyi restoranları bulmayı sağlıyoruz!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: const Color.fromARGB(255, 32, 32, 32),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
