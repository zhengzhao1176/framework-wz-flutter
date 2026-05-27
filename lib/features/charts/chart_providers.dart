import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import 'chart_models.dart';

abstract class ChartRepository {
  Future<ChartData> fetch(ChartType type);
}

class DioChartRepository implements ChartRepository {
  DioChartRepository(this._dio);
  final Dio _dio;

  @override
  Future<ChartData> fetch(ChartType type) async {
    final res = await _dio.get<Object?>('/api/charts/${type.name}');
    final body = res.data;
    if (body is! Map) {
      return ChartData(type: type, series: const []);
    }
    return ChartData.fromJson(body.cast<String, Object?>());
  }
}

final chartRepositoryProvider = Provider<ChartRepository>(
  (ref) => DioChartRepository(ref.watch(dioProvider)),
);

final chartDataProvider =
    FutureProvider.family<ChartData, ChartType>((ref, type) async {
  return ref.watch(chartRepositoryProvider).fetch(type);
});
