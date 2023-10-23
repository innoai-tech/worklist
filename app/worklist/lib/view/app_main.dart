import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/common/layout.dart';

import 'profile/page_setting.dart';
import 'worklist/page_worklist.dart';

class AppMain extends SetupWidget<AppMain> {
  const AppMain({super.key});

  @override
  setup(context) {
    final pages = List<NavigationPage>.of([
      const PageWorklist(),
      const PageSetting(),
    ]);

    final selectedIndex = ref(0);

    return () {
      return Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex.value,
          onDestinationSelected: (i) => selectedIndex.value = i,
          destinations: [
            ...pages.map((e) => e.destination),
          ],
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
        body: pages[selectedIndex.value],
      );
    };
  }
}
