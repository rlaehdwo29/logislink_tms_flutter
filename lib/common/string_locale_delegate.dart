
import 'package:flutter/cupertino.dart';
import 'package:logislink_tms_flutter/common/strings.dart';

class StringLocaleDelegate extends LocalizationsDelegate<Strings> {
  const StringLocaleDelegate();

@override
bool isSupported(Locale locale) => ['ko', 'en'].contains(locale.languageCode);

@override
Future<Strings> load(Locale locale) async {
  Strings _strings = Strings(locale);
  await _strings.load();

  print("Load ${locale.languageCode}");

  return _strings;
}

@override
bool shouldReload(StringLocaleDelegate old) => false;
}