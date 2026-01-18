import 'package:app/database/entity/account.dart';
import 'package:app/database/services/localdbservice.dart';
import 'package:app/functions/additionalfunc.dart';
import 'package:app/global/universaltheme.dart';
import 'package:app/pages/forgetpasswordpage.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/services/authservice.dart';
import 'package:app/notification/notification-test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomTabState = Provider.of<BottomTabState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _LoginHeaderPage(),
                    const _LoginHeadFooterPage(),
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
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: "E-posta gir",
                            hintStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.grey[400],
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
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: "Şifre gir",
                            hintStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.grey[400],
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
                              onPressed: _isLoading ? null : () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgetPasswordPage()),
                          );
                        },
                        child: Text(
                          "Şifreni mi unuttun?",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: _isLoading ? Colors.grey : const Color(0xFFFF7300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading ? Colors.grey[400] : const Color(0xFFFF7300),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : () async {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            if (await signInAndSaveAccount(
                              email: _emailController.text,
                              password: _passwordController.text
                            )) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Hesabınızı hızlı girişe kayıt ettik. Bundan sonra doğrudan hızlı giriş ile girebilirsiniz.")
                                  )
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Hızlı girişe hesabı saklarken hata ile karşılaştık!")
                                  )
                                );
                              }
                            }

                            await NotificationTest.updateLastLogin().catchError((e) {
                              debugPrint('Bildirim planlama hatası: $e');
                            });

                            if (mounted) {
                              Navigator.pushReplacementNamed(context, "/home");
                            }
                          } on FirebaseAuthException catch(e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("E-postanız ya da şifreniz hatalı! Lütfen, tekrar deneyiniz.")
                                )
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "Giriş Yap",
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white
                              )
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hesabın yok mu? ",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Hesap Oluştur",
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: _isLoading ? Colors.grey : const Color(0xFFFF7300),
                            ),
                          ),
                        ),
                        Text(
                          "ya da",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : () {
                            NotificationTest.updateLastLogin().catchError((e) {
                              debugPrint('Bildirim planlama hatası: $e');
                            });
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
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: _isLoading ? Colors.grey : const Color(0xFFFF7300),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF7300),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7300).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF7300),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Giriş yapılıyor...",
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Lütfen bekleyiniz",
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoginHeaderPage extends StatelessWidget {
  const _LoginHeaderPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 90),
      alignment: Alignment.center,
      height: 120,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitHeight,
          image: AssetImage("images/image_logo.png"),
        ),
      ),
      child: Text(
        "Nerede Yiyelim?",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}

class _LoginHeadFooterPage extends StatelessWidget {
  const _LoginHeadFooterPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Text(
        "Hoşgeldin",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          color: const Color.fromARGB(255, 32, 32, 32),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}