import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logislink_tms_flutter/common/model/code_model.dart';
import 'package:logislink_tms_flutter/common/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/const.dart';

class SP extends GetxController {
  static SharedPreferences? m_Pref;

  @override
  void onInit() async {
    m_Pref ??= await SharedPreferences.getInstance();
    super.onInit();
  }

  static Future<void> open() async {
    m_Pref ??= await SharedPreferences.getInstance();
  }

  static void clear() {
    open();
    m_Pref?.clear();
  }

  static Future<void> remove(String key) async {
    await open();
    await m_Pref?.remove(key);
    await m_Pref?.commit();
  }

  static Future<void> putString(String key, String value) async {
    await open();
    await m_Pref?.setString(key, value);
  }

  static Future<void> putInt(String key, int value) async {
    await open();
    await m_Pref?.setInt(key, value);
  }

  static Future<void> putBool(String key, bool value) async {
    await open();
    m_Pref?.setBool(key, value);
  }

  static Future<void> putUserModel(String key, UserModel? value) async {
    await open();
    m_Pref?.setString(key,jsonEncode(value));
  }

  static Future<String?> get(String key) async {
    await open();
    return m_Pref?.getString(key);
  }

  static Future<String?> getString(String key, String defaultValue) async {
    await open();
    return m_Pref?.getString(key)??defaultValue;
  }

  static Future<bool> getBoolean(String key) async {
    await open();
    return m_Pref?.getBool(key)??false;
  }

  static Future<bool> getDefaultTrueBoolean(String key) async {
    await open();
    return m_Pref?.getBool(key)??true;
  }

  static Future<int>? getInt(String key,{int? defaultValue}) async {
    await open();
    defaultValue ??= 0;
    return m_Pref?.getInt(key)??defaultValue;
  }

  static Future<String> getFirstScreen(BuildContext context) async {
    await open();
    return m_Pref?.getString(Const.KEY_SETTING_SCREEN)??Const.first_screen[0];
  }

  static Future<UserModel>? getUserInfo(String key)  async {
    await open();
    var json = await m_Pref?.getString(key);
    if(json == null){
      return UserModel();
    }else {
      Map<String, dynamic> jsonData = jsonDecode(json);
      return UserModel.fromJSON(jsonData);
    }
  }

  static Future<void> putStringList(String key, List<String>? list) async {
    await open();
    m_Pref?.setStringList(key, list??[]);
  }

  static Future<List<String>?>? getStringList(String key) async {
    await open();
    List<String>? json = await m_Pref?.getStringList(key);
    return json;
  }

/**
   * 공통코드 목록 저장
   */
  static Future<void> putCodeList(String key, String codeList) async {
    await open();
    Logger logger = Logger();
    try {
      await m_Pref?.setString(key, codeList);
    }catch(e){
      logger.e(e);
    }
  }


  /**
   * 저장된 공통코드 목록 불러오기
   */
  static List<CodeModel>? getCodeList(String key) {
    Logger logger = Logger();
    List<CodeModel>? mList = List.empty(growable: true);
    open();
    if(m_Pref?.getString(key)?.isNotEmpty == true && m_Pref?.getString(key) != null ) {
      String jsonString = m_Pref?.getString(key) ?? "";
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      var list = jsonData?["data"] as List;
      List<CodeModel>? itemsList = list.map((i) => CodeModel.fromJSON(i))
          .toList();
      mList.addAll(itemsList);
    }
    return mList;
  }

  /**
   * 저장된 공통코드 목록에서 코드네임 불러오기
   */
  static String getCodeName(String key, String val) {
    if (val.isEmpty) {
      return "";
    }
    List<CodeModel>? list = getCodeList(key);
    String codeName = "";
    for (CodeModel data in list!) {
      if (val == data.code) {
        codeName = data.codeName??"";
      }
    }
    return codeName;
  }

}