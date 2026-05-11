import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dash.dart';

const _green = Color(0xFF5AAA28);
const _dark = Color(0xFF0F3D2E);

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});
  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _mdpCtrl.text.isEmpty) {
      setState(() => _error = "Veuillez remplir tous les champs");
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.post(
        Uri.parse("http://localhost:3000/admin/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mail": _emailCtrl.text.trim(),
          "motdp": _mdpCtrl.text,
        }),
      );
      final body = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        setState(() => _error = body['message'] ?? "Erreur de connexion");
      }
    } catch (e) {
      setState(() => _error = "Impossible de contacter le serveur");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF5AAA28),
                        Color(0xFF2F6B12),
                        Color(0xFF1E4D0A),
                        Color(0xFF0F2E05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(top: -60, right: -60, child: _circle(220)),
                Positioned(bottom: -80, left: -80, child: _circle(260)),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('images/logo.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Jungle",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Bienvenue....",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      const Text(
                        '"Gérez votre application."',
                        style: TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bienvenue — accédez à votre espace admin",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 36),

                  _label("EMAIL"),
                  const SizedBox(height: 8),
                  _field(
                    hint: "vous@exemple.com",
                    controller: _emailCtrl,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  _label("MOT DE PASSE"),
                  const SizedBox(height: 8),
                  _field(
                    hint: "••••••••",
                    controller: _mdpCtrl,
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: _dark, size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      ),
                      child: const Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(color: _green),
                      ),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    _errorBox(_error!),
                  ],

                  const SizedBox(height: 20),

                  _btn(
                    label: "Se connecter",
                    loading: _isLoading,
                    onPressed: _login,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _sendOtp() async {
    if (_emailCtrl.text.isEmpty) {
      setState(() => _error = "Veuillez entrer votre email");
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.post(
        Uri.parse("http://localhost:3000/admin/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mail": _emailCtrl.text.trim()}),
      );
      final body = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(email: _emailCtrl.text.trim()),
          ),
        );
      } else {
        setState(() => _error = body['message'] ?? "Erreur");
      }
    } catch (e) {
      setState(() => _error = "Impossible de contacter le serveur");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      title: "Mot de passe oublié",
      subtitle: "Entrez votre email pour recevoir un code OTP",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("EMAIL"),
          const SizedBox(height: 8),
          _field(
            hint: "vous@exemple.com",
            controller: _emailCtrl,
            icon: Icons.email_outlined,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _errorBox(_error!),
          ],
          const SizedBox(height: 24),
          _btn(label: "Envoyer le code OTP", loading: _isLoading, onPressed: _sendOtp),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("← Retour au login",
                  style: TextStyle(color: _green)),
            ),
          ),
        ],
      ),
    );
  }
}


class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});
  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() { _otpCtrl.dispose(); super.dispose(); }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length != 6) {
      setState(() => _error = "Le code OTP doit contenir 6 chiffres");
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.post(
        Uri.parse("http://localhost:3000/admin/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mail": widget.email,
          "otp": _otpCtrl.text.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: widget.email),
          ),
        );
      } else {
        setState(() => _error = body['message'] ?? "Code incorrect");
      }
    } catch (e) {
      setState(() => _error = "Impossible de contacter le serveur");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      title: "Vérification OTP",
      subtitle: "Code envoyé à ${widget.email}",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("CODE OTP (6 chiffres)"),
          const SizedBox(height: 8),
          _field(
            hint: "123456",
            controller: _otpCtrl,
            icon: Icons.key_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _errorBox(_error!),
          ],
          const SizedBox(height: 24),
          _btn(label: "Vérifier le code", loading: _isLoading, onPressed: _verifyOtp),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("← Retour", style: TextStyle(color: _green)),
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _mdpCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _error;

  @override
  void dispose() {
    _mdpCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_mdpCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      setState(() => _error = "Veuillez remplir tous les champs");
      return;
    }
    if (_mdpCtrl.text != _confirmCtrl.text) {
      setState(() => _error = "Les mots de passe ne correspondent pas");
      return;
    }
    if (_mdpCtrl.text.length < 6) {
      setState(() => _error = "Minimum 6 caractères");
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.post(
        Uri.parse("http://localhost:3000/admin/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mail": widget.email,
          "password": _mdpCtrl.text,
        }),
      );
      final body = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginUI()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mot de passe modifié avec succès !"),
            backgroundColor: _green,
          ),
        );
      } else {
        setState(() => _error = body['message'] ?? "Erreur");
      }
    } catch (e) {
      setState(() => _error = "Impossible de contacter le serveur");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      title: "Nouveau mot de passe",
      subtitle: "Choisissez un mot de passe sécurisé",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("NOUVEAU MOT DE PASSE"),
          const SizedBox(height: 8),
          _field(
            hint: "••••••••",
            controller: _mdpCtrl,
            icon: Icons.lock_outline,
            obscure: _obscure1,
            suffix: IconButton(
              icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility,
                  color: _dark, size: 20),
              onPressed: () => setState(() => _obscure1 = !_obscure1),
            ),
          ),
          const SizedBox(height: 16),
          _label("CONFIRMER LE MOT DE PASSE"),
          const SizedBox(height: 8),
          _field(
            hint: "••••••••",
            controller: _confirmCtrl,
            icon: Icons.lock_outline,
            obscure: _obscure2,
            suffix: IconButton(
              icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility,
                  color: _dark, size: 20),
              onPressed: () => setState(() => _obscure2 = !_obscure2),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _errorBox(_error!),
          ],
          const SizedBox(height: 24),
          _btn(
            label: "Réinitialiser le mot de passe",
            loading: _isLoading,
            onPressed: _reset,
          ),
        ],
      ),
    );
  }
}

class _AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _AuthLayout({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF5AAA28),
                        Color(0xFF2F6B12),
                        Color(0xFF1E4D0A),
                        Color(0xFF0F2E05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(top: -60, right: -60, child: _circle(220)),
                Positioned(bottom: -80, left: -80, child: _circle(260)),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('images/logo.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Jungle",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Bienvenue....",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      const Text(
                        '"Gérez votre application."',
                        style: TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Widget _circle(double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
      ),
    );

Widget _label(String text) => Text(
      text,
      style: const TextStyle(
        color: _dark,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );

Widget _field({
  required String hint,
  required TextEditingController controller,
  bool obscure = false,
  IconData? icon,
  Widget? suffix,
  TextInputType? keyboardType,
  int? maxLength,
}) =>
    TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: _dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        counterText: "",
        prefixIcon: icon != null ? Icon(icon, color: _dark, size: 20) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5FAF5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 2),
        ),
      ),
    );

Widget _errorBox(String msg) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

Widget _btn({
  required String label,
  required bool loading,
  required VoidCallback onPressed,
}) =>
    SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _dark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );