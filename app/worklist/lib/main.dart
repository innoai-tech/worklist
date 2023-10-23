import 'package:flutter/material.dart';
import 'package:logr/logr.dart';
import 'package:logr/stdlogr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:storage/storage.dart';
import 'package:worklistapp/common/persist.dart';
import 'package:worklistapp/domain/downloader/downloader.dart';
import 'package:worklistapp/domain/registry/registry.dart';
import 'package:worklistapp/domain/worklist/worklist.dart';
import 'package:worklistapp/view/app_main.dart';

void main() async {
  final logger = Logger(StdLogSink("app"));
  final ctx = Logger.withLogger(logger);

  await ctx.run(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      runApp(App(
        driver: FsDriver(root: await getApplicationDocumentsDirectory()),
      ));
    },
  );
}

var theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.amber,
  ),
);

class App extends SetupWidget<App> {
  final Driver driver;

  const App({required this.driver, super.key});

  @override
  setup(sc) {
    final downloader = Downloader.context.use();
    final registryStore = RegistryStore.context.use();
    final worklistSchemaStore = WorklistSchemaStore.context.use();
    final worklistStore = WorklistStore.context.use();

    registryStore.connectPersist(
      driver: driver,
      valueFromJson: RegistryStore.valueFromJson,
    );

    worklistSchemaStore.connectPersist(
      driver: driver,
      valueFromJson: WorklistSchemaStore.valueFromJson,
    );

    worklistStore.connectPersist(
      driver: driver,
      valueFromJson: WorklistStore.valueFromJson,
    );

    // keep running
    downloader.stream.listenUntilUnmounted();

    return () {
      return Driver.context.provide(
        value: driver,
        child: MaterialApp(
          title: "工作清单",
          theme: theme,
          home: const AppMain(),
        ),
      );
    };
  }
}
