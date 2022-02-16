import 'package:flutter/material.dart';
import '../size_config.dart';

class Clear extends StatelessWidget {
  final model;
  Clear({this.model});

  @override
  Widget build(BuildContext context) {
    // * クリア画面
    return model.display == 'clear'
        ? Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'C L E A R !!!',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 180,
                ),
                OutlinedButton(
                  onPressed: () {
                    //model.switchDisplay();
                    model.display = 'top';
                    model.resetPosition();
                    model.reload();
                  },
                  child: Text(
                    'E X I T',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 2,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        : Text('');
  }
}
