import 'package:flutter/material.dart';
import 'package:new_rocket/mainpage_model.dart';
import 'package:new_rocket/objects/lock.dart';
import '../../size_config.dart';

class Top extends StatelessWidget {
  MainPageModel model;
  Top({required this.model});

  @override
  Widget build(BuildContext context) {
    // * タイトル画面
    return model.display == 'top'
        ? Stack(
            children: [
              Align(
                alignment: Alignment(0, -0.2),
                child: Text(
                  'Unlucky Rocket',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 3,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.15),
                child: Text(
                  'version 1.2',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // todo デバッグボタン ----------------------------------------------
              model.debugMode
                  ? Align(
                      alignment: Alignment(0, -0.4),
                      child: Container(
                        height: SizeConfig.blockSizeVertical! * 5,
                        width: SizeConfig.blockSizeHorizontal! * 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Colors.black,
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            model.debug();
                          },
                          child: Text(
                            'デバッグ',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              // todo デバッグボタン ----------------------------------------------
              Align(
                alignment: Alignment(0, 0.5),
                child: SizedBox(
                  height: SizeConfig.blockSizeVertical! * 18,
                  width: double.infinity,
                  child: FutureBuilder(
                    future: model.getClearLevel(),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData) {
                        return Center(
                          child: Wrap(
                            spacing: SizeConfig.blockSizeHorizontal! * 2,
                            runSpacing: SizeConfig.blockSizeVertical! * 1,
                            children: [
                              for (int i = 1; i <= 10; i++) ...[
                                Container(
                                  height: SizeConfig.blockSizeVertical! * 8,
                                  width: SizeConfig.blockSizeHorizontal! * 18,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: snapshot.data! < i
                                        ? Lock()
                                        : OutlinedButton(
                                            onPressed: () {
                                              model.switchLevel(i);
                                              model.switchDisplay('ready');
                                            },
                                            child: Stack(
                                              children: [
                                                model.isClear(i)
                                                    ? Align(
                                                        alignment:
                                                            Alignment(0, 1),
                                                        child: Text(
                                                          'CLEAR',
                                                          style: TextStyle(
                                                            fontSize: SizeConfig
                                                                    .blockSizeVertical! *
                                                                1.7,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                Align(
                                                  alignment: Alignment(0, -0.8),
                                                  child: Text(
                                                    'LEVEL',
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockSizeVertical! *
                                                          1.3,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment(0, 0),
                                                  child: Text(
                                                    (i).toString(),
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockSizeVertical! *
                                                          2,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                )
                              ],
                            ],
                          ),
                        );
                      }

                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.75),
                child: Container(
                  height: SizeConfig.blockSizeVertical! * 5,
                  width: SizeConfig.blockSizeHorizontal! * 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      model.switchDisplay('how');
                      model.howDemoMove();
                    },
                    child: Text(
                      '遊び方',
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
