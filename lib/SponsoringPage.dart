import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const _dark = Color(0xFF0F3D2E);
const _green = Color(0xFF1F7A5C);
const _lightGreen = Color(0xFFF0FAF5);
const _accent = Color(0xFF4CAF50);

class SponsoringPage extends StatefulWidget {
  const SponsoringPage({super.key});

  @override
  State<SponsoringPage> createState() => _SponsoringPageState();
}

class _SponsoringPageState extends State<SponsoringPage> {
  List _all = [];
  List _filtered = [];
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();
  String _filterStatut = 'Tous';

  // ── Stats ─────────────────────────────────────────────────────────────────
  int get totalSponsored => _all.length;
  int get totalImpressions =>
      _all.fold(0, (s, p) => s + ((p['impressions'] ?? 0) as num).toInt());
  int get totalClicks =>
      _all.fold(0, (s, p) => s + ((p['clicks'] ?? 0) as num).toInt());
  double get avgCtr => totalImpressions == 0
      ? 0
      : (totalClicks / totalImpressions * 100);

  @override
  void initState() {
    super.initState();
    loadSponsoring();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() => _applyFilters();

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = _all.where((p) {
        final matchName =
            (p['nom'] ?? '').toLowerCase().contains(q);
        final statut = (p['statut'] ?? 'actif');
        final matchStatut = _filterStatut == 'Tous' ||
            (_filterStatut == 'Actif' && statut == 'actif') ||
            (_filterStatut == 'Inactif' && statut == 'inactif');
        return matchName && matchStatut;
      }).toList();
    });
  }

  Future<void> loadSponsoring() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("http://localhost:3000/sponsoring/list"),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body is List ? body : (body['sponsorings'] ?? []);
        setState(() {
          _all = list;
          _filtered = List.from(list);
        });
      }
    } catch (e) {
      debugPrint("Erreur sponsoring: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Toggle statut ─────────────────────────────────────────────────────────
  Future<void> _toggleStatut(Map item) async {
    final newStatut =
        (item['statut'] ?? 'actif') == 'actif' ? 'inactif' : 'actif';
    try {
      final res = await http.put(
        Uri.parse(
            "http://localhost:3000/sponsoring/update/${item['_id']}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"statut": newStatut}),
      );
      if (res.statusCode == 200) {
        setState(() => item['statut'] = newStatut);
        _applyFilters();
      }
    } catch (e) {
      _showSnack("Erreur mise à jour", Colors.red);
    }
  }

  // ── Modifier niveau ───────────────────────────────────────────────────────
  Future<void> _updateNiveau(Map item, int niveau) async {
    try {
      final res = await http.put(
        Uri.parse(
            "http://localhost:3000/sponsoring/update/${item['_id']}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"niveau": niveau}),
      );
      if (res.statusCode == 200) {
        setState(() => item['niveau'] = niveau);
      }
    } catch (e) {
      debugPrint("Erreur niveau: $e");
    }
  }

  // ── Supprimer ─────────────────────────────────────────────────────────────
  Future<void> _delete(String id, String nom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text("Confirmer suppression"),
        ]),
        content: Text("Supprimer le sponsoring \"$nom\" ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text("Annuler", style: TextStyle(color: Colors.grey)),
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
        Uri.parse("http://localhost:3000/sponsoring/delete/$id"),
      );
      if (res.statusCode == 200) {
        _showSnack("Sponsoring supprimé", _green);
        loadSponsoring();
      }
    } catch (e) {
      _showSnack("Erreur suppression", Colors.red);
    }
  }

  void _openForm({Map? item}) {
    showDialog(
      context: context,
      builder: (_) => _SponsoringFormDialog(
        item: item,
        onSaved: () => loadSponsoring(),
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
            // ── TOP BAR ─────────────────────────────────────────────────
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
                  child: const Icon(Icons.campaign_outlined,
                      color: _dark, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gestion du Sponsoring",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _dark)),
                      Text(
                          "Gérez les produits sponsorisés qui apparaissent en priorité",
                          style:
                              TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: loadSponsoring,
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
                  label: const Text("Ajouter"),
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

            // ── STATS CARDS ──────────────────────────────────────────────
            Row(
              children: [
                _StatCard(
                  icon: Icons.campaign_outlined,
                  label: "Sponsorisés",
                  value: "$totalSponsored",
                  color: _dark,
                ),
                const SizedBox(width: 14),
                _StatCard(
                  icon: Icons.visibility_outlined,
                  label: "Impressions",
                  value: _fmt(totalImpressions),
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 14),
                _StatCard(
                  icon: Icons.ads_click_outlined,
                  label: "Clics",
                  value: _fmt(totalClicks),
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 14),
                _StatCard(
                  icon: Icons.percent_outlined,
                  label: "CTR moyen",
                  value: "${avgCtr.toStringAsFixed(2)}%",
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── FILTRES + RECHERCHE ──────────────────────────────────────
            Row(
              children: [
                // Recherche
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: _dark),
                    decoration: InputDecoration(
                      hintText: "Rechercher un produit sponsorisé...",
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search,
                          color: _dark, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: Colors.grey.shade400,
                                  size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _applyFilters();
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
                // Filtre statut
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterStatut,
                      style: const TextStyle(
                          color: _dark, fontSize: 13),
                      items: ['Tous', 'Actif', 'Inactif']
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _filterStatut = v!);
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Compteur
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.campaign_outlined,
                        color: _dark, size: 18),
                    const SizedBox(width: 6),
                    Text("${_filtered.length} / ${_all.length}",
                        style: const TextStyle(
                            color: _dark,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── TABLEAU ──────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: _dark))
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.campaign_outlined,
                                  size: 70,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                _searchCtrl.text.isEmpty
                                    ? "Aucun sponsoring trouvé"
                                    : "Aucun résultat pour\n\"${_searchCtrl.text}\"",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2.2), // Produit
                                1: FlexColumnWidth(1.4), // Statut
                                2: FlexColumnWidth(1.8), // Niveau
                                3: FlexColumnWidth(1.5), // Début
                                4: FlexColumnWidth(1.5), // Fin
                                5: FlexColumnWidth(1.2), // Impr.
                                6: FlexColumnWidth(1),   // Clics
                                7: FlexColumnWidth(1),   // CTR
                                8: FlexColumnWidth(1.2), // Actions
                              },
                              children: [
                                // Header
                                TableRow(
                                  decoration: const BoxDecoration(
                                      color: _dark),
                                  children: [
                                    _th("Produit"),
                                    _th("Statut"),
                                    _th("Niveau"),
                                    _th("Début"),
                                    _th("Fin"),
                                    _th("Impr."),
                                    _th("Clics"),
                                    _th("CTR"),
                                    _th("Actions"),
                                  ],
                                ),
                                // Rows
                                ..._filtered
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final i = entry.key;
                                  final p = entry.value;
                                  final isEven = i % 2 == 0;
                                  final isActif =
                                      (p['statut'] ?? 'actif') ==
                                          'actif';
                                  final niveau =
                                      (p['niveau'] ?? 1) as int;
                                  final imp =
                                      (p['impressions'] ?? 0)
                                          as num;
                                  final clicks =
                                      (p['clicks'] ?? 0) as num;
                                  final ctr = imp > 0
                                      ? (clicks / imp * 100)
                                      : 0.0;

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: isEven
                                          ? Colors.white
                                          : _lightGreen,
                                    ),
                                    children: [
                                      // Produit
                                      _td(Row(children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: _lightGreen,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                          ),
                                          child: const Icon(
                                              Icons
                                                  .shopping_bag_outlined,
                                              color: _green,
                                              size: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            p['nom'] ?? '—',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: _dark,
                                                fontSize: 13),
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ])),

                                      // Statut toggle
                                      _td(Row(children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _toggleStatut(p),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 40,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: isActif
                                                  ? _accent
                                                  : Colors
                                                      .grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      11),
                                            ),
                                            child: AnimatedAlign(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              alignment: isActif
                                                  ? Alignment
                                                      .centerRight
                                                  : Alignment
                                                      .centerLeft,
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                margin:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 3),
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Colors.white,
                                                  shape:
                                                      BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isActif
                                                ? const Color(
                                                    0xFFE8F5E9)
                                                : Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                          ),
                                          child: Text(
                                            isActif
                                                ? "Actif"
                                                : "Inactif",
                                            style: TextStyle(
                                              color: isActif
                                                  ? _accent
                                                  : Colors.grey,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ])),

                                      // Niveau avec étoiles
                                      _td(Row(children: [
                                        IconButton(
                                          onPressed: niveau > 1
                                              ? () => _updateNiveau(
                                                  p, niveau - 1)
                                              : null,
                                          icon: const Icon(
                                              Icons.remove,
                                              size: 14),
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(
                                                  minWidth: 22,
                                                  minHeight: 22),
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                _lightGreen,
                                            shape:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                6)),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Row(
                                          children: List.generate(
                                              5,
                                              (si) => Icon(
                                                    si < niveau
                                                        ? Icons.star
                                                        : Icons
                                                            .star_border,
                                                    color: si < niveau
                                                        ? const Color(
                                                            0xFFF59E0B)
                                                        : Colors
                                                            .grey.shade300,
                                                    size: 14,
                                                  )),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          onPressed: niveau < 5
                                              ? () => _updateNiveau(
                                                  p, niveau + 1)
                                              : null,
                                          icon: const Icon(Icons.add,
                                              size: 14),
                                          padding: EdgeInsets.zero,
                                          constraints:
                                              const BoxConstraints(
                                                  minWidth: 22,
                                                  minHeight: 22),
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                _lightGreen,
                                            shape:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                6)),
                                          ),
                                        ),
                                      ])),

                                      // Début
                                      _td(Text(
                                        _fmtDate(p['dateDebut']),
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12),
                                      )),

                                      // Fin
                                      _td(Text(
                                        _fmtDate(p['dateFin']),
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12),
                                      )),

                                      // Impressions
                                      _td(Text(
                                        _fmt(imp.toInt()),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _dark),
                                      )),

                                      // Clics
                                      _td(Text(
                                        _fmt(clicks.toInt()),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _dark),
                                      )),

                                      // CTR
                                      _td(Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${ctr.toStringAsFixed(1)}%",
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: _green,
                                                fontSize: 12),
                                          ),
                                          const SizedBox(height: 3),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: LinearProgressIndicator(
                                              value: ctr / 100,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              color: _green,
                                              minHeight: 4,
                                            ),
                                          ),
                                        ],
                                      )),

                                      // Actions
                                      _td(Row(children: [
                                        IconButton(
                                          onPressed: () =>
                                              _openForm(item: p),
                                          icon: const Icon(
                                              Icons.edit_outlined,
                                              color: _green,
                                              size: 18),
                                          tooltip: "Modifier",
                                          style: IconButton.styleFrom(
                                            backgroundColor: _green
                                                .withOpacity(0.1),
                                            shape:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8)),
                                            padding:
                                                const EdgeInsets.all(6),
                                            minimumSize:
                                                const Size(30, 30),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          onPressed: () => _delete(
                                              p['_id'],
                                              p['nom'] ?? ''),
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 18),
                                          tooltip: "Supprimer",
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.red
                                                .withOpacity(0.1),
                                            shape:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8)),
                                            padding:
                                                const EdgeInsets.all(6),
                                            minimumSize:
                                                const Size(30, 30),
                                          ),
                                        ),
                                      ])),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
            ),

            const SizedBox(height: 16),

            // ── INFO PANEL ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _dark.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline,
                        color: _dark, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Comment fonctionne le sponsoring ?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _dark,
                                fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          "Les produits avec un niveau de sponsoring plus élevé apparaissent en premier dans les recommandations et la page d'accueil. Niveau 5 = visibilité maximale.",
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              height: 1.5),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [1, 2, 3, 4, 5].map((n) {
                            final labels = [
                              'Basique',
                              'Standard',
                              'Priorité',
                              'Vedette',
                              'Premium'
                            ];
                            final isHigh = n >= 3;
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isHigh
                                    ? _dark
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(8),
                                border: Border.all(
                                  color: isHigh
                                      ? _dark
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                "N$n · ${labels[n - 1]}",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isHigh
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  String _fmtDate(dynamic d) {
    if (d == null) return '—';
    try {
      final dt = DateTime.parse(d.toString());
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return '—';
    }
  }

  TableCell _th(String text) => TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      );

  TableCell _td(Widget child) => TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          child: child,
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// STAT CARD
// ════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DIALOG AJOUTER / MODIFIER
// ════════════════════════════════════════════════════════════════════════════

class _SponsoringFormDialog extends StatefulWidget {
  final Map? item;
  final VoidCallback onSaved;

  const _SponsoringFormDialog({this.item, required this.onSaved});

  @override
  State<_SponsoringFormDialog> createState() =>
      _SponsoringFormDialogState();
}

class _SponsoringFormDialogState extends State<_SponsoringFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  late final TextEditingController _nom;
  late final TextEditingController _dateDebut;
  late final TextEditingController _dateFin;
  int _niveau = 1;
  String _statut = 'actif';

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final p = widget.item ?? {};
    _nom = TextEditingController(text: p['nom'] ?? '');
    _dateDebut = TextEditingController(
        text: _fmtInput(p['dateDebut']));
    _dateFin =
        TextEditingController(text: _fmtInput(p['dateFin']));
    _niveau = (p['niveau'] ?? 1) as int;
    _statut = p['statut'] ?? 'actif';
  }

  @override
  void dispose() {
    _nom.dispose();
    _dateDebut.dispose();
    _dateFin.dispose();
    super.dispose();
  }

  String _fmtInput(dynamic d) {
    if (d == null) return '';
    try {
      final dt = DateTime.parse(d.toString());
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final body = {
        "nom": _nom.text.trim(),
        "dateDebut": _dateDebut.text.trim(),
        "dateFin": _dateFin.text.trim(),
        "niveau": _niveau,
        "statut": _statut,
      };

      final http.Response res;
      if (isEdit) {
        res = await http.put(
          Uri.parse(
              "http://localhost:3000/sponsoring/update/${widget.item!['_id']}"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      } else {
        res = await http.post(
          Uri.parse("http://localhost:3000/sponsoring/create"),
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
        setState(
            () => _error = resBody['message'] ?? "Erreur serveur");
      }
    } catch (e) {
      setState(
          () => _error = "Impossible de contacter le serveur");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                          : Icons.campaign_outlined,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit
                        ? "Modifier le sponsoring"
                        : "Ajouter un sponsoring",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _dark),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.close, color: Colors.grey),
                  ),
                ]),

                const SizedBox(height: 20),

                _ff("Nom du produit", _nom,
                    validator: (v) =>
                        v!.isEmpty ? "Requis" : null),
                const SizedBox(height: 12),

                // Niveau
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Niveau de sponsoring (1 - 5)",
                        style: TextStyle(
                            color: _dark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(children: [
                      ...List.generate(
                          5,
                          (i) => GestureDetector(
                                onTap: () => setState(
                                    () => _niveau = i + 1),
                                child: Icon(
                                  i < _niveau
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: i < _niveau
                                      ? const Color(0xFFF59E0B)
                                      : Colors.grey.shade300,
                                  size: 28,
                                ),
                              )),
                      const SizedBox(width: 10),
                      Text("$_niveau / 5",
                          style: const TextStyle(
                              color: _dark,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ],
                ),

                const SizedBox(height: 12),

                Row(children: [
                  Expanded(
                      child: _ff("Date début (YYYY-MM-DD)",
                          _dateDebut,
                          keyboardType:
                              TextInputType.datetime)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _ff("Date fin (YYYY-MM-DD)",
                          _dateFin,
                          keyboardType:
                              TextInputType.datetime)),
                ]),
                const SizedBox(height: 12),

                // Statut
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Statut",
                        style: TextStyle(
                            color: _dark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _statut,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _lightGreen,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                      ),
                      items: ['actif', 'inactif']
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s == 'actif'
                                  ? 'Actif'
                                  : 'Inactif')))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _statut = v!),
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
                      border:
                          Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: Colors.red))),
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
                            style:
                                TextStyle(color: Colors.grey)),
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
                              borderRadius:
                                  BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2))
                            : Text(isEdit
                                ? "Enregistrer"
                                : "Ajouter"),
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
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: _dark, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}