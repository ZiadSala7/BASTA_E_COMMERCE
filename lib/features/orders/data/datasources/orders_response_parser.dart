List<dynamic> ordersDataList(dynamic data) {
  if (data is List) return data;
  if (data is! Map) return const [];
  final directData = data['data'];
  if (directData is List) return directData;
  if (directData is Map && directData['orders'] is List) {
    return directData['orders'] as List;
  }
  return data['orders'] is List ? data['orders'] as List : const [];
}

Map<String, dynamic> responseMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

Map<String, dynamic> orderFromVerification(Map<String, dynamic> body) {
  final data = responseMap(body['data']);
  final directOrder = responseMap(body['order']);
  final nestedOrder = responseMap(data['order']);
  if (directOrder.isNotEmpty) return directOrder;
  if (nestedOrder.isNotEmpty) return nestedOrder;
  return data.isNotEmpty ? data : body;
}
