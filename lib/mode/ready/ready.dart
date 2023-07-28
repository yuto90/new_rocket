import 'package:flutter/material.dart';
import 'package:new_rocket/mainpage_model.dart';
import '../../size_config.dart';

class Ready extends StatelessWidget {
  final MainPageModel model;
  Ready({required this.model});

  @override
  Widget build(BuildContext context) {
    // * ゲーム開始画面
    return model.display == 'ready'
        ? Stack(
            children: [
              Align(
                alignment: Alignment(0, -0.3),
                child: Text(
                  'L E V E L ' + model.selectedLevel.toString(),
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 2,
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.2),
                child: Text(
                  'T A P  T O  P L A Y',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 2,
                    color: Colors.white,
                  ),
                ),
              ),
              // 戻るボタン
              Align(
                alignment: Alignment(0, 0.3),
                child: Container(
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
