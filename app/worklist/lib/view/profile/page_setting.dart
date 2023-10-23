import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/common/layout.dart';

import 'view_about.dart';
import 'view_registry.dart';

class PageSetting extends SetupWidget implements NavigationPage {
  const PageSetting({
    super.key,
  });

  @override
  get destination => const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings_rounded),
        label: "设置",
      );

  @override
  setup(sc) {
    final list = List<QuickView>.of([
      ViewRegistry(),
      ViewAbout(),
    ]);

    return () {
      return Scaffold(
        appBar: AppBar(
          title: const Text("设置"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [...list.map((quickView) => quickView.view)],
            ),
          ),
        ),
      );
    };
  }
}
