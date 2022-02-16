import 'package:flutter/material.dart';
import '../size_config.dart';

class Ready extends StatelessWidget {
  final model;
  Ready({this.model});

  @override
  Widget build(BuildContext context) {
    // * ゲーム開始画面
    return model.display == 'ready'
        ? Align(
            alignment: Alignment(0, -0.2),
            child: model.gameHasStarted
                ? Text('')
                : Text(
                    'T A P  T O  P L A Y',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical! * 2,
                      color: Colors.white,
                    ),
                  ),
          )
        : Text('');
  }
}
