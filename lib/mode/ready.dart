import 'package:flutter/material.dart';
import '../size_config.dart';

class Ready extends StatelessWidget {
  final model;
  Ready({this.model});

  @override
  Widget build(BuildContext context) {
    // * ゲーム開始画面
    return model.display == 'ready'
        ? Stack(
            children: [
              Align(
                alignment: Alignment(0, -0.2),
                child: model.gameHasStarted
                    ? const SizedBox()
                    : Text(
                        'T A P  T O  P L A Y',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeVertical! * 2,
                          color: Colors.white,
                        ),
                      ),
              ),
              Align(
                alignment: Alignment(0, 0.35),
                child: model.gameHasStarted
                    ? const SizedBox()
                    : Container(
                        height: SizeConfig.blockSizeVertical! * 5,
                        width: SizeConfig.blockSizeHorizontal! * 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Colors.black,
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            model.switchDisplay('how');
                          },
                          child: Text(
                            'H O W  T O  P L A Y',
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 1.7,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
              // 戻るボタン
              Align(
                alignment: Alignment(0, 0.5),
                child: model.gameHasStarted
                    ? const SizedBox()
                    : Container(
                        height: SizeConfig.blockSizeVertical! * 5,
                        width: SizeConfig.blockSizeHorizontal! * 40,
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
                              fontSize: SizeConfig.blockSizeVertical! * 1.7,
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
