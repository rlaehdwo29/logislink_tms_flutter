import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Strings {
  Strings(this.locale);

  final Locale locale;

  static Strings? of(BuildContext context) {
    return Localizations.of<Strings>(context, Strings);
  }

  Map<String, String>? _strings;

  Future<bool> load() async {
    String data = await rootBundle
        .loadString('assets/translations/ko.json');
    Map<String, dynamic> _result = json.decode(data);

    _strings = Map();
    _result.forEach((String key, dynamic value) {
      _strings?[key] = value.toString();
    });

    return true;
  }

  String? get(String key) {
    return _strings?[key];
  }
}
