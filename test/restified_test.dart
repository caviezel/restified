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
      await http.getOne('/1', InventoryType(), HttpCallback<InventoryType>(
          onResponse: (IResponse response, InventoryType result) {
        expect(response.success, true);
        expect(result.id, 1);
      }));
    });

    test('get fail', () async {
      await http.getOne('/10000000', InventoryType(),
          HttpCallback<InventoryType>(
              onResponse: (IResponse response, InventoryType result) {
        expect(response.success, false);
        expect(result, null);
      }));
    });

    test('get all success', () async {
      await http.getList('', InventoryType(), HttpCallback<List<InventoryType>>(
          onResponse: (IResponse response, List<InventoryType> results) {
        expect(response.success, true);
        expect(results.length, 5);
      }));
    });

    test('get all fail', () async {
      await http.getList(
          'sdsds',
          InventoryType(),
          HttpCallback<List<InventoryType>>(
              onFailure: (int statusCode) => expect(statusCode, 404)));
    });

    test('insert', () async {
      InventoryType p = InventoryType(name: 'test123');
      await http.post('', p.toJson(),
          HttpCallback<int>(onResponse: (IResponse response, int id) {
        expect(response.success, true);
        lastInsertId = id;
      }));
    });

    test('update', () async {
      InventoryType p = InventoryType(name: 'test2100');
      await http.put('/$lastInsertId', p.toJson(),
          HttpCallback<int>(onResponse: (IResponse response, int affectedRows) {
        expect(response.success, true);
        expect(affectedRows, 1);
      }));
    });

    test('delete', () async {
      await http.delete('/$lastInsertId',
          HttpCallback<int>(onResponse: (IResponse response, int affectedRows) {
        expect(response.success, true);
        expect(affectedRows, 1);
      }));
    });
  });
}
