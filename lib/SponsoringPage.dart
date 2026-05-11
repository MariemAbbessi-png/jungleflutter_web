import 'package:flutter/material.dart';



const kPrimary = Color(0xFF0F3D2E);
const kPrimaryLight = Color(0xFF1F7A5C);
const kAccent = Color(0xFF4CAF50);
const kBg = Color(0xFFF4F6FB);
const kWhite = Colors.white;
const kBorder = Color(0xFFE8EAF0);
const kTextPrimary = Color(0xFF111827);
const kTextSecondary = Color(0xFF6B7280);
const kTextMuted = Color(0xFF9CA3AF);


class SponsoredProduct {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int level;
  final String startDate;
  final String endDate;
  final int impressions;
  final int clicks;
  bool isActive;

  SponsoredProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.level,
    required this.startDate,
    required this.endDate,
    required this.impressions,
    required this.clicks,
    required this.isActive,
  });

  double get ctr =>
      impressions > 0 ? (clicks / impressions) * 100 : 0;
}


List<SponsoredProduct> mockProducts = [
  SponsoredProduct(
    id: '1', name: 'MacBook Pro M3', sku: '#4821',
    category: 'Electronics', level: 5,
    startDate: '01 Jan', endDate: '31 Jan 2026',
    impressions: 32140, clicks: 2870, isActive: true,
  ),
  SponsoredProduct(
    id: '2', name: 'Nike Air Max 270', sku: '#3107',
    category: 'Fashion', level: 4,
    startDate: '05 Jan', endDate: '20 Fév 2026',
    impressions: 21500, clicks: 1640, isActive: true,
  ),
  SponsoredProduct(
    id: '3', name: 'Canapé Convertible', sku: '#1984',
    category: 'Maison', level: 3,
    startDate: '10 Jan', endDate: '10 Fév 2026',
    impressions: 14220, clicks: 790, isActive: false,
  ),
  SponsoredProduct(
    id: '4', name: 'Samsung Galaxy S25', sku: '#5530',
    category: 'Electronics', level: 5,
    startDate: '15 Jan', endDate: '28 Fév 2026',
    impressions: 29870, clicks: 2410, isActive: true,
  ),
  SponsoredProduct(
    id: '5', name: 'Panier Bio Saison', sku: '#0291',
    category: 'Alimentation', level: 2,
    startDate: '20 Jan', endDate: '05 Fév 2026',
    impressions: 8100, clicks: 500, isActive: false,
  ),
];


class SponsoringPage extends StatefulWidget {
  const SponsoringPage({super.key});

  @override
  State<SponsoringPage> createState() => _SponsoringPageState();
}

class _SponsoringPageState extends State<SponsoringPage> {
  List<SponsoredProduct> products = List.from(mockProducts);
  String searchQuery = '';
  String selectedCategory = 'Tous';
  String selectedStatus = 'Tous';

  List<SponsoredProduct> get filtered {
    return products.where((p) {
      final matchSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchCat = selectedCategory == 'Tous' || p.category == selectedCategory;
      final matchStatus = selectedStatus == 'Tous' ||
          (selectedStatus == 'Actif' && p.isActive) ||
          (selectedStatus == 'Inactif' && !p.isActive);
      return matchSearch && matchCat && matchStatus;
    }).toList();
  }

  int get totalImpressions =>
      products.fold(0, (s, p) => s + p.impressions);
  int get totalClicks =>
      products.fold(0, (s, p) => s + p.clicks);
  double get avgCtr =>
      totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0;
  int get activeCount => products.where((p) => p.isActive).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const _Sidebar(),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  onSearch: (v) => setState(() => searchQuery = v),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PageHeader(activeCount: activeCount),
                        const SizedBox(height: 22),
                        _StatsRow(
                          sponsored: products.length,
                          impressions: totalImpressions,
                          clicks: totalClicks,
                          ctr: avgCtr,
                        ),
                        const SizedBox(height: 22),
                        _TableSection(
                          products: filtered,
                          selectedCategory: selectedCategory,
                          selectedStatus: selectedStatus,
                          onCategoryChanged: (v) =>
                              setState(() => selectedCategory = v!),
                          onStatusChanged: (v) =>
                              setState(() => selectedStatus = v!),
                          onToggle: (p, val) =>
                              setState(() => p.isActive = val),
                          onDelete: (p) =>
                              setState(() => products.remove(p)),
                        ),
                        const SizedBox(height: 18),
                        const _InfoPanel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: kPrimary,
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kAccent, kPrimaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco, color: kWhite, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('JungleAdmin',
                    style: TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          _sectionLabel('Navigation'),
          _navItem(context, Icons.dashboard_outlined, 'Dashboard', false),
          _navItem(context, Icons.shopping_cart_outlined, 'Produits', false),
          _navItem(context, Icons.receipt_long_outlined, 'Commandes', false),
          _navItem(context, Icons.people_outline, 'Clients', false),
          _navItem(context, Icons.category_outlined, 'Catégories', false),
          const SizedBox(height: 8),
          _sectionLabel('Marketing'),
          _navItem(context, Icons.star_outline, 'Sponsoring', true,
              badge: '8'),
          _navItem(context, Icons.bar_chart_outlined, 'Statistiques', false),
          const SizedBox(height: 8),
          _sectionLabel('Système'),
          _navItem(context, Icons.settings_outlined, 'Paramètres', false),
          const Spacer(),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [kAccent, kPrimaryLight]),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Center(
                    child: Text('AB',
                        style: TextStyle(
                            color: kWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Admin Brahim',
                        style: TextStyle(
                            color: kWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    Text('Super Admin',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
        child: Text(label.toUpperCase(),
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500)),
      );

  Widget _navItem(BuildContext ctx, IconData icon, String title, bool active,
      {String? badge}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: active
            ? kAccent.withOpacity(0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            color: active ? kAccent : Colors.white60, size: 19),
        title: Text(title,
            style: TextStyle(
                color: active ? kAccent : Colors.white70,
                fontSize: 13,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.normal)),
        trailing: badge != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(badge,
                    style: const TextStyle(
                        color: kWhite, fontSize: 10, fontWeight: FontWeight.w600)),
              )
            : null,
        onTap: () {},
      ),
    );
  }
}


class _TopBar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  const _TopBar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(9),
              ),
              child: TextField(
                onChanged: onSearch,
                style: const TextStyle(fontSize: 13, color: kTextPrimary),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un produit...',
                  hintStyle: TextStyle(fontSize: 13, color: kTextMuted),
                  prefixIcon: Icon(Icons.search, size: 18, color: kTextMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const Spacer(),
          _iconBtn(
            child: Stack(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 20, color: kTextSecondary),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _iconBtn(
              child: const Icon(Icons.help_outline,
                  size: 20, color: kTextSecondary)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
            decoration: BoxDecoration(
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [kAccent, kPrimaryLight]),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text('AB',
                        style: TextStyle(
                            color: kWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Admin Brahim',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: kTextMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({required Widget child}) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(9)),
        child: Center(child: child),
      );
}


class _PageHeader extends StatelessWidget {
  final int activeCount;
  const _PageHeader({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Gestion du Sponsoring',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                      letterSpacing: -0.3)),
              SizedBox(height: 4),
              Text(
                'Gérer les produits sponsorisés qui apparaissent en priorité sur l\'app',
                style: TextStyle(fontSize: 13, color: kTextSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_outlined, size: 16),
          label: const Text('Exporter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: kTextPrimary,
            side: const BorderSide(color: kBorder),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9)),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            textStyle: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Ajouter un sponsoring'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: kWhite,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9)),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}


class _StatsRow extends StatelessWidget {
  final int sponsored;
  final int impressions;
  final int clicks;
  final double ctr;
  const _StatsRow(
      {required this.sponsored,
      required this.impressions,
      required this.clicks,
      required this.ctr});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star_outline,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: kPrimary,
            value: '$sponsored',
            label: 'Produits sponsorisés',
            trend: '+2 ce mois',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.visibility_outlined,
            iconBg: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF2563EB),
            value: _fmt(impressions),
            label: 'Total impressions',
            trend: '+12.4%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.ads_click_outlined,
            iconBg: const Color(0xFFCCFBF1),
            iconColor: const Color(0xFF0D9488),
            value: _fmt(clicks),
            label: 'Total clics',
            trend: '+8.1%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: Icons.percent_outlined,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            value: '${ctr.toStringAsFixed(2)}%',
            label: 'CTR moyen',
            trend: '-0.3% vs mois dernier',
            trendUp: false,
          ),
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return '$n';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kWhite,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                  letterSpacing: -0.5)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: kTextMuted)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                trendUp
                    ? Icons.trending_up
                    : Icons.trending_down,
                size: 14,
                color: trendUp
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 4),
              Text(trend,
                  style: TextStyle(
                      fontSize: 11,
                      color: trendUp
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))),
            ],
          ),
        ],
      ),
    );
  }
}


class _TableSection extends StatelessWidget {
  final List<SponsoredProduct> products;
  final String selectedCategory;
  final String selectedStatus;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final Function(SponsoredProduct, bool) onToggle;
  final Function(SponsoredProduct) onDelete;

  const _TableSection({
    required this.products,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                const Text('Liste des produits sponsorisés',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary)),
                const Spacer(),
                _filterDropdown(
                  value: selectedCategory,
                  items: const [
                    'Tous', 'Electronics', 'Fashion',
                    'Maison', 'Alimentation'
                  ],
                  onChanged: onCategoryChanged,
                  hint: 'Catégorie',
                ),
                const SizedBox(width: 8),
                _filterDropdown(
                  value: selectedStatus,
                  items: const ['Tous', 'Actif', 'Inactif'],
                  onChanged: onStatusChanged,
                  hint: 'Statut',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _tableHeader(),
          const Divider(height: 1, color: kBorder),
          ...products.map((p) => _ProductRow(
                product: p,
                onToggle: (val) => onToggle(p, val),
                onDelete: () => onDelete(p),
              )),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Text('${products.length} produits affichés',
                    style: const TextStyle(
                        fontSize: 12, color: kTextMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(
                            fontSize: 12, color: kTextPrimary)),
                  ))
              .toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 12, color: kTextPrimary),
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 16, color: kTextMuted),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    const style = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: kTextMuted,
        letterSpacing: 0.4);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('PRODUIT', style: style)),
          Expanded(flex: 2, child: Text('CATÉGORIE', style: style)),
          Expanded(flex: 1, child: Text('STATUT', style: style)),
          Expanded(flex: 2, child: Text('NIVEAU', style: style)),
          Expanded(flex: 2, child: Text('DATES', style: style)),
          Expanded(flex: 2, child: Text('IMPRESSIONS', style: style)),
          Expanded(flex: 1, child: Text('CLICS', style: style)),
          Expanded(flex: 1, child: Text('CTR', style: style)),
          Expanded(flex: 1, child: Text('ACTIONS', style: style)),
        ],
      ),
    );
  }
}


class _ProductRow extends StatelessWidget {
  final SponsoredProduct product;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF7F7FB)))),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      _categoryIcon(product.category),
                      size: 18,
                      color: kTextMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: kTextPrimary),
                            overflow: TextOverflow.ellipsis),
                        Text('SKU ${product.sku}',
                            style: const TextStyle(
                                fontSize: 11, color: kTextMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _CategoryBadge(product.category),
            ),
            // Toggle
            Expanded(
              flex: 1,
              child: Switch(
                value: product.isActive,
                onChanged: onToggle,
                activeColor: kPrimary,
                materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            // Stars level
            Expanded(
              flex: 2,
              child: Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < product.level
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 15,
                    color: i < product.level
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFD1D5DB),
                  );
                }),
              ),
            ),
            // Dates
            Expanded(
              flex: 2,
              child: Text(
                '${product.startDate} → ${product.endDate}',
                style: const TextStyle(
                    fontSize: 11, color: kTextSecondary),
              ),
            ),
            // Impressions
            Expanded(
              flex: 2,
              child: Text(
                _fmt(product.impressions),
                style: const TextStyle(
                    fontSize: 13,
                    color: kTextPrimary,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
            // Clicks
            Expanded(
              flex: 1,
              child: Text(
                _fmt(product.clicks),
                style: const TextStyle(
                    fontSize: 13, color: kTextPrimary),
              ),
            ),
            // CTR
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '${product.ctr.toStringAsFixed(2)}%',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: kPrimary),
                ),
              ),
            ),
            // Actions
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  _actionBtn(
                    icon: Icons.edit_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(
                    icon: Icons.delete_outline,
                    onTap: onDelete,
                    danger: true,
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
      required VoidCallback onTap,
      bool danger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: kWhite,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon,
            size: 15,
            color: danger
                ? const Color(0xFFEF4444)
                : kTextSecondary),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Electronics':
        return Icons.devices_outlined;
      case 'Fashion':
        return Icons.checkroom_outlined;
      case 'Maison':
        return Icons.weekend_outlined;
      case 'Alimentation':
        return Icons.eco_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _fmt(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k'
      : '$n';
}


class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge(this.category);

  @override
  Widget build(BuildContext context) {
    final colors = _colors(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(category,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.$2)),
    );
  }

  (Color, Color) _colors(String cat) {
    switch (cat) {
      case 'Electronics':
        return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF));
      case 'Fashion':
        return (const Color(0xFFEDE9FE), const Color(0xFF5B21B6));
      case 'Maison':
        return (const Color(0xFFFEF3C7), const Color(0xFF92400E));
      case 'Alimentation':
        return (const Color(0xFFD1FAE5), const Color(0xFF065F46));
      default:
        return (const Color(0xFFF3F4F6), kTextSecondary);
    }
  }
}



class _InfoPanel extends StatelessWidget {
  const _InfoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD1FAE5), Color(0xFFE8F5E9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: kAccent.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.info_outline,
                color: kWhite, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Comment fonctionne le sponsoring ?',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kPrimary)),
                SizedBox(height: 6),
                Text(
                  'Les produits avec un niveau de sponsoring plus élevé (1–5) apparaissent en premier dans les recommandations et la page d\'accueil de l\'app. '
                  'Les produits de niveau 5 occupent le slot bannière principal, tandis que les niveaux 3–4 apparaissent dans la ligne "à la une". '
                  'Les produits inactifs sont immédiatement masqués de toutes les surfaces. '
                  'Les impressions et les clics sont suivis en temps réel — surveillez le CTR pour optimiser vos placements sponsorisés.',
                  style: TextStyle(
                      fontSize: 13,
                      color: kPrimaryLight,
                      height: 1.6),
                ),
              ],

            ),
          ),
        ],
      ),
    );
  }
}