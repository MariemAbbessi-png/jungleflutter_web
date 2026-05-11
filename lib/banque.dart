import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

const _dark = Color(0xFF0F3D2E);
const _green = Color(0xFF1F7A5C);
const _lightGreen = Color(0xFFF0FAF5);
const _accent = Color(0xFF4CAF50);

class BanquePage extends StatefulWidget {
  const BanquePage({super.key});

  @override
  State<BanquePage> createState() => _BanquePageState();
}

class _BanquePageState extends State<BanquePage>
    with SingleTickerProviderStateMixin {
  Map? _banque;
  bool _isLoading = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    loadBanque();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> loadBanque() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
          Uri.parse("http://localhost:3000/banque/list"));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body is List ? body : (body['banques'] ?? []);
        setState(() => _banque = list.isNotEmpty ? list[0] : null);
        _animCtrl.forward();
      }
    } catch (e) {
      debugPrint("Erreur banque: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openEditDialog() {
    showDialog(
      context: context,
      builder: (_) => _BanqueEditDialog(
        banque: _banque!,
        onSaved: () => loadBanque(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : _banque == null
              ? _emptyState()
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildPage(),
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_outlined,
              size: 70, color: Colors.white24),
          const SizedBox(height: 16),
          const Text("Aucune banque trouvée",
              style: TextStyle(color: Colors.white54, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildPage() {
    final b = _banque!;
    final logoUrl = "http://localhost:3000/uploads/${b['image']}";

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A2E1F),
            Color(0xFF0F3D2E),
            Color(0xFF1A5C3A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80, right: -80,
            child: _circle(260),
          ),
          Positioned(
            bottom: -100, left: -60,
            child: _circle(300),
          ),
          Positioned(
            top: 180, left: 260,
            child: _circle(100),
          ),

          const Positioned(top: 60, left: 180, child: _Star(size: 18)),
          const Positioned(bottom: 100, right: 200, child: _Star(size: 12)),
          const Positioned(top: 250, right: 100, child: _Star(size: 9)),

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white70, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _accent.withOpacity(0.6), width: 2),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          logoUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 44,
                            height: 44,
                            color: _green,
                            child: const Icon(Icons.account_balance,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Text(
                      b['nom'] ?? 'Banque',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    ElevatedButton.icon(
                      onPressed: _openEditDialog,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text("Modifier"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: _accent.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Votre banque partenaire",
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              b['nom'] ?? '—',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 14),

                            Text(
                              "Solution bancaire rapide,\nsimple et sécurisée.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),

                            _infoRow(Icons.email_outlined,
                                b['email'] ?? '—'),
                            const SizedBox(height: 10),
                            _infoRow(Icons.phone_outlined,
                                b['num_tel'] ?? b['telephone'] ?? '—'),
                            const SizedBox(height: 10),
                            _infoRow(Icons.location_on_outlined,
                                b['adresse'] ?? '—'),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 5,
                        child: Center(
                          child: _BankCard(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildStats(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("01", "Transactions sécurisées",
              "Toutes vos opérations protégées"),
          _vDivider(),
          _statItem("02", "Système simple",
              "Interface intuitive et rapide"),
          _vDivider(),
          _statItem("10%", "Cashback",
              "Sur chaque achat chez nos partenaires"),
          _vDivider(),
          Row(children: [
            SizedBox(
              width: 72,
              height: 34,
              child: Stack(
                children: List.generate(
                  3,
                  (i) => Positioned(
                    left: i * 20.0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF0F3D2E), width: 2),
                        color: [_green, _accent, _dark][i],
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Utilisateurs actifs",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text("En croissance",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11)),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _statItem(String num, String title, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(num,
              style: const TextStyle(
                  color: _accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(sub,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ],
      );

  Widget _vDivider() => Container(
        width: 1, height: 44,
        color: Colors.white.withOpacity(0.1),
      );

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _accent, size: 15),
          ),
          const SizedBox(width: 10),
          Text(text,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75), fontSize: 14)),
        ],
      );

  Widget _circle(double size) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.04),
        ),
      );
}

class _BankCard extends StatefulWidget {
  const _BankCard();

  @override
  State<_BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<_BankCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _ctrl;
  late Animation<double> _rotY;
  late Animation<double> _rotX;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _rotY = Tween<double>(begin: -0.10, end: 0.05)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _rotX = Tween<double>(begin: 0.04, end: -0.03)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) { setState(() => _hovered = true); _ctrl.forward(); },
      onExit: (_) { setState(() => _hovered = false); _ctrl.reverse(); },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_rotY.value)
            ..rotateX(_rotX.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(_hovered ? -28 : -18, _hovered ? 18 : 12),
                child: Transform.rotate(
                  angle: _hovered ? -0.07 : -0.04,
                  child: _cardWidget(isBack: true),
                ),
              ),
              _cardWidget(isBack: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardWidget({required bool isBack}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 320,
      height: 195,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isBack
              ? [const Color(0xFF2E8B57), const Color(0xFF1A5C3A)]
              : [const Color(0xFF0F3D2E), const Color(0xFF1F7A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_hovered ? 0.45 : 0.25),
            blurRadius: _hovered ? 36 : 18,
            offset: const Offset(0, 12),
          ),
          if (_hovered && !isBack)
            BoxShadow(
              color: _accent.withOpacity(0.25),
              blurRadius: 28,
              spreadRadius: 1,
            ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isBack ? 0.04 : 0.12),
        ),
      ),
      child: isBack
          ? null
          : ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'images/carte.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackCard(),
              ),
            ),
    );
  }

  Widget _fallbackCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 28,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Text("1234  5678  9012  345",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardLabel("Titulaire", "JUNGLE CARD"),
              _cardLabel("Expire", "06/28"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardLabel(String top, String bot) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(top,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 9)),
          Text(bot,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      );
}

class _Star extends StatelessWidget {
  final double size;
  const _Star({required this.size});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _StarPainter(),
      );
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, size.height / 2);
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final tx = c.dx + math.cos(a) * size.width / 2;
      final ty = c.dy + math.sin(a) * size.height / 2;
      final r = size.width * 0.14;
      final lx = c.dx + math.cos(a - math.pi / 4) * r;
      final ly = c.dy + math.sin(a - math.pi / 4) * r;
      final rx = c.dx + math.cos(a + math.pi / 4) * r;
      final ry = c.dy + math.sin(a + math.pi / 4) * r;
      if (i == 0) path.moveTo(lx, ly);
      path.lineTo(tx, ty);
      path.lineTo(rx, ry);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BanqueEditDialog extends StatefulWidget {
  final Map banque;
  final VoidCallback onSaved;
  const _BanqueEditDialog({required this.banque, required this.onSaved});

  @override
  State<_BanqueEditDialog> createState() => _BanqueEditDialogState();
}

