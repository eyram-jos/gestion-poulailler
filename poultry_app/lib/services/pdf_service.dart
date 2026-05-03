import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/wave.dart';

class PdfService {
  static Future<void> generateReport({
    required double totalExpenses,
    required double totalRevenue,
    required double profit,
    required int mortality,
    List<Wave> waves = const [],
    Wave? activeWave,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    String money(double value) {
      return '${value.toStringAsFixed(0)} FCFA';
    }

    String date(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    final totalChicks = waves.fold<int>(0, (sum, w) => sum + w.chicks);
    final activeWaves = waves.where((w) => w.isActive).length;
    final inactiveWaves = waves.where((w) => !w.isActive).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            // HEADER
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.green800,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'OG PoultryPro',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Rapport professionnel de gestion avicole',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 18),

            pw.Text(
              'Date du rapport : ${date(now)}',
              style: const pw.TextStyle(fontSize: 11),
            ),

            pw.SizedBox(height: 20),

            // RESUME
            pw.Text(
              'Résumé général',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                _row('Dépenses totales', money(totalExpenses)),
                _row('Revenus totaux', money(totalRevenue)),
                _row(
                  'Bénéfice net',
                  money(profit),
                  valueColor: profit >= 0 ? PdfColors.green800 : PdfColors.red,
                ),
                _row('Mortalité totale', '$mortality poulets'),
                _row('Nombre total de vagues', '${waves.length}'),
                _row('Vagues actives', '$activeWaves'),
                _row('Vagues terminées / inactives', '$inactiveWaves'),
                _row('Cheptel total enregistré', '$totalChicks poussins'),
              ],
            ),

            pw.SizedBox(height: 22),

            // VAGUE ACTIVE
            if (activeWave != null) ...[
              pw.Text(
                'Vague active',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green700),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Nom : ${activeWave.name}'),
                    pw.Text('Nombre de poussins : ${activeWave.chicks}'),
                    pw.Text('Date de début : ${date(activeWave.startDate)}'),
                    pw.Text('Statut : Active'),
                  ],
                ),
              ),
              pw.SizedBox(height: 22),
            ],

            // LISTE DES VAGUES
            pw.Text(
              'Détail des vagues',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            if (waves.isEmpty)
              pw.Text('Aucune vague enregistrée.')
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.green100,
                    ),
                    children: [
                      _cell('Nom', bold: true),
                      _cell('Poussins', bold: true),
                      _cell('Début', bold: true),
                      _cell('Statut', bold: true),
                    ],
                  ),
                  ...waves.map(
                    (w) => pw.TableRow(
                      children: [
                        _cell(w.name),
                        _cell('${w.chicks}'),
                        _cell(date(w.startDate)),
                        _cell(w.isActive ? 'Active' : 'Terminée'),
                      ],
                    ),
                  ),
                ],
              ),

            pw.SizedBox(height: 22),

            // ANALYSE
            pw.Text(
              'Analyse de performance',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: profit >= 0 ? PdfColors.green50 : PdfColors.red50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                profit >= 0
                    ? 'Votre activité présente actuellement un bénéfice positif. Continuez à suivre régulièrement vos dépenses, ventes et mortalités pour maintenir une bonne rentabilité.'
                    : 'Votre activité présente actuellement une perte. Il est conseillé de revoir les dépenses, les pertes et les prix de vente afin d’améliorer la rentabilité.',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),

            pw.SizedBox(height: 22),

            // FOOTER
            pw.Divider(),

            pw.Text(
              'Rapport généré automatiquement par OG PoultryPro.',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.Text(
              'OG PoultryPro — Le copilote de votre élevage.',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.TableRow _row(
    String label,
    String value, {
    PdfColor valueColor = PdfColors.black,
  }) {
    return pw.TableRow(
      children: [
        _cell(label, bold: true),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}