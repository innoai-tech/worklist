import 'package:setup_widget/setup_widget.dart';
import 'package:syncer/syncer.dart';

abstract class Downloader {
  static final context = Context.create(() => TaskSyncer.create());
}
