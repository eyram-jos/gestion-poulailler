import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateReport({
    required double totalExpenses,
    required double totalRevenue,
    required double profit,
    required int mortality,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PoultryPro - Rapport', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),

              pw.Text('Dépenses: $totalExpenses FCFA'),
              pw.Text('Revenus: $totalRevenue FCFA'),
              pw.Text('Bénéfice: $profit FCFA'),
              pw.Text('Mortalité: $mortality'),

              pw.SizedBox(height: 20),
              pw.Text('Merci d\'utiliser PoultryPro'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}