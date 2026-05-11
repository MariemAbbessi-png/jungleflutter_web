import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const _dark       = Color(0xFF0F3D2E);
const _green      = Color(0xFF1F7A5C);
const _lightGreen = Color(0xFFF0FAF5);
const _baseUrl    = 'http://localhost:3000';

class CashbackPage extends StatefulWidget {
  const CashbackPage({super.key});
  @override
  State<CashbackPage> createState() => _CashbackPageState();
}

class _CashbackPageState extends State<CashbackPage> {
  List   _cashbacks     = [];
  double _budgetTotal   = 0;
  double _budgetUtilise = 0;
  double _budgetReste   = 0;
  bool   _isLoading     = true;
  bool   _isPaying      = false;
  bool   _isExporting   = false;

  double get totalPaye => _cashbacks
      .where((c) => (c['statut'] ?? '') == 'paye')
      .fold(0.0, (sum, c) => sum + ((c['montantCashback'] ?? 0) as num).toDouble());

  double get totalEnAttente => _cashbacks
      .where((c) => (c['statut'] ?? '') == 'en_attente')
      .fold(0.0, (sum, c) => sum + ((c['montantCashback'] ?? 0) as num).toDouble());

  int get countEnAttente =>
      _cashbacks.where((c) => (c['statut'] ?? '') == 'en_attente').length;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        http.get(Uri.parse("$_baseUrl/api/cashback")),
        http.get(Uri.parse("$_baseUrl/api/cashback/budget")),
      ]);
      if (!mounted) return;
      if (results[0].statusCode == 200) {
        final body = jsonDecode(results[0].body);
        setState(() => _cashbacks = body is List ? body : []);
      }
      if (results[1].statusCode == 200) {
        final b = jsonDecode(results[1].body);
        setState(() {
          _budgetTotal   = ((b['montantTotal']   ?? 0) as num).toDouble();
          _budgetUtilise = ((b['montantUtilise'] ?? 0) as num).toDouble();
          _budgetReste   = ((b['reste']          ?? 0) as num).toDouble();
        });
      }
    } catch (e) {
      debugPrint("Erreur loadData: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exporterPdf() async {
    setState(() => _isExporting = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final now      = DateTime.now();
    final dateStr  = "${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}";
    final heureStr = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
    final refFacture = "CB-${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}-${now.millisecondsSinceEpoch % 10000}";

    final darkColor  = PdfColor.fromHex('#0F3D2E');
    final greenColor = PdfColor.fromHex('#1F7A5C');
    final lightGreen = PdfColor.fromHex('#F0FAF5');
    final orange     = PdfColor.fromHex('#FF9800');
    final blue       = PdfColor.fromHex('#2196F3');
    final grey       = PdfColor.fromHex('#888888');
    final white      = PdfColors.white;

    final cashbacksPaye    = _cashbacks.where((c) => (c['statut'] ?? '') == 'paye').toList();
    final cashbacksAttente = _cashbacks.where((c) => (c['statut'] ?? '') == 'en_attente').toList();

    List<List<String>> rowsPaye = cashbacksPaye.asMap().entries.map((e) {
      final c      = e.value;
      final user   = c['utilisateurId'];
      return <String>[
        '${e.key + 1}',
        _getNom(user),
        user is Map ? (user['email']?.toString() ?? '—') : '—',
        ((c['montantCashback'] ?? 0) as num).toStringAsFixed(2),
        _formatDate(c['datePaiement']),
      ];
    }).toList();

    List<List<String>> rowsAttente = cashbacksAttente.asMap().entries.map((e) {
      final c    = e.value;
      final user = c['utilisateurId'];
      return <String>[
        '${e.key + 1}',
        _getNom(user),
        user is Map ? (user['email']?.toString() ?? '—') : '—',
        ((c['montantCashback'] ?? 0) as num).toStringAsFixed(2),
        _formatDate(c['dateCreation']),
      ];
    }).toList();

    final tauxUtilisation = _budgetTotal > 0
        ? (_budgetUtilise / _budgetTotal).clamp(0.0, 1.0)
        : 0.0;
    final tauxPct = _budgetTotal > 0
        ? '${(_budgetUtilise / _budgetTotal * 100).toStringAsFixed(4)} %'
        : '0.0000 %';

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (_) => pw.Container(
              decoration: const pw.BoxDecoration(color: PdfColors.white)),
        ),
        build: (ctx) => [

          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
                color: darkColor, borderRadius: pw.BorderRadius.circular(12)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('RAPPORT FINANCIER CASHBACK',
                      style: pw.TextStyle(color: white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  pw.Text('N° $refFacture',
                      style: pw.TextStyle(color: white, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Généré le $dateStr à $heureStr',
                      style: pw.TextStyle(color: PdfColor.fromHex('#A8D5C2'), fontSize: 10)),
                ]),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          pw.Text('Synthèse budgétaire',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: darkColor)),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            _pdfBudgetCard('Budget total',   '${_budgetTotal.toStringAsFixed(2)} TND',   darkColor,  lightGreen,                    darkColor),
            pw.SizedBox(width: 12),
            _pdfBudgetCard('Budget utilisé', '${_budgetUtilise.toStringAsFixed(2)} TND', blue,       PdfColor.fromHex('#E3F2FD'),   blue),
            pw.SizedBox(width: 12),
            _pdfBudgetCard('Budget restant', '${_budgetReste.toStringAsFixed(2)} TND',   greenColor, lightGreen,                    greenColor),
          ]),

          pw.SizedBox(height: 16),

          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: lightGreen,
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: greenColor, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Taux d'utilisation du budget",
                        style: pw.TextStyle(fontSize: 11, color: darkColor, fontWeight: pw.FontWeight.bold)),
                    pw.Text(tauxPct,
                        style: pw.TextStyle(fontSize: 11, color: greenColor, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  height: 10,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#D0EDE2'),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(children: [
                    pw.Expanded(
                      flex: (tauxUtilisation * 1000).round(),
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: greenColor,
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: ((1 - tauxUtilisation) * 1000).round().clamp(1, 1000),
                      child: pw.Container(),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          pw.Text('Récapitulatif des cashbacks',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: darkColor)),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            _pdfStatCard('Total versé',      '${totalPaye.toStringAsFixed(2)} TND',      '${cashbacksPaye.length} client(s)',    greenColor),
            pw.SizedBox(width: 12),
            _pdfStatCard('En attente',       '${totalEnAttente.toStringAsFixed(2)} TND', '$countEnAttente client(s)',             orange),
            pw.SizedBox(width: 12),
            _pdfStatCard('Total cashbacks',  '${_cashbacks.length}',                      'enregistrements',                     darkColor),
          ]),

          pw.SizedBox(height: 24),

          if (cashbacksPaye.isNotEmpty) ...[
            _pdfSectionTitle('Cashbacks versés aux clients', greenColor),
            pw.SizedBox(height: 8),
            _pdfTable(
              headers: ['#', 'Client', 'Email', 'Montant (TND)', 'Date versement'],
              rows: rowsPaye,
              headerColor: darkColor,
              rowAltColor: lightGreen,
              accentCol: 3,
              accentColor: greenColor,
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(color: darkColor, borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('TOTAL VERSÉ', style: pw.TextStyle(color: white, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('${totalPaye.toStringAsFixed(2)} TND', style: pw.TextStyle(color: white, fontSize: 13, fontWeight: pw.FontWeight.bold)),
              ]),
            ),
            pw.SizedBox(height: 24),
          ],

          if (cashbacksAttente.isNotEmpty) ...[
            _pdfSectionTitle('Cashbacks en attente de versement', orange),
            pw.SizedBox(height: 8),
            _pdfTable(
              headers: ['#', 'Client', 'Email', 'Montant (TND)', 'Date création'],
              rows: rowsAttente,
              headerColor: orange,
              rowAltColor: PdfColor.fromHex('#FFF8E1'),
              accentCol: 3,
              accentColor: orange,
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(color: orange, borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('TOTAL EN ATTENTE', style: pw.TextStyle(color: white, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('${totalEnAttente.toStringAsFixed(2)} TND', style: pw.TextStyle(color: white, fontSize: 13, fontWeight: pw.FontWeight.bold)),
              ]),
            ),
            pw.SizedBox(height: 24),
          ],

          pw.Divider(color: grey, thickness: 0.5),
          pw.SizedBox(height: 8),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            
            pw.Text('Réf. $refFacture | $dateStr',
                style: pw.TextStyle(color: grey, fontSize: 9)),
          ]),
        ],
      ),
    );

    if (!mounted) return;
    setState(() => _isExporting = false);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'rapport_cashback_$dateStr.pdf',
    );

    scaffoldMessenger.showSnackBar(const SnackBar(
      content: Text('✅ PDF généré avec succès'),
      backgroundColor: _green,
    ));
  }


  pw.Widget _pdfBudgetCard(String label, String value,
      PdfColor textColor, PdfColor bgColor, PdfColor borderColor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: borderColor, width: 0.5),
        ),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#666666'))),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textColor)),
        ]),
      ),
    );
  }

  pw.Widget _pdfStatCard(String label, String value, String sub, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: color, width: 0.8),
        ),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#666666'))),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: color)),
          pw.Text(sub,   style: pw.TextStyle(fontSize: 9,  color: PdfColor.fromHex('#888888'))),
        ]),
      ),
    );
  }

  pw.Widget _pdfSectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Text(title,
          style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _pdfTable({
    required List<String>       headers,
    required List<List<String>> rows,       
    required PdfColor           headerColor,
    required PdfColor           rowAltColor,
    required int                accentCol,
    required PdfColor           accentColor,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(24),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: headers.map((h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: pw.Text(h, style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
          )).toList(),
        ),
        ...rows.asMap().entries.map((entry) {
          final isEven = entry.key % 2 == 0;
          final row    = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: isEven ? PdfColors.white : rowAltColor),
            children: row.asMap().entries.map((cell) {
              final isAccent = cell.key == accentCol;
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: pw.Text(
                  cell.value,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: isAccent ? accentColor : PdfColor.fromHex('#333333'),
                    fontWeight: isAccent ? pw.FontWeight.bold : pw.FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Future<void> payerTous() async {
    if (!mounted) return;
    if (countEnAttente == 0) { _showSnack("Aucun cashback en attente", Colors.orange); return; }
    if (_budgetReste < totalEnAttente) { _showSnack("Budget insuffisant ", Colors.red); return; }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.payments_outlined, color: _dark), SizedBox(width: 8), Text("Confirmer le paiement")]),
        content: Text("Payer $countEnAttente cashback(s) en attente ?\n\nMontant total : ${totalEnAttente.toStringAsFixed(2)} TND"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler", style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: _dark), child: const Text("Confirmer")),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    setState(() => _isPaying = true);

    try {
      final res = await http.post(Uri.parse("$_baseUrl/api/cashback/payer-all"), headers: {"Content-Type": "application/json"});
      if (!mounted) return;
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        await loadData();
        if (!mounted) return;
        setState(() => _isPaying = false);
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text("✅ ${body['message']} — Total: ${((body['total'] ?? 0) as num).toStringAsFixed(2)} TND"),
          backgroundColor: _green, duration: const Duration(seconds: 3),
        ));
      } else {
        setState(() => _isPaying = false);
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(body['message'] ?? "Erreur"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Impossible de contacter le serveur"), backgroundColor: Colors.red));
    }
  }

  Future<void> _payerUnCashback(String cashbackId) async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.payment, color: _dark), SizedBox(width: 8), Text("Confirmer le paiement")]),
        content: const Text("Payer ce cashback ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler", style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: _dark), child: const Text("Confirmer")),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;

    try {
      final res = await http.post(Uri.parse("$_baseUrl/api/cashback/payer/$cashbackId"), headers: {"Content-Type": "application/json"});
      if (!mounted) return;
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        await loadData();
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text("✅ Cashback payé avec succès"), backgroundColor: _green));
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(body['message'] ?? "Erreur"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Impossible de contacter le serveur"), backgroundColor: Colors.red));
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  String _getNom(dynamic u) {
    if (u == null) return '—';
    if (u is Map) {
      final nom    = u['nom']?.toString()    ?? '';
      final prenom = u['prenom']?.toString() ?? '';
      if (nom.isNotEmpty || prenom.isNotEmpty) return '$prenom $nom'.trim();
      final email = u['email']?.toString() ?? '';
      if (email.isNotEmpty) return email;
    }
    return '—';
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    try {
      final d = DateTime.parse(date.toString());
      return "${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}";
    } catch (_) { return '—'; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _dark))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: _dark),
                      style: IconButton.styleFrom(backgroundColor: _lightGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.monetization_on_outlined, color: _dark, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Tableau de bord Cashback",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _dark)),
                        Text("Gestion et suivi des cashbacks",
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ]),
                    ),
                    IconButton(
                      onPressed: _isExporting ? null : _exporterPdf,
                      tooltip: 'Télécharger le rapport PDF',
                      icon: _isExporting
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(color: _dark, strokeWidth: 2))
                          : const Icon(Icons.picture_as_pdf, color: _dark),
                      style: IconButton.styleFrom(backgroundColor: _lightGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: loadData,
                      icon: const Icon(Icons.refresh, color: _dark),
                      style: IconButton.styleFrom(backgroundColor: _lightGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isPaying ? null : payerTous,
                      icon: _isPaying
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.payments_outlined),
                      label: Text(_isPaying ? "Paiement..." : "Payer les cashbacks"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dark, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  Row(children: [
                    Expanded(child: _StatCard(
                      title: "Budget cashback", icon: Icons.account_balance_outlined,
                      iconColor: _dark, bgColor: _lightGreen,
                      items: [
                        _StatItem(label: "Budget total",    value: "${_budgetTotal.toStringAsFixed(2)} TND",   color: _dark,                   icon: Icons.savings_outlined),
                        _StatItem(label: "Budget utilisé",  value: "${_budgetUtilise.toStringAsFixed(2)} TND", color: const Color(0xFF2196F3), icon: Icons.outbox_outlined),
                        _StatItem(label: "Budget restant",  value: "${_budgetReste.toStringAsFixed(2)} TND",   color: _green,                  icon: Icons.account_balance_wallet_outlined),
                      ],
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _StatCard(
                      title: "Récapitulatif cashback", icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xFF4CAF50), bgColor: const Color(0xFFF1FFF6),
                      items: [
                        _StatItem(label: "Total versé aux clients", value: "${totalPaye.toStringAsFixed(2)} TND",
                            color: const Color(0xFF4CAF50), icon: Icons.check_circle_outline),
                      ],
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _StatCard(
                      title: "Cashback en attente", icon: Icons.hourglass_empty_outlined,
                      iconColor: const Color(0xFFFF9800), bgColor: const Color(0xFFFFFBF0),
                      items: [
                        _StatItem(label: "Montant restant à verser", value: "${totalEnAttente.toStringAsFixed(2)} TND",
                            color: const Color(0xFFFF9800), icon: Icons.pending_outlined),
                        _StatItem(label: "Nombre en attente", value: "$countEnAttente clients",
                            color: Colors.grey.shade700, icon: Icons.people_outline),
                      ],
                    )),
                  ]),

                  const SizedBox(height: 24),

                  const Text("Détail des cashbacks",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _dark)),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _cashbacks.isEmpty
                        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text("Aucun cashback trouvé", style: TextStyle(color: Colors.grey.shade400)),
                          ]))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SingleChildScrollView(
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2.5), 1: FlexColumnWidth(1.5),
                                  2: FlexColumnWidth(1.5), 3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(1.2),
                                },
                                children: [
                                  TableRow(
                                    decoration: const BoxDecoration(color: _dark),
                                    children: [
                                      _tableHeader("Utilisateur"), _tableHeader("Montant (TND)"),
                                      _tableHeader("Statut"), _tableHeader("Date paiement"),
                                      _tableHeader("Action"),
                                    ],
                                  ),
                                  ..._cashbacks.asMap().entries.map((entry) {
                                    final i      = entry.key;
                                    final c      = entry.value;
                                    final isPaye = (c['statut'] ?? '') == 'paye';
                                    final isEven = i % 2 == 0;
                                    final nom    = _getNom(c['utilisateurId']);
                                    final init   = nom.isNotEmpty && nom != '—' ? nom[0].toUpperCase() : '?';
                                    final cbId   = c['_id']?.toString() ?? '';
                                    return TableRow(
                                      decoration: BoxDecoration(color: isEven ? Colors.white : _lightGreen),
                                      children: [
                                        _tableCell(Row(children: [
                                          CircleAvatar(radius: 14, backgroundColor: _dark.withOpacity(0.1),
                                              child: Text(init, style: const TextStyle(fontSize: 11, color: _dark, fontWeight: FontWeight.bold))),
                                          const SizedBox(width: 8),
                                          Flexible(child: Text(nom, overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w500))),
                                        ])),
                                        _tableCell(Text(
                                          ((c['montantCashback'] ?? 0) as num).toStringAsFixed(2),
                                          style: TextStyle(fontWeight: FontWeight.bold,
                                              color: isPaye ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)),
                                        )),
                                        _tableCell(Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isPaye ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(isPaye ? "✓ Payé" : "En attente",
                                              style: TextStyle(
                                                  color: isPaye ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                                                  fontSize: 12, fontWeight: FontWeight.w600)),
                                        )),
                                        _tableCell(Text(_formatDate(c['datePaiement']),
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
                                        _tableCell(isPaye
                                            ? const SizedBox.shrink()
                                            : GestureDetector(
                                                onTap: cbId.isEmpty ? null : () => _payerUnCashback(cbId),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(color: _dark, borderRadius: BorderRadius.circular(8)),
                                                  child: const Text("Payer", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                                ),
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

  static TableCell _tableHeader(String t) => TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );

  static TableCell _tableCell(Widget child) => TableCell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: child,
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor, bgColor;
  final List<_StatItem> items;
  const _StatCard({required this.title, required this.icon,
      required this.iconColor, required this.bgColor, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _dark))),
        ]),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Icon(item.icon, color: item.color, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              const SizedBox(height: 2),
              Text(item.value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: item.color)),
            ])),
          ]),
        )),
      ]),
    );
  }
}

class _StatItem {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.color, required this.icon});
}