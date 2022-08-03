import 'package:flutter/material.dart';
import 'package:new_rocket/mainpage_model.dart';
import '../size_config.dart';

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
                alignment: Alignment(0, 0.5),
                child: SizedBox(
                  height: SizeConfig.blockSizeVertical! * 25,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // レベル1~5
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 1; i <= 5; i++) ...[
                            Container(
                              height: SizeConfig.blockSizeVertical! * 8,
                              width: SizeConfig.blockSizeHorizontal! * 18,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: Colors.black,
                              ),
                              child: OutlinedButton(
                                onPressed: () {
                                  model.switchLevel(model.mappingLevel[i]);
                                  model.switchDisplay('ready');
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'LEVEL',
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeVertical! * 1.3,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      (i).toString(),
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeVertical! * 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ],
                      ),
                      // レベル6~10
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 6; i <= 10; i++) ...[
                            Container(
                              height: SizeConfig.blockSizeVertical! * 8,
                              width: SizeConfig.blockSizeHorizontal! * 18,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: Colors.black,
                              ),
                              child: OutlinedButton(
                                onPressed: () {
                                  model.switchLevel(model.mappingLevel[i]);
                                  model.switchDisplay('ready');
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'LEVEL',
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeVertical! * 1.3,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      (i).toString(),
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeVertical! * 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