class _BanqueEditDialogState extends State<_BanqueEditDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  late final TextEditingController _nom;
  late final TextEditingController _adresse;
  late final TextEditingController _tel;
  late final TextEditingController _email;
  late final TextEditingController _mdp;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final b = widget.banque;
    _nom = TextEditingController(text: b['nom'] ?? '');
    _adresse = TextEditingController(text: b['adresse'] ?? '');
    _tel = TextEditingController(text: b['num_tel'] ?? b['telephone'] ?? '');
    _email = TextEditingController(text: b['email'] ?? '');
    _mdp = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [_nom, _adresse, _tel, _email, _mdp]) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await http.put(
        Uri.parse("http://localhost:3000/banque/update/${widget.banque['_id']}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": _nom.text.trim(),
          "adresse": _adresse.text.trim(),
          "num_tel": _tel.text.trim(),
          "email": _email.text.trim(),
          if (_mdp.text.isNotEmpty) "motdp": _mdp.text,
        }),
      );
      final body = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200) {
        Navigator.of(context).pop();
        widget.onSaved();
      } else {
        setState(() => _error = body['message'] ?? "Erreur serveur");
      }
    } catch (e) {
      setState(() => _error = "Impossible de contacter le serveur");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _lightGreen,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.account_balance_outlined,
                      color: _dark),
                ),
                const SizedBox(width: 12),
                const Text("Modifier la banque",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _dark)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ]),

              const SizedBox(height: 20),

              _ff("Nom", _nom,
                  validator: (v) => v!.isEmpty ? "Requis" : null),
              const SizedBox(height: 12),
              _ff("Adresse", _adresse),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _ff("Téléphone", _tel,
                    keyboardType: TextInputType.phone)),
                const SizedBox(width: 12),
                Expanded(child: _ff("Email", _email,
                    keyboardType: TextInputType.emailAddress)),
              ]),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mot de passe (laisser vide = inchangé)",
                      style: TextStyle(
                          color: _dark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _mdp,
                    obscureText: _obscure,
                    style: const TextStyle(color: _dark, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _lightGreen,
                      hintText: "••••••••",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: _dark, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                        style: const TextStyle(color: Colors.red))),
                  ]),
                ),
              ],

              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler",
                      style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("Enregistrer"),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ff(String label, TextEditingController ctrl,
      {TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _dark, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: _dark, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: _lightGreen,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _dark, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}