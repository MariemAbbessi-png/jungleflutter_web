import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const _dark = Color(0xFF0F3D2E);
const _green = Color(0xFF1F7A5C);
const _lightGreen = Color(0xFFF0FAF5);
const _midGreen = Color(0xFF2E8B57);

class EntreprisePage extends StatelessWidget {
  const EntreprisePage({super.key});

  static const List<Map<String, String>> _categories = [
    {'label': 'Restaurants',   'type': 'Restaurants',   'image': 'images/resto.jpg'},
    {'label': 'Courses',       'type': 'Courses',       'image': 'images/course.jpg'},
    {'label': 'Boutiques',     'type': 'Boutiques',     'image': 'images/boutique.jpg'},
    {'label': 'Beauté',        'type': 'beaute',        'image': 'images/beaute.jpg'},
    {'label': 'Parapharmacie', 'type': 'Parapharmacie', 'image': 'images/pharma.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(28),
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
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.business_outlined, color: _dark, size: 26),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Entreprises partenaires",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _dark)),
                    Text("Sélectionnez une catégorie",
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CategoryBubble(cat: _categories[0]),
                          const SizedBox(width: 40),
                          _CategoryBubble(cat: _categories[1]),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CategoryBubble(cat: _categories[2]),
                          const SizedBox(width: 24),
                          _CategoryBubble(cat: _categories[3]),
                          const SizedBox(width: 24),
                          _CategoryBubble(cat: _categories[4]),
                        ],
                      ),
                      const SizedBox(height: 20),
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
}


class _CategoryBubble extends StatefulWidget {
  final Map<String, String> cat;
  const _CategoryBubble({required this.cat});

  @override
  State<_CategoryBubble> createState() => _CategoryBubbleState();
}

