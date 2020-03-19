import 'package:flutter_test/flutter_test.dart';
import 'package:restified/restified.dart';

class InventoryType implements Serializable<InventoryType> {
  final int id;
  String name;

  InventoryType({this.id, this.name});

  InventoryType fromJson(Map json) {
    return InventoryType(id: json['id'], name: json['name']);
  }

  @override
  Map<String, dynamic> toJson() => {'name': name};
}

void main() {
  Http http = Http(
    url: 'http://localhost:8101/inventories/types',
  );

  int lastInsertId;
  group('Http', () {
    test('get success', () async {
      HttpResult<InventoryType, int> result =
          await http.getOne('/1', InventoryType());
      expect(result.response.success, true);
      expect(result.data.id, 1);
    });

    test('get fail', () async {
      HttpResult<InventoryType, int> result = await http.getOne(
        '/10000000',
        InventoryType(),
      );
      expect(result.response.success, false);
      expect(result.data, null);
    });

    test('get all success', () async {
      HttpResult<List<InventoryType>, int> result =
          await http.getList('', InventoryType());
      expect(result.response.success, true);
      expect(result.data.length, 5);
    });

    test('get all fail', () async {
      HttpResult<List<InventoryType>, int> result =
          await http.getList('sdsds', InventoryType());
      expect(result.data, null);
      expect(result.response, null);
      expect(result.error, 404);
    });

    test('insert', () async {
      InventoryType p = InventoryType(name: 'test123');
      HttpResult<int, int> result = await http.post('', p.toJson());
      expect(result.response.success, true);
      lastInsertId = result.data;
    });

    test('update', () async {
      InventoryType p = InventoryType(name: 'test2100');
      HttpResult<int, int> result =
          await http.put('/$lastInsertId', p.toJson());
      expect(result.response.success, true);
      expect(result.data, 1);
    });

    test('delete', () async {
      HttpResult<int, int> result = await http.delete('/$lastInsertId');
      expect(result.response.success, true);
      expect(result.data, 1);
    });
  });

  test('update fail', () async {
    InventoryType p = InventoryType(name: 'test2100');
    HttpResult<int, int> result = await http.put('', p.toJson());
    expect(result.response, null);
    expect(result.data, null);
    expect(result.error, 405);
  });

  test('delete fail', () async {
    HttpResult<int, int> result = await http.delete('');
    expect(result.response, null);
    expect(result.data, null);
    expect(result.error, 405);
  });
}
