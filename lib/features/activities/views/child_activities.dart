import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../games/controllers/games_controller.dart';
import '../../games/views/games_view.dart';

class ChildActivities extends StatefulWidget {
  const ChildActivities({super.key});

  @override
  State<ChildActivities> createState() => _ChildActivitiesState();
}

class _ChildActivitiesState extends State<ChildActivities> {
  late final GamesController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<GamesController>()
        ? Get.find<GamesController>()
        : Get.put(GamesController());
  }

  @override
  Widget build(BuildContext context) {
    return const GamesView();
  }
}
