enum ChartType {
  shop,
  radar,
  cake;

  static ChartType fromString(String s) => switch (s) {
        'shopchart' || 'shop' || 'line' || 'bar' => ChartType.shop,
        'radarchart' || 'radar' => ChartType.radar,
        'cakechart' || 'cake' || 'pie' => ChartType.cake,
        _ => ChartType.shop,
      };

  String get slug => switch (this) {
        ChartType.shop => 'shopchart',
        ChartType.radar => 'radarchart',
        ChartType.cake => 'cakechart',
      };

  String get label => switch (this) {
        ChartType.shop => '商场统计图表',
        ChartType.radar => '雷达图',
        ChartType.cake => '蛋糕销量图表',
      };

  String get subtitle => switch (this) {
        ChartType.shop => '本年商场顾客男女人数统计',
        ChartType.radar => '雷达图',
        ChartType.cake => '蛋糕销量',
      };
}

class ChartPoint {
  const ChartPoint({required this.label, required this.value});
  final String label;
  final double value;

  factory ChartPoint.fromJson(Map<String, Object?> j) => ChartPoint(
        label: j['label']!.toString(),
        value: (j['value']! as num).toDouble(),
      );
}

class ChartSeries {
  const ChartSeries({required this.name, required this.points});
  final String name;
  final List<ChartPoint> points;

  factory ChartSeries.fromJson(Map<String, Object?> j) => ChartSeries(
        name: j['name']!.toString(),
        points: (j['points'] as List? ?? const [])
            .cast<Map<String, Object?>>()
            .map(ChartPoint.fromJson)
            .toList(growable: false),
      );
}

class ChartData {
  const ChartData({required this.type, required this.series, this.xLabels = const []});
  final ChartType type;
  final List<ChartSeries> series;
  final List<String> xLabels;

  bool get isEmpty => series.every((s) => s.points.isEmpty);

  factory ChartData.fromJson(Map<String, Object?> j) => ChartData(
        type: ChartType.fromString(j['type']?.toString() ?? 'shop'),
        xLabels: (j['xLabels'] as List?)?.cast<String>() ?? const [],
        series: (j['series'] as List? ?? const [])
            .cast<Map<String, Object?>>()
            .map(ChartSeries.fromJson)
            .toList(growable: false),
      );
}
