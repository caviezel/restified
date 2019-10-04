library restified;

import 'package:flutter/foundation.dart';
import 'package:restified/http.dart';
import 'package:rxdart/rxdart.dart';

class GetBloc<T> {
  final String endpoint;
  final Serializable<T> model;

  final BehaviorSubject<List<T>> _all = BehaviorSubject<List<T>>();
  final BehaviorSubject<T> _single = BehaviorSubject<T>();

  GetBloc({this.endpoint, this.model});

  getAll() async {
    _all.sink.add(null);
    List<T> response = await Http().getAll('$endpoint', model);
    _all.sink.add(response);
  }

  getById(int id) async {
    _single.sink.add(null);
    T m = await Http().getSingle('$endpoint/$id', model);
    _single.sink.add(m);
  }

  change(T model) {
    _single.sink.add(model);
  }

  dispose() {
    _all.close();
    _single.close();
  }

  BehaviorSubject<List<T>> get all => _all;

  BehaviorSubject<T> get single => _single;
}

abstract class ManipulationBloc<T> {
  final BehaviorSubject<T> _response = BehaviorSubject<T>();
  bool _loading = false;

  clear() {
    _response.sink.add(null);
  }

  dispose() {
    _response.close();
  }

  BehaviorSubject<T> get response => _response;

  bool get loading => _loading;
}

class UpdateBloc extends ManipulationBloc<ResponseUpdateData> {
  final String endpoint;

  UpdateBloc({@required this.endpoint});

  update(int id, Map model) async {
    _loading = true;
    ResponseUpdateData resp = await Http().put('$endpoint/$id', model);
    _loading = false;
    _response.sink.add(resp);
  }
}

class InsertBloc extends ManipulationBloc<ResponseInsertData> {
  final String endpoint;

  InsertBloc({@required this.endpoint});

  insert(Map model) async {
    _loading = true;
    ResponseInsertData resp = await Http().post('$endpoint', model);
    _loading = false;
    _response.sink.add(resp);
  }
}
