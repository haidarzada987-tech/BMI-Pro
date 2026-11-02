import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/storage/storage_service.dart';
import '../../models/weight_entry.dart';

class WeightHistoryPage extends StatefulWidget {
  const WeightHistoryPage({super.key});

  @override
  State<WeightHistoryPage> createState() => _WeightHistoryPageState();
}

class _WeightHistoryPageState extends State<WeightHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final list = StorageService.getWeightHistory()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('history'))),
      body: list.isEmpty
          ? Center(child: Text(context.tr('noHistory')))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (list.length >= 2) _chartCard(context, list),
                const SizedBox(height: 12),
                ...list.reversed.map(
                  (entry) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.monitor_weight_outlined),
                      title: Text('${entry.weightKg.toStringAsFixed(1)} kg'),
                      subtitle: Text(_date(entry)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _chartCard(BuildContext context, List<WeightEntry> entries) {
    final spots = [
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].weightKg),
    ];
    final minWeight =
        entries.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    final maxWeight =
        entries.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
    final range = (maxWeight - minWeight).abs();
    final padding = range < 1 ? 1.0 : range * 0.15;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
        child: SizedBox(
          height: 230,
          child: LineChart(
            LineChartData(
              minY: (minWeight - padding).clamp(0.0, double.infinity),
              maxY: maxWeight + padding,
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: entries.length > 6
                        ? (entries.length / 5).ceilToDouble()
                        : 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final d = entries[index].date;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text('${d.day}/${d.month}',
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: const FlDotData(show: true),
                  barWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _date(WeightEntry entry) =>
      '${entry.date.day}/${entry.date.month}/${entry.date.year}';
}
