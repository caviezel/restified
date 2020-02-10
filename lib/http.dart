library http;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class Serializable<T> {
  T fromJson(Map json);
  Map<String, dynamic> toJson();
  T clone();
}

class Response {
  final bool success;
  final String msg;
  final dynamic data;

  const Response({this.success, this.msg, this.data});

  factory Response.fromJson(Map json) {
    return Response(
      success: json['success'],
      msg: json.containsKey('msg') ? json['msg'] : null,
      data: json.containsKey('data') ? json['data'] : null,
    );
  }
}

class Http {
  static String api;

  Future<T> getSingle<T>(String endpoint, Serializable<T> s) async {
    http.Response response = await http
        .get('$api$endpoint', headers: {'Authorization': await _getToken()});
    return s.fromJson(json.decode(response.body)['data']);
  }

  Future<List<T>> getAll<T>(String endpoint, Serializable<T> s) async {
    http.Response response = await http
        .get('$api$endpoint', headers: {'Authorization': await _getToken()});
    dynamic j = json.decode(response.body)['data'];
    return (j as List).map((i) => s.fromJson(i)).toList();
  }

  Future<Response> post(String endpoint, Map s) async {
    http.Response response = await http.post('$api$endpoint',
        headers: {
          'Authorization': await _getToken(),
          'Content-Type': 'application/json'
        },
        body: json.encode(s));
    return Response.fromJson(json.decode(response.body));
  }

  Future<Response> put(String endpoint, Map s) async {
    http.Response response = await http.put('$api$endpoint',
        headers: {
          'Authorization': await _getToken(),
          'Content-Type': 'application/json'
        },
        body: json.encode(s));
    return Response.fromJson(json.decode(response.body));
  }

  Future<Response> delete(String endpoint) async {
    http.Response response = await http.delete('$api$endpoint', headers: {
      'Authorization': await _getToken(),
    });
    return Response.fromJson(json.decode(response.body));
  }

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
