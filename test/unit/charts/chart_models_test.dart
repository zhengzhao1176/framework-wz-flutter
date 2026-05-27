import 'package:flutter_test/flutter_test.dart';
import 'package:framework_wz/features/charts/chart_models.dart';

void main() {
  test('ChartType.fromString maps known + falls back to shop', () {
    expect(ChartType.fromString('shopchart'), ChartType.shop);
    expect(ChartType.fromString('shop'), ChartType.shop);
    expect(ChartType.fromString('bar'), ChartType.shop);
    expect(ChartType.fromString('radarchart'), ChartType.radar);
    expect(ChartType.fromString('cakechart'), ChartType.cake);
    expect(ChartType.fromString('pie'), ChartType.cake);
    expect(ChartType.fromString('nope'), ChartType.shop);
  });

  test('ChartData.isEmpty true when all series empty', () {
    const data = ChartData(type: ChartType.shop, series: []);
    expect(data.isEmpty, isTrue);
  });

  test('ChartData.fromJson decodes nested series', () {
    final data = ChartData.fromJson({
      'type': 'shopchart',
      'xLabels': ['a', 'b'],
      'series': [
        {
          'name': 's1',
          'points': [
            {'label': 'a', 'value': 1},
            {'label': 'b', 'value': 2},
          ],
        },
      ],
    });
    expect(data.type, ChartType.shop);
    expect(data.series.single.points.map((p) => p.value), [1, 2]);
    expect(data.xLabels, ['a', 'b']);
    expect(data.isEmpty, isFalse);
  });
}
