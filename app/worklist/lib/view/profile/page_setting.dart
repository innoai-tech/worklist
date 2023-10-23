import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/view/profile/page_registry_list.dart';

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
    final list = List<NavigationPage>.of([
      PageRegistryList(),
    ]);

    return () {
      return Scaffold(
        appBar: AppBar(
          title: const Text("设置"),
        ),
        body: ListView(
          children: [
            ...list.map((page) => ListTile(
                  leading: page.destination.icon,
                  title: Text(page.destination.label),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      sc.context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => page,
                      ),
                    );
                  },
                ))
          ],
        ),
      );
    };
  }
}