class _CategoryBubbleState extends State<_CategoryBubble> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EntrepriseListPage(
              type: widget.cat['type']!,
              label: widget.cat['label']!,
            ),
          ),
        ),
        child: AnimatedScale(
          scale: _hovered ? 1.07 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Column(
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _hovered ? _midGreen : const Color(0xFFA8D5B5),
                    width: _hovered ? 4 : 3,
                  ),
                  color: _hovered ? _lightGreen : const Color(0xFFEAF5EE),
                  boxShadow: _hovered
                      ? [BoxShadow(
                          color: _green.withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 2)]
                      : [],
                ),
                child: Center(
                  child: Container(
                    width: 95,
                    height: 95,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          widget.cat['image']!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            _fallbackIcon(widget.cat['type']!),
                            color: _green,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _hovered ? _dark : _lightGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _hovered ? _dark : const Color(0xFFA8D5B5),
                  ),
                ),
                child: Text(
                  widget.cat['label']!,
                  style: TextStyle(
                    color: _hovered ? Colors.white : _dark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _fallbackIcon(String type) {
    switch (type) {
      case 'Restaurants': return Icons.restaurant;
      case 'Courses': return Icons.shopping_cart;
      case 'Boutiques': return Icons.shopping_bag;
      case 'beaute': return Icons.spa;
      case 'Parapharmacie': return Icons.local_pharmacy;
      default: return Icons.business;
    }
  }
}


class EntrepriseListPage extends StatefulWidget {
  final String type;
  final String label;
  const EntrepriseListPage({super.key, required this.type, required this.label});

  @override
  State<EntrepriseListPage> createState() => _EntrepriseListPageState();
}

class _EntrepriseListPageState extends State<EntrepriseListPage> {
  List _all = [];
  List _filtered = [];  
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadEntreprises();
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
              .where((e) =>
                  (e['nom'] ?? '').toLowerCase().contains(q) ||
                  (e['adresse'] ?? '').toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> loadEntreprises() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("http://localhost:3000/entreprise/listpartype/${widget.type}"),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body is List ? body : (body['entreprises'] ?? []);
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

  Future<void> _delete(String id, String nom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text("Confirmer suppression"),
        ]),
        content: Text("Supprimer l'entreprise \"$nom\" ?"),
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
        Uri.parse("http://localhost:3000/entreprise/deletee/$id"),
      );
      if (res.statusCode == 200) {
        _showSnack("Entreprise supprimée avec succès", _green);
        loadEntreprises();
      } else {
        final b = jsonDecode(res.body);
        _showSnack(b['message'] ?? "Erreur", Colors.red);
      }
    } catch (e) {
      _showSnack("Impossible de contacter le serveur", Colors.red);
    }
  }

  void _openForm({Map? entreprise}) {
    showDialog(
      context: context,
      builder: (_) => _EntrepriseFormDialog(
        entreprise: entreprise,
        defaultType: widget.type,
        onSaved: () => loadEntreprises(),
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
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.store_outlined, color: _dark, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _dark)),
                      Text("${_filtered.length} entreprise(s)",
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: loadEntreprises,
                  icon: const Icon(Icons.refresh, color: _dark),
                  style: IconButton.styleFrom(
                    backgroundColor: _lightGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text("Ajouter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: _dark),
                    decoration: InputDecoration(
                      hintText: "Rechercher une entreprise par nom...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, color: _dark, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: Colors.grey.shade400, size: 18),
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _dark, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store_outlined, color: _dark, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "${_filtered.length} / ${_all.length}",
                        style: const TextStyle(
                            color: _dark, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _dark))
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store_mall_directory_outlined,
                                  size: 70, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                _searchCtrl.text.isEmpty
                                    ? "Aucune entreprise dans\nla catégorie ${widget.label}"
                                    : "Aucun résultat pour\n\"${_searchCtrl.text}\"",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final e = _filtered[i];
                            return _EntrepriseCard(
                              entreprise: e,
                              onEdit: () => _openForm(entreprise: e),
                              onDelete: () => _delete(e['_id'], e['nom'] ?? ''),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProduitListPage(
                                    entrepriseId: e['_id'],
                                    entrepriseNom: e['nom'] ?? '',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}


class _EntrepriseCard extends StatefulWidget {
  final Map entreprise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _EntrepriseCard({
    required this.entreprise,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<_EntrepriseCard> createState() => _EntrepriseCardState();
}

class _EntrepriseCardState extends State<_EntrepriseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entreprise;
    final imgUrl = "http://localhost:3000/uploads/${e['image']}";

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _hovered ? _lightGreen : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? _green : Colors.grey.shade200,
              width: _hovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? _green.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _hovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _hovered ? _green : Colors.grey.shade200,
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _lightGreen,
                      child: const Icon(Icons.business, color: _green, size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e['nom'] ?? '—',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14, color: _dark),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                e['adresse'] ?? '',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_hovered)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text("Voir les produits →",
                      style: TextStyle(
                          color: _green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_outlined, color: _green, size: 18),
                    tooltip: "Modifier",
                    style: IconButton.styleFrom(
                      backgroundColor: _green.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                    tooltip: "Supprimer",
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _EntrepriseFormDialog extends StatefulWidget {
  final Map? entreprise;
  final String defaultType;
  final VoidCallback onSaved;

  const _EntrepriseFormDialog({
    this.entreprise,
    required this.defaultType,
    required this.onSaved,
  });

  @override
  State<_EntrepriseFormDialog> createState() => _EntrepriseFormDialogState();
}

class _EntrepriseFormDialogState extends State<_EntrepriseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  late final TextEditingController _nom;
  late final TextEditingController _adresse;
  late final TextEditingController _tel;
  late final TextEditingController _email;
  late final TextEditingController _mdp;
  late String _type;

  bool get isEdit => widget.entreprise != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entreprise ?? {};
    _nom = TextEditingController(text: e['nom'] ?? '');
    _adresse = TextEditingController(text: e['adresse'] ?? '');
    _tel = TextEditingController(text: e['num_tel'] ?? '');
    _email = TextEditingController(text: e['email'] ?? '');
    _mdp = TextEditingController();
    _type = e['typeentreprise'] ?? widget.defaultType;
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
      final body = {
        "nom": _nom.text.trim(),
        "adresse": _adresse.text.trim(),
        "num_tel": _tel.text.trim(),
        "email": _email.text.trim(),
        "typeentreprise": _type,
        if (_mdp.text.isNotEmpty) "motdp": _mdp.text,
      };

      final http.Response res;
      if (isEdit) {
        res = await http.put(
          Uri.parse("http://localhost:3000/entreprise/update/${widget.entreprise!['_id']}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      } else {
        res = await http.post(
          Uri.parse("http://localhost:3000/entreprise/create"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      }

      final resBody = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
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
        width: 500,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      isEdit ? Icons.edit_outlined : Icons.add_business_outlined,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? "Modifier l'entreprise" : "Ajouter une entreprise",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: _dark),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ]),
                const SizedBox(height: 20),
                _ff("Nom", _nom, validator: (v) => v!.isEmpty ? "Requis" : null),
                const SizedBox(height: 12),
                _ff("Adresse", _adresse),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _ff("Téléphone", _tel, keyboardType: TextInputType.phone)),
                  const SizedBox(width: 12),
                  Expanded(child: _ff("Email", _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? "Requis" : null)),
                ]),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Type d'entreprise",
                        style: TextStyle(
                            color: _dark, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _lightGreen,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: ['Restaurants', 'Courses', 'Boutiques', 'beaute', 'Parapharmacie']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ff(
                  isEdit ? "Mot de passe (laisser vide = inchangé)" : "Mot de passe",
                  _mdp,
                  obscure: true,
                  validator: isEdit ? null : (v) => v!.isEmpty ? "Requis" : null,
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
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_error!,
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
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(isEdit ? "Enregistrer" : "Ajouter"),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ff(String label, TextEditingController ctrl,
      {bool obscure = false,
      TextInputType? keyboardType,
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
          obscureText: obscure,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}


class ProduitListPage extends StatefulWidget {
  final String entrepriseId;
  final String entrepriseNom;

  const ProduitListPage({
    super.key,
    required this.entrepriseId,
    required this.entrepriseNom,
  });

  @override
  State<ProduitListPage> createState() => _ProduitListPageState();
}

class _ProduitListPageState extends State<ProduitListPage> {
  List _all = [];
  List _filtered = [];
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProduits();
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
              .where((p) =>
                  (p['nom'] ?? '').toLowerCase().contains(q) ||
                  (p['description'] ?? '').toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> loadProduits() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("http://localhost:3000/produit/byentreprise/${widget.entrepriseId}"),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body is List ? body : (body['produits'] ?? []);
        setState(() {
          _all = list;
          _filtered = List.from(list);
        });
      }
    } catch (e) {
      debugPrint("Erreur produits: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduit(String id, String nom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text("Confirmer suppression"),
        ]),
        content: Text("Supprimer le produit \"$nom\" ?"),
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
        Uri.parse("http://localhost:3000/produit/deletep/$id"),
      );
      if (res.statusCode == 200) {
        _showSnack("Produit supprimé", _green);
        loadProduits();
      } else {
        _showSnack("Erreur suppression", Colors.red);
      }
    } catch (e) {
      _showSnack("Impossible de contacter le serveur", Colors.red);
    }
  }

  void _openProduitForm({Map? produit}) {
    showDialog(
      context: context,
      builder: (_) => _ProduitFormDialog(
        produit: produit,
        entrepriseId: widget.entrepriseId,
        onSaved: () => loadProduits(),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF0A2E1F), Color(0xFF0F3D2E), Color(0xFF1A5C3A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60, right: -60,
              child: _decorCircle(240),
            ),
            Positioned(
              bottom: -80, left: -50,
              child: _decorCircle(200),
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white70, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.entrepriseNom,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${_filtered.length} produit(s)${_searchCtrl.text.isNotEmpty ? ' trouvé(s)' : ''}",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: loadProduits,
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    
                      ElevatedButton.icon(
                        onPressed: () => _openProduitForm(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Ajouter un produit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText:
                                  "Rechercher un produit par nom...",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 14),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color:
                                              Colors.white.withOpacity(0.6),
                                          size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        _onSearch();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                color: const Color(0xFF4CAF50), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "${_filtered.length} / ${_all.length}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF4CAF50)))
                      : _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 70,
                                      color:
                                          Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchCtrl.text.isEmpty
                                        ? "Aucun produit pour\n${widget.entrepriseNom}"
                                        : "Aucun résultat pour\n\"${_searchCtrl.text}\"",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            Colors.white.withOpacity(0.4),
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  24, 0, 24, 24),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.78,
                                ),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) {
                                  final p = _filtered[i];
                                  return _ProduitCard(
                                    produit: p,
                                    onEdit: () =>
                                        _openProduitForm(produit: p),
                                    onDelete: () => _deleteProduit(
                                        p['_id'], p['nom'] ?? ''),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.04),
        ),
      );
}

class _ProduitCard extends StatefulWidget {
  final Map produit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProduitCard({
    required this.produit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProduitCard> createState() => _ProduitCardState();
}

class _ProduitCardState extends State<_ProduitCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.produit;
    final imgUrl = "http://localhost:3000/uploads/${p['image']}";

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? const Color(0xFF4CAF50).withOpacity(0.8)
                : Colors.white.withOpacity(0.12),
            width: _hovered ? 2 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1F7A5C),
                              const Color(0xFF0F3D2E)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.shopping_bag_outlined,
                              color: Colors.white54, size: 44),
                        ),
                      ),
                    ),
                    if (_hovered)
                      Container(
                        color: Colors.black.withOpacity(0.15),
                        child: const Center(
                          child: Icon(Icons.visibility_outlined,
                              color: Colors.white70, size: 32),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['nom'] ?? '—',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (p['description'] != null &&
                      (p['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      p['description'],
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.4)),
                        ),
                        child: Text(
                          "${p['prix']} TND",
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(children: [
                        _actionBtn(
                          icon: Icons.edit_outlined,
                          color: const Color(0xFF4CAF50),
                          onTap: widget.onEdit,
                        ),
                        const SizedBox(width: 6),
                        _actionBtn(
                          icon: Icons.delete_outline,
                          color: Colors.redAccent,
                          onTap: widget.onDelete,
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}

class _ProduitFormDialog extends StatefulWidget {
  final Map? produit;
  final String entrepriseId;
  final VoidCallback onSaved;

  const _ProduitFormDialog({
    this.produit,
    required this.entrepriseId,
    required this.onSaved,
  });

  @override
  State<_ProduitFormDialog> createState() => _ProduitFormDialogState();
}

class _ProduitFormDialogState extends State<_ProduitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  late final TextEditingController _nom;
  late final TextEditingController _description;
  late final TextEditingController _prix;

  bool get isEdit => widget.produit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.produit ?? {};
    _nom = TextEditingController(text: p['nom'] ?? '');
    _description = TextEditingController(text: p['description'] ?? '');
    _prix = TextEditingController(
        text: p['prix'] != null ? p['prix'].toString() : '');
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _prix.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final body = {
        "nom": _nom.text.trim(),
        "description": _description.text.trim(),
        "prix": double.tryParse(_prix.text.trim()) ?? 0,
        "identreprise": widget.entrepriseId,
      };

      final http.Response res;
      if (isEdit) {
        res = await http.put(
          Uri.parse("http://localhost:3000/produit/update/${widget.produit!['_id']}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      } else {
        res = await http.post(
          Uri.parse("http://localhost:3000/produit/create"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      }

      final resBody = jsonDecode(res.body);
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
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
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _lightGreen,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.shopping_bag_outlined, color: _dark),
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? "Modifier le produit" : "Ajouter un produit",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: _dark),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ]),
              const SizedBox(height: 20),
              _ff("Nom du produit", _nom,
                  validator: (v) => v!.isEmpty ? "Requis" : null),
              const SizedBox(height: 12),
              _ff("Description", _description),
              const SizedBox(height: 12),
              _ff("Prix (TND)", _prix,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? "Requis" : null),
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
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_error!,
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
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(isEdit ? "Enregistrer" : "Ajouter"),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ff(String label, TextEditingController ctrl,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}