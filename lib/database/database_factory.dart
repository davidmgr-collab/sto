
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

DatabaseFactory createDatabaseFactory() {
  if (kIsWeb) {
    return databaseFactoryFfiWeb;
  }

  return mobile.databaseFactory;
}
