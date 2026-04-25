import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProfitChart extends StatelessWidget {
  final double expenses;
  final double revenue;

  const ProfitChart({
    super.key,
    required this.expenses,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: expenses,
              color: Colors.red,
              title: 'Dépenses',
            ),
            PieChartSectionData(
              value: revenue,
              color: Colors.green,
              title: 'Revenus',
            ),
          ],
        ),
      ),
    );
  }
}