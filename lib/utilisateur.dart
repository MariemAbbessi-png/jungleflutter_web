import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const _dark = Color(0xFF0F3D2E);
const _green = Color(0xFF1F7A5C);
const _lightGreen = Color(0xFFF0FAF5);

class utilisateur extends StatefulWidget {
  const utilisateur({super.key});

  @override
  State<utilisateur> createState() => _utilisateurState();
}

class _utilisateurState extends State<utilisateur> {
  List _all = [];
  List _filtered = [];
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUtilisateurs();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_all)
          : _all
              .where((u) =>
                  (u['cin'] ?? '').toString().toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> loadUtilisateurs() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("http://localhost:3000/utilisateur/list"),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['utilisateurs'] as List;
        setState(() {
          _all = list;
          _filtered = List.from(list);
        });
      }
    } catch (e) {
      debugPrint("Erreur: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String cin, String nom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text("Confirmer suppression"),
        ]),
        content: Text("Supprimer l'utilisateur $nom (CIN: $cin) ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await http.delete(
        Uri.parse("http://localhost:3000/utilisateur/deleteu/$cin"),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        _showSnack("Utilisateur supprimé avec succès", _green);
        loadUtilisateurs();
      } else {
        _showSnack(body['message'] ?? "Erreur", Colors.red);
      }
    } catch (e) {
      _showSnack("Impossible de contacter le serveur", Colors.red);
    }
  }

  void _openForm({Map? user}) {
    showDialog(
      context: context,
      builder: (_) => _UserFormDialog(
        user: user,
        onSaved: () => loadUtilisateurs(),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: _dark),
                  style: IconButton.styleFrom(
                    backgroundColor: _lightGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people_outline, color: _dark, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gestion des utilisateurs",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _dark)),
                      Text("Liste et gestion des comptes utilisateurs",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text("Ajouter un utilisateur"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: _dark),
                    decoration: InputDecoration(
                      hintText: "Rechercher par CIN...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon:
                          const Icon(Icons.search, color: _dark, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Colors.grey, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _onSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: _lightGreen,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: _dark, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "${_filtered.length} utilisateur(s)",
                        style: const TextStyle(
                            color: _dark, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: loadUtilisateurs,
                  icon: const Icon(Icons.refresh, color: _dark),
                  style: IconButton.styleFrom(
                    backgroundColor: _lightGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _dark))
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search,
                                  size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                _searchCtrl.text.isEmpty
                                    ? "Aucun utilisateur trouvé"
                                    : "Aucun résultat pour \"${_searchCtrl.text}\"",
                                style:
                                    TextStyle(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.2), 
                                1: FlexColumnWidth(1.5), 
                                2: FlexColumnWidth(1.5), 
                                3: FlexColumnWidth(1.3), 
                                4: FlexColumnWidth(2),   
                                5: FlexColumnWidth(1.2), 
                                6: FlexColumnWidth(1.3), 
                                7: FlexColumnWidth(1.2), 
                              },
                              children: [
                                TableRow(
                                  decoration:
                                      const BoxDecoration(color: _dark),
                                  children: [
                                    _th("CIN"),
                                    _th("Nom"),
                                    _th("Prénom"),
                                    _th("Téléphone"),
                                    _th("Email"),
                                    _th("Sexe"),
                                    _th("Date naiss."),
                                    _th("Actions"),
                                  ],
                                ),
                                ..._filtered.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final u = entry.value;
                                  final isEven = i % 2 == 0;
                                  final nom = u['nom'] ?? '—';
                                  final prenom = u['prenom'] ?? '—';

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: isEven
                                          ? Colors.white
                                          : _lightGreen,
                                    ),
                                    children: [
                                      _td(Text(
                                        u['cin'] ?? '—',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _dark),
                                      )),
                                      _td(Row(children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor:
                                              _dark.withOpacity(0.1),
                                          child: Text(
                                            nom.isNotEmpty
                                                ? nom[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: _dark,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                            child: Text(nom,
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                      ])),
                                      _td(Text(prenom,
                                          overflow: TextOverflow.ellipsis)),
                                      _td(Text(u['num_tel'] ?? '—',
                                          style: TextStyle(
                                              color: Colors.grey.shade700))),
                                      _td(Text(u['email'] ?? '—',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12))),
                                      _td(_sexeBadge(u['sexe'])),
                                      _td(Text(
                                        _formatDate(u['date_naissance']),
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12),
                                      )),
                                      _td(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                _openForm(user: u),
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                color: _green,
                                                size: 20),
                                            tooltip: "Modifier",
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  _green.withOpacity(0.1),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8)),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          IconButton(
                                            onPressed: () => _delete(
                                                u['cin'] ?? '',
                                                "$nom $prenom"),
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20),
                                            tooltip: "Supprimer",
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.withOpacity(0.1),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8)),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sexeBadge(String? sexe) {
    final isMale = (sexe ?? '').toLowerCase() == 'homme';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMale
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        sexe ?? '—',
        style: TextStyle(
          color: isMale
              ? const Color(0xFF1565C0)
              : const Color(0xFFC62828),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final d = DateTime.parse(date.toString());
      return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    } catch (_) {
      return '—';
    }
  }

  TableCell _th(String text) => TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      );

  TableCell _td(Widget child) => TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: child,
        ),
      );
}


