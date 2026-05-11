import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const _dark = Color(0xFF0F3D2E);
const _green = Color(0xFF1F7A5C);
const _lightGreen = Color(0xFFF0FAF5);

class ProduitPage extends StatefulWidget {
  const ProduitPage({super.key});

  @override
  State<ProduitPage> createState() => _ProduitPageState();
}

class _ProduitPageState extends State<ProduitPage> {
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
        Uri.parse("http://localhost:3000/produit/list"),
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
        _showSnack("Produit supprimé avec succès", _green);
        loadProduits();
      } else {
        _showSnack("Erreur suppression", Colors.red);
      }
    } catch (e) {
      _showSnack("Impossible de contacter le serveur", Colors.red);
    }
  }

  void _openForm({Map? produit}) {
    showDialog(
      context: context,
      builder: (_) => _ProduitFormDialog(
        produit: produit,
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
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: _dark, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gestion des produits",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _dark),
                      ),
                      Text(
                        "Liste de tous les produits disponibles",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: loadProduits,
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
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter un produit"),
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
                  flex: 3,
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: _dark),
                    decoration: InputDecoration(
                      hintText: "Rechercher un produit par nom...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon:
                          const Icon(Icons.search, color: _dark, size: 20),
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
                        borderSide:
                            const BorderSide(color: _dark, width: 1.5),
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
                      const Icon(Icons.inventory_2_outlined,
                          color: _dark, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "${_filtered.length} / ${_all.length} produit(s)",
                        style: const TextStyle(
                            color: _dark, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _dark))
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 70, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                _searchCtrl.text.isEmpty
                                    ? "Aucun produit trouvé"
                                    : "Aucun résultat pour\n\"${_searchCtrl.text}\"",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.80,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final p = _filtered[i];
                            return _ProduitCard(
                              produit: p,
                              onEdit: () => _openForm(produit: p),
                              onDelete: () =>
                                  _delete(p['_id'], p['nom'] ?? ''),
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

    final entreprise = p['identreprise'];
    final entrepriseNom = entreprise is Map
        ? (entreprise['nom'] ?? '')
        : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
              blurRadius: _hovered ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                        color: _lightGreen,
                        child: const Center(
                          child: Icon(Icons.shopping_bag_outlined,
                              color: _green, size: 44),
                        ),
                      ),
                    ),
                    if (entrepriseNom.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _dark.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entrepriseNom,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
            
                    if (_hovered)
                      Container(
                        color: _dark.withOpacity(0.08),
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
                      fontSize: 14,
                      color: _dark,
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
                          color: Colors.grey.shade500, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _dark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${p['prix']} TND",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(children: [
                        _actionBtn(
                          icon: Icons.edit_outlined,
                          color: _green,
                          onTap: widget.onEdit,
                          tooltip: "Modifier",
                        ),
                        const SizedBox(width: 6),
                        _actionBtn(
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: widget.onDelete,
                          tooltip: "Supprimer",
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

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

class _ProduitFormDialog extends StatefulWidget {
  final Map? produit;
  final VoidCallback onSaved;

  const _ProduitFormDialog({this.produit, required this.onSaved});

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
      };

      final http.Response res;
      if (isEdit) {
        res = await http.put(
          Uri.parse(
              "http://localhost:3000/produit/update/${widget.produit!['_id']}"),
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
        width: 440,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _lightGreen,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    isEdit
                        ? Icons.edit_outlined
                        : Icons.add_shopping_cart_outlined,
                    color: _dark,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? "Modifier le produit" : "Ajouter un produit",
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
                          width: 18,
                          height: 18,
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
      {TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _dark,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
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
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _dark, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}