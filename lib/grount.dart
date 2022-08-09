import 'package:flutter/material.dart';
import 'package:new_rocket/mainpage_model.dart';
import 'package:new_rocket/size_config.dart';
import 'objects/building.dart';
import 'objects/building2.dart';
import 'objects/office.dart';
import 'objects/tokyo_tower.dart';
import 'objects/wood.dart';

/// 地面のオブジェクトを管理するclass
class Ground {
  /// 東京背景
  List tokyo(MainPageModel model) {
    return [
      Align(
        alignment: Alignment(0.6, model.ground),
        child: Building2(),
      ),
      Align(
        alignment: Alignment(-1.3, model.ground),
        child: Building2(),
      ),
      Align(
        alignment: Alignment(-0.1, model.ground),
        child: Office(),
      ),
      Align(
        alignment: Alignment(1.2, model.ground),
        child: Building2(),
      ),
      Align(
        alignment: Alignment(1.1, model.ground),
        child: TokyoTower(),
      ),
      Align(
        alignment: Alignment(1.1, model.ground),
        child: Wood(),
      ),
      Align(
        alignment: Alignment(-0.9, model.ground),
        child: Office(),
      ),
      Align(
        alignment: Alignment(0.2, model.ground),
        child: Building(),
      ),
      Align(
        alignment: Alignment(0, model.ground),
        child: Wood(),
      ),
      Align(
        alignment: Alignment(-0.8, model.ground),
        child: Building(),
      ),
      Align(
        alignment: Alignment(-0.4, model.ground),
        child: Building2(),
      ),
    ];
  }
}
