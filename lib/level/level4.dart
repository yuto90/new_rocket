import 'package:flutter/material.dart';
import 'package:new_rocket/objects/cloud.dart';
import 'package:new_rocket/objects/meteorite.dart';
import 'package:new_rocket/objects/star.dart';
import 'package:new_rocket/objects/ufo.dart';
import '../size_config.dart';

class Level4 extends StatelessWidget {
  final model;
  Level4({this.model});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // * 障害物 -----------------------------------------------------------
        Align(
          alignment: Alignment(model.ufo_1, -1),
          child: Ufo(),
        ),
        //Align(
        //alignment: Alignment(model.ufo_075, -0.75),
        //child: Ufo(),
        //),
        //Align(
        //alignment: Alignment(model.ufo_05, -0.5),
        //child: Ufo(),
        //),
        //Align(
        //alignment: Alignment(model.ufo_025, -0.25),
        //child: Ufo(),
        //),
        //Align(
        //alignment: Alignment(model.ufo0, 0),
        //child: Ufo(),
        //),
        //Align(
        //alignment: Alignment(model.ufo025, 0.25),
        //child: Ufo(),
        //),
        //Align(
        //alignment: Alignment(model.ufo05, 0.5),
        //child: Ufo(),
        //),
        //Align(
        //alignment: Alignment(model.ufo075, 0.75),
        //child: Ufo(),
        //),
        //Align(
        //alignment: Alignment(model.ufo1, 1),
        //child: Ufo(),
        //),
        // * 雲 -----------------------------------------------------------
        Align(
          alignment: Alignment(0.9, model.cloud),
          child: Cloud(
            vertical: SizeConfig.blockSizeVertical! * 20,
            horizontal: SizeConfig.blockSizeHorizontal! * 60,
          ),
        ),
        Align(
          alignment: Alignment(-1, model.cloud2),
          child: Cloud(
            vertical: SizeConfig.blockSizeVertical! * 15,
            horizontal: SizeConfig.blockSizeHorizontal! * 45,
          ),
        ),
        Align(
          alignment: Alignment(1, model.cloud3),
          child: Cloud(
            vertical: SizeConfig.blockSizeVertical! * 20,
            horizontal: SizeConfig.blockSizeHorizontal! * 50,
          ),
        ),
        // * 星 -----------------------------------------------------------
        model.level != 7
            ? Align(
                alignment: Alignment((model.star * -1), model.star),
                child: Star(),
              )
            : const SizedBox(),
        model.level != 5 || model.level != 7
            ? Align(
                alignment: Alignment((model.star2 * -1), model.star2),
                child: Star(),
              )
            : const SizedBox(),
        model.level == 2
            ? Align(
                alignment: Alignment((model.star3 * -1), model.star3),
                child: Star(),
              )
            : const SizedBox(),
        // * 隕石 -----------------------------------------------------------
        Align(
          alignment: Alignment(1, model.meteorite),
          child: Meteorite(
            vertical: SizeConfig.blockSizeVertical! * 18,
            horizontal: SizeConfig.blockSizeHorizontal! * 27,
          ),
        ),
        Align(
          alignment: Alignment(-0.8, model.meteorite2),
          child: Meteorite(
            vertical: SizeConfig.blockSizeVertical! * 15,
            horizontal: SizeConfig.blockSizeHorizontal! * 20,
          ),
        ),
        Align(
          alignment: Alignment(0.6, model.meteorite3),
          child: Meteorite(
            vertical: SizeConfig.blockSizeVertical! * 10,
            horizontal: SizeConfig.blockSizeHorizontal! * 20,
          ),
        ),
        Align(
          alignment: Alignment(0.8, model.meteorite4),
          child: Meteorite(
            vertical: SizeConfig.blockSizeVertical! * 16,
            horizontal: SizeConfig.blockSizeHorizontal! * 26,
          ),
        ),
        Align(
          alignment: Alignment(-0.6, model.meteorite5),
          child: Meteorite(
            vertical: SizeConfig.blockSizeVertical! * 18,
            horizontal: SizeConfig.blockSizeHorizontal! * 27,
          ),
        ),
      ],
    );
  }
}
