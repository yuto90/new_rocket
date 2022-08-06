import 'package:flutter/material.dart';
import '../objects/goal.dart';
import '../objects/star.dart';
import '../objects/ufo.dart';
import '../size_config.dart';

class How extends StatelessWidget {
  final model;
  How({this.model});

  @override
  Widget build(BuildContext context) {
    // * ルール説明画面
    return model.display == 'how'
        ? Stack(
            children: [
              // クリア条件の注釈
              Align(
                alignment: Alignment(0, -0.7),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  height: SizeConfig.blockSizeVertical! * 20,
                  width: SizeConfig.blockSizeHorizontal! * 90,
                  child: Column(
                    children: [
                      Spacer(),
                      Text(
                        '-*-*-*-*- 遊び方 -*-*-*-*-',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeVertical! * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ロケットに迫る障害物を避けて宇宙の惑星を目指そう！',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeVertical! * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(),
                          Goal(heightSize: 10, widthSize: 10),
                          Spacer(),
                          Container(
                            height: SizeConfig.blockSizeVertical! * 8,
                            width: SizeConfig.blockSizeHorizontal! * 0.5,
                            color: Colors.white,
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Ufo(),
                              Star(),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(flex: 5),
                          Text(
                            '惑星',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 1.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                          Spacer(flex: 8),
                          Text(
                            '障害物',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 1.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(flex: 5),
                        ],
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),

              // ロケットの注釈
              Align(
                alignment: Alignment(0, 0.16),
                child: Text(
                  '↑',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 6,
                    color: Colors.black,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.26),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  height: SizeConfig.blockSizeVertical! * 5,
                  width: SizeConfig.blockSizeHorizontal! * 75,
                  child: Center(
                    child: Text(
                      '画面をタップするとロケットが上にブースト',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // 戻るボタン
              Align(
                alignment: Alignment(0, 0.5),
                child: Container(
                  height: SizeConfig.blockSizeVertical! * 5,
                  width: SizeConfig.blockSizeHorizontal! * 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      model.switchDisplay('top');
                    },
                    child: Text(
                      'B A C K',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
