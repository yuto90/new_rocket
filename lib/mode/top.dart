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
                alignment: Alignment(0, 0.3),
                child: Container(
                  height: SizeConfig.blockSizeVertical! * 10,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.mappingLevel.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: SizeConfig.blockSizeVertical! * 5,
                        width: SizeConfig.blockSizeHorizontal! * 33,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Colors.black,
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            model.switchLevel(model.mappingLevel[index + 1]);
                            model.switchDisplay('ready');
                          },
                          child: Text(
                            'LEVEL ' + (index + 1).toString(),
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
