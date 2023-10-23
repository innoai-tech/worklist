import 'package:flutter/material.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/common/layout.dart';
import 'package:worklistapp/view/worklist/page_worklist_schema_list.dart';

class PageWorklist extends SetupWidget implements NavigationPage {
  const PageWorklist({super.key});

  @override
  get destination => const NavigationDestination(
        icon: Icon(Icons.view_list_outlined),
        selectedIcon: Icon(Icons.view_list_rounded),
        label: "工作清单",
      );

  @override
  setup(sc) {
    return () {
      return Scaffold(
        appBar: AppBar(
          title: Text("工作清单"),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                sc.context,
                MaterialPageRoute(
                    builder: (c) => PageWorklistSchemaList(
                          onSelect: (schema) {
                            print(schema);

                            Navigator.pop(sc.context);
                          },
                        )),
              );
            },
            icon: Icon(Icons.tag),
          ),
        ),
        body: ListView(
          children: [],
        ),
      );
    };
  }
}
