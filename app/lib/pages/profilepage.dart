import 'package:app/pages/loginpage.dart';
import 'package:app/pages/reviewpage.dart';
import 'package:app/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController(text: user?.email ?? "");
    _passwordController = TextEditingController();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          _nicknameController.text = doc['nickname'] ?? "";
        });
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF7300);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profilim",
          style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 50, color: primaryColor),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildProfileField("Nickname", _nicknameController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildProfileField("E-mail", _emailController, Icons.email_outlined),
              const SizedBox(height: 20),
              _buildProfileField(
                "Şifre",
                _passwordController,
                Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () async {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _updateProfile,
                  child: Text(
                    "Bilgileri Güncelle",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
// Yorum butonu
               SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  // review sayfasına gönderme
                 onPressed:(){ Navigator.push(
                       context,
                        MaterialPageRoute(
                        builder: (context) => ReviewPage(
                              ),
                            ),
                          ); },
                  child: Flexible(
                      child: Text('Yorumlarıma Göz At',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    try{
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context, rootNavigator: true).pushReplacement( 
                        MaterialPageRoute(builder: (_) => const LoginPage()), 
                        );
                    } on StateError catch(e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text("Yönlendirme sırasında hata aldık. Lütfen, uygulamayı baştan başlatın!"))
                      );
                    } on FirebaseAuthException catch(e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text("Hesaptan çıkarken bir hata ile karşılaştık. Lütfen, innternet bağlantınızın olduğuna emin olun ya da uygulamayı yeniden başlatın!"))
                      );
                    }
                  },
                  child: Text(
                    "Çıkış Yap",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (user != null) {
      try {
        if (_nicknameController.text != "") {
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'nickname': _nicknameController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        }
        if (_passwordController.text != ""){
          await AuthService().currentUser?.updatePassword(_passwordController.text);
        }
      } on ArgumentError catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Takma adını değiştirirken bir hata ile karşılaştık!")),
        );
      } on FirebaseAuthException catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parolanı değiştirirken bir hata ile karşılaştık!"))
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil güncellendi!")),
      );
    }
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    const primaryColor = Color(0xFFFF7300);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.black87
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : Icon(Icons.edit_outlined, color: Colors.grey[400], size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
