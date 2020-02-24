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

class HttpCallback<T> {
  final void Function(IResponse, T) onResponse;
  final void Function(int) onFailure;

  HttpCallback({this.onResponse, this.onFailure});
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

  Future<void> getOne<T>(String endpoint, Serializable<T> template,
      HttpCallback<T> callback) async {
    dartHttp.Response response =
        await dartHttp.get('$url$endpoint', headers: headers);
    if (response.statusCode != 200) {
      if (callback.onFailure != null) {
        callback?.onFailure(response.statusCode);
      }
    } else {
      IResponse resp = parseResponse(response.body);
      T result = resp.success ? template.fromJson(resp.data) : null;
      callback?.onResponse(resp, result);
    }
  }

  Future<void> getList<T>(String endpoint, Serializable<T> template,
      HttpCallback<List<T>> callback) async {
    dartHttp.Response response =
        await dartHttp.get('$url$endpoint', headers: headers);
    if (response.statusCode != 200) {
      if (callback.onFailure != null) {
        callback?.onFailure(response.statusCode);
      }
    } else {
      IResponse resp = parseResponse(response.body);
      List<T> results = resp.success
          ? (resp.data as List).map((i) => template.fromJson(i)).toList()
          : null;
      callback?.onResponse(resp, results);
    }
  }

  Future<void> post(
      String endpoint, Map data, HttpCallback<int> callback) async {
    dartHttp.Response response = await dartHttp.post('$url$endpoint',
        headers: headers, body: json.encode(data));
    if (response.statusCode != 200) {
      if (callback.onFailure != null) {
        callback?.onFailure(response.statusCode);
      }
    } else {
      IResponse resp = parseResponse(response.body);
      int id = resp.success ? resp.data['id'] : null;
      callback?.onResponse(resp, id);
    }
  }

  Future<void> put(
      String endpoint, Map data, HttpCallback<int> callback) async {
    dartHttp.Response response = await dartHttp.put('$url$endpoint',
        headers: headers, body: json.encode(data));
    if (response.statusCode != 200) {
      if (callback.onFailure != null) {
        callback?.onFailure(response.statusCode);
      }
    } else {
      IResponse resp = parseResponse(response.body);
      int affectedRows = resp.success ? resp.data['affected_rows'] : null;
      callback?.onResponse(resp, affectedRows);
    }
  }

  Future<void> delete(String endpoint, HttpCallback<int> callback) async {
    dartHttp.Response response =
        await dartHttp.delete('$url$endpoint', headers: headers);
    if (response.statusCode != 200) {
      if (callback.onFailure != null) {
        callback?.onFailure(response.statusCode);
      }
    } else {
      IResponse resp = parseResponse(response.body);
      int affectedRows = resp.success ? resp.data['affected_rows'] : null;
      callback?.onResponse(resp, affectedRows);
    }
  }
}
