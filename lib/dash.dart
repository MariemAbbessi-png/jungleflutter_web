import 'package:flutter/material.dart';
import 'utilisateur.dart';
import 'pagep.dart';
import 'PageCashback.dart';
import 'produit.dart';
import 'banque.dart';
import 'entreprise.dart';
import 'SponsoringPage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map?> fetchAdmin() async {
  try {
    final res = await http.get(Uri.parse("http://localhost:3000/admin"));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true &&
          body['admin'] != null &&
          (body['admin'] as List).isNotEmpty) {
        return body['admin'][0] as Map;
      }
    }
  } catch (e) {
    debugPrint("Erreur fetchAdmin: $e");
  }
  return null;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map? admin;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAdmin();
  }

  void loadAdmin() async {
    final data = await fetchAdmin();
    if (!mounted) return;
    setState(() {
      admin = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F3D2E),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (admin == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F3D2E),
        body: Center(
          child: Text("Erreur chargement admin",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F3D2E),
      body: Row(
        children: [
          Sidebar(admin: admin!),
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const DashboardContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int? nbUtilisateurs;
  int? nbEntreprises;
  int? nbProduits;
  String? nomBanque;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final results = await Future.wait([
        http.get(Uri.parse("http://localhost:3000/utilisateur/count")),
        http.get(Uri.parse("http://localhost:3000/entreprise/count")),
        http.get(Uri.parse("http://localhost:3000/produit/count")),
        http.get(Uri.parse("http://localhost:3000/banque/name")),
      ]);

      if (!mounted) return;
      setState(() {
        if (results[0].statusCode == 200) {
          final b = jsonDecode(results[0].body);
          nbUtilisateurs = b['count'] ?? b['total'] ?? 0;
        }
        if (results[1].statusCode == 200) {
          final b = jsonDecode(results[1].body);
          nbEntreprises = b['count'] ?? b['total'] ?? 0;
        }
        if (results[2].statusCode == 200) {
          final b = jsonDecode(results[2].body);
          nbProduits = b['count'] ?? b['total'] ?? 0;
        }
        if (results[3].statusCode == 200) {
          final b = jsonDecode(results[3].body);
          nomBanque = b['name'] ?? b['nom'] ?? '—';
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur loadStats: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cards = [
      {
        'title': 'Utilisateurs',
        'value': nbUtilisateurs != null ? '$nbUtilisateurs' : '...',
        'color': const Color(0xFF4CAF50),
        'bars': [0.4, 0.6, 0.5, 0.8, 0.6, 0.9, 0.7],
        'barColor': const Color(0xFF4CAF50),
      },
      {
        'title': 'Entreprises',
        'value': nbEntreprises != null ? '$nbEntreprises' : '...',
        'color': const Color(0xFF2196F3),
        'bars': [0.5, 0.7, 0.4, 0.6, 0.8, 0.5, 0.9],
        'barColor': const Color(0xFF2196F3),
      },
      {
        'title': 'Banque Partenaire',
        'value': nomBanque ?? '...',
        'color': const Color(0xFFFF9800),
        'bars': [0.6, 0.5, 0.7, 0.4, 0.8, 0.6, 0.5],
        'barColor': const Color(0xFFFF9800),
      },
      {
        'title': 'Produits',
        'value': nbProduits != null ? '$nbProduits' : '...',
        'color': const Color(0xFF9C27B0),
        'bars': [0.3, 0.6, 0.8, 0.5, 0.7, 0.4, 0.9],
        'barColor': const Color(0xFF9C27B0),
      },
      {
        'title': 'Cashback',
        'value': '10%',
        'color': const Color(0xFFF44336),
        'bars': [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
        'barColor': const Color(0xFFF44336),
      },
      {
        'title': 'Sponsoring',
        'value': 'Sponsoring',
        'color': const Color(0xFF0F3D2E),
        'bars': [0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.5],
        'barColor': const Color(0xFF0F3D2E),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TopBar(),
        const SizedBox(height: 20),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  itemCount: 6,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (_, i) => StatCard(data: cards[i]),
                ),
        ),
        const SizedBox(height: 20),
        const EntrepriseCarousel(),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const StatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<double> bars = List<double>.from(data['bars']);
    final Color barColor = data['barColor'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data['title'],
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  data['value'],
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: data['color']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((h) {
                return Container(
                  width: 5,
                  height: 36 * h,
                  decoration: BoxDecoration(
                    color: barColor.withOpacity(0.3 + h * 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final Map admin;
  const Sidebar({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: const Color(0xFF0F3D2E),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("images/logo.jpeg"),
              ),
              SizedBox(width: 10),
              Text("Jungle",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 40),
          navItem(context, Icons.dashboard, "TB", const DashboardScreen()),
          navItem(context, Icons.person, "Utilisateur", const utilisateur()),
          navItem(context, Icons.business, "Entreprise", const EntreprisePage()),
          navItem(context, Icons.account_balance, "Banque", const BanquePage()),
          navItem(context, Icons.shopping_cart, "Produit", const ProduitPage()),
          navItem(context, Icons.monetization_on, "Cashback", const CashbackPage()),
          navItem(context, Icons.campaign, "Sponsoring", const SponsoringPage()),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AdminPage(admin: admin))),
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: ClipOval(
                      child: Image.network(
                        "http://localhost:3000/${admin['img']}",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${admin['nom']} ${admin['prenom']}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                        Text(admin['email'],
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Tableaux de bord",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3D2E),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Espace Admin"),
        ),
      ],
    );
  }
}

class EntrepriseCarousel extends StatefulWidget {
  const EntrepriseCarousel({super.key});

  @override
  State<EntrepriseCarousel> createState() => _EntrepriseCarouselState();
}

class _EntrepriseCarouselState extends State<EntrepriseCarousel> {
  List entreprises = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadEntreprises();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadEntreprises() async {
    try {
      final res = await http.get(
          Uri.parse("http://localhost:3000/entreprise/list"));
      if (res.statusCode == 200 && mounted) {
        setState(() => entreprises = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Erreur loadEntreprises: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0F3D2E), Color(0xFF1F7A5C)]),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nos entreprises",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text("partenaires",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70)),
            ],
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => _scrollController.animateTo(
                _scrollController.offset - 200,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white, shape: const CircleBorder()),
          ),
          Expanded(
            child: entreprises.isEmpty
                ? const Center(
                    child: Text("Aucune entreprise",
                        style:
                            TextStyle(color: Colors.grey, fontSize: 12)))
                : ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: entreprises.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final e = entreprises[i];
                      return Container(
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.network(
                                "http://localhost:3000/uploads/${e['image']}",
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.business,
                                    color: Colors.grey,
                                    size: 28),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(e['nom'] ?? '',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          IconButton(
            onPressed: () => _scrollController.animateTo(
                _scrollController.offset + 200,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut),
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF0F3D2E),
                foregroundColor: Colors.white,
                shape: const CircleBorder()),
          ),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  final Map admin;
  const AdminPage({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3D2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3D2E),
        elevation: 0,
        title: const Text("Admin Profile"),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                child: ClipOval(
                  child: Image.network(
                    "http://localhost:3000/${admin['img']}",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text("${admin['nom']} ${admin['prenom']}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(admin['email']),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const pagep()),
                  (route) => false,
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Se déconnecter"),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget simplePage(String title) {
  return Scaffold(
    backgroundColor: const Color(0xFF0F3D2E),
    body: Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Text(title,
            style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    ),
  );
}