class _UserFormDialog extends StatefulWidget {
  final Map? user;
  final VoidCallback onSaved;

  const _UserFormDialog({this.user, required this.onSaved});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  bool _obscure = true;

  late final TextEditingController _cin;
  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  late final TextEditingController _adresse;
  late final TextEditingController _tel;
  late final TextEditingController _carteB;
  late final TextEditingController _email;
  late final TextEditingController _mdp;
  late final TextEditingController _dateNaissance;
  String _sexe = 'Homme';

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user ?? {};
    _cin = TextEditingController(text: u['cin'] ?? '');
    _nom = TextEditingController(text: u['nom'] ?? '');
    _prenom = TextEditingController(text: u['prenom'] ?? '');
    _adresse = TextEditingController(text: u['adresse'] ?? '');
    _tel = TextEditingController(text: u['num_tel'] ?? '');
    _carteB = TextEditingController(text: u['num_carteB'] ?? '');
    _email = TextEditingController(text: u['email'] ?? '');
    _mdp = TextEditingController();
    _dateNaissance = TextEditingController(
        text: u['date_naissance'] != null
            ? _formatDateInput(u['date_naissance'])
            : '');
    _sexe = u['sexe'] ?? 'Homme';
  }

  @override
  void dispose() {
    for (final c in [
      _cin, _nom, _prenom, _adresse, _tel, _carteB, _email, _mdp, _dateNaissance
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatDateInput(dynamic date) {
    try {
      final d = DateTime.parse(date.toString());
      return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }

  String _convertDate(String input) {
    if (input.isEmpty) return '';
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) return input;
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(input)) {
      final parts = input.split('/');
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return input;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final body = {
        "cin": _cin.text.trim(),
        "nom": _nom.text.trim(),
        "prenom": _prenom.text.trim(),
        "adresse": _adresse.text.trim(),
        "num_tel": _tel.text.trim(),
        "num_carteB": _carteB.text.trim(),
        "email": _email.text.trim(),
        "sexe": _sexe,
        "date_naissance": _convertDate(_dateNaissance.text.trim()),
        if (_mdp.text.isNotEmpty) "mdp": _mdp.text,
      };

      final http.Response res;
      if (isEdit) {
        res = await http.put(
          Uri.parse(
              "http://localhost:3000/utilisateur/update/${widget.user!['cin']}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      } else {
        res = await http.post(
          Uri.parse("http://localhost:3000/utilisateur/create"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      }

      final resBody = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        Navigator.of(context).pop(); 
        widget.onSaved();           
      } else {
        setState(() => _error = resBody['message'] ?? "Erreur serveur");
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
        width: 600,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_outlined : Icons.person_add_outlined,
                        color: _dark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdit ? "Modifier l'utilisateur" : "Ajouter un utilisateur",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _dark),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(children: [
                  Expanded(child: _formField("CIN", _cin,
                      enabled: !isEdit,
                      validator: (v) =>
                          v!.isEmpty ? "CIN requis" : null)),
                  const SizedBox(width: 12),
                  Expanded(child: _formField("Nom", _nom,
                      validator: (v) =>
                          v!.isEmpty ? "Nom requis" : null)),
                  const SizedBox(width: 12),
                  Expanded(child: _formField("Prénom", _prenom,
                      validator: (v) =>
                          v!.isEmpty ? "Prénom requis" : null)),
                ]),

                const SizedBox(height: 12),

                Row(children: [
                  Expanded(child: _formField("Email", _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v!.isEmpty ? "Email requis" : null)),
                  const SizedBox(width: 12),
                  Expanded(child: _formField("Téléphone", _tel,
                      keyboardType: TextInputType.phone)),
                ]),

                const SizedBox(height: 12),

                Row(children: [
                  Expanded(child: _formField("Adresse", _adresse)),
                  const SizedBox(width: 12),
                  Expanded(child: _formField("N° Carte bancaire", _carteB)),
                ]),

                const SizedBox(height: 12),

                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Date de naissance",
                            style: TextStyle(
                                color: _dark,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                              builder: (context, child) => Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: _dark,
                                    onPrimary: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _dateNaissance.text =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: _lightGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    color: _dark, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  _dateNaissance.text.isEmpty
                                      ? "Choisir une date"
                                      : _dateNaissance.text,
                                  style: TextStyle(
                                    color: _dateNaissance.text.isEmpty
                                        ? Colors.grey.shade400
                                        : _dark,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Sexe",
                            style: TextStyle(
                                color: _dark,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _sexe,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _lightGreen,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                          items: ['Homme', 'Femme']
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _sexe = v!),
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 12),

                _formField(
                  isEdit
                      ? "Nouveau mot de passe (laisser vide = inchangé)"
                      : "Mot de passe",
                  _mdp,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                        size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: isEdit
                      ? null
                      : (v) => v!.isEmpty ? "Mot de passe requis" : null,
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
                      Expanded(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red))),
                    ]),
                  ),
                ],

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? "Enregistrer" : "Ajouter"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
    bool enabled = true,
    TextInputType? keyboardType,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _dark, fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: _dark, fontSize: 13),
          decoration: InputDecoration(
            suffixIcon: suffix,
            filled: true,
            fillColor: enabled ? _lightGreen : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _dark, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}