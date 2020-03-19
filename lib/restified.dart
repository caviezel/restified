library restified;

import 'dart:convert';
import 'package:http/http.dart' as dartHttp;

abstract class Serializable<T> {
  T fromJson(Map json);
  Map<String, dynamic> toJson();
}

abstract class IResponse {
  bool get success;
  String get msg;
  dynamic get data;
}

class Response implements IResponse {
  final bool s;
  final dynamic m;
  final dynamic d;

  Response({this.s, this.m, this.d});

  @override
  factory Response.fromJson(Map json) {
    return Response(
      s: json['success'],
      m: json.containsKey('msg') ? json['msg'] : null,
      d: json.containsKey('data') ? json['data'] : null,
    );
  }

  @override
  bool get success => s;

  @override
  String get msg => m;

  @override
  dynamic get data => d;
}

class HttpResult<T, E> {
  final IResponse response;
  final T data;
  final E error;

  HttpResult({this.response, this.data, this.error});
}

class Http {
  final String url;

  IResponse Function(String) parseResponse;
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Http({this.url, this.parseResponse}) {
    if (parseResponse == null) {
      parseResponse = (body) => Response.fromJson(json.decode(body));
    }
  }

  Future<HttpResult<T, int>> getOne<T>(
      String endpoint, Serializable<T> template) async {
    dartHttp.Response response =
        await dartHttp.get('$url$endpoint', headers: headers);
    if (response.statusCode != 200) {
      return HttpResult(error: response.statusCode);
    }

    IResponse resp = parseResponse(response.body);
    T result = resp.success ? template.fromJson(resp.data) : null;
    return HttpResult(response: resp, data: result);
  }

  Future<HttpResult<List<T>, int>> getList<T>(
      String endpoint, Serializable<T> template) async {
    dartHttp.Response response =
        await dartHttp.get('$url$endpoint', headers: headers);
    if (response.statusCode != 200) {
      return HttpResult<List<T>, int>(error: response.statusCode);
    }

    IResponse resp = parseResponse(response.body);
    List<T> list = resp.success
        ? (resp.data as List).map((i) => template.fromJson(i)).toList()
        : null;
    return HttpResult<List<T>, int>(response: resp, data: list);
  }

  Future<HttpResult<int, int>> post(String endpoint, Map data) async {
    dartHttp.Response response = await dartHttp.post('$url$endpoint',
        headers: headers, body: json.encode(data));
    if (response.statusCode != 200) {
      return HttpResult<int, int>(error: response.statusCode);
    }

    IResponse resp = parseResponse(response.body);
    int id = resp.success ? resp.data['id'] : null;
    return HttpResult<int, int>(response: resp, data: id);
  }

  Future<HttpResult<int, int>> put(String endpoint, Map data) async {
    dartHttp.Response response = await dartHttp.put('$url$endpoint',
        headers: headers, body: json.encode(data));
    if (response.statusCode != 200) {
      return HttpResult<int, int>(error: response.statusCode);
    }

    IResponse resp = parseResponse(response.body);
    int affectedRows = resp.success ? resp.data['affected_rows'] : null;
    return HttpResult<int, int>(data: affectedRows, response: resp);
  }

  Future<HttpResult<int, int>> delete(String endpoint) async {
    dartHttp.Response response =
        await dartHttp.delete('$url$endpoint', headers: headers);
    if (response.statusCode != 200) {
      return HttpResult<int, int>(error: response.statusCode);
    }

    IResponse resp = parseResponse(response.body);
    int affectedRows = resp.success ? resp.data['affected_rows'] : null;
    return HttpResult<int, int>(data: affectedRows, response: resp);
  }
}
