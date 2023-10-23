import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:formkit/formkit.dart';
import 'package:setup_widget/core/core.dart';
import 'package:storage/storage.dart';

class MdView extends SetupWidget<MdView> {
  final String code;

  const MdView({
    required this.code,
  });

  @override
  setup(sc) {
    return () {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MarkdownBody(
                  styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                  data: sc.widget.code,
                  imageBuilder: (Uri uri, String? title, String? alt) {
                    return ImageView(uri: uri);
                  })
            ],
          ),
        ),
      );
    };
  }
}

class ImageView extends SetupWidget<ImageView> {
  final Uri uri;

  const ImageView({
    required this.uri,
  });

  @override
  setup(sc) {
    final driver = Driver.context.use();

    return () {
      final f = sc.widget.uri.toString();

      if (f.startsWith("file:")) {
        return Image(image: FileImage(File(sc.widget.uri.path)));
      }

      if (f.startsWith("blob:")) {
        return Image(
          image: BlobImage(
            driver: driver,
            uri: BlobURI.parse(f),
          ),
        );
      }

      return SizedBox.shrink();
    };
  }
}

class BlobImage extends ImageProvider<BlobURI> {
  final Driver driver;
  final BlobURI uri;

  const BlobImage({
    required this.driver,
    required this.uri,
  });

  @override
  Future<BlobURI> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<BlobURI>(uri);
  }

  @override
  ImageStreamCompleter loadImage(BlobURI uri, ImageDecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    ;

    return MultiFrameImageStreamCompleter(
      codec: driver
          .openFile(uri.digest.asBlobFilePath())
          .then((FileInterface file) async {
            final f = await file.openRead();
            return await f.readAsBytes();
          })
          .then((bytes) {
            if (uri.compressType == "gzip") {
              return Uint8List.fromList(GZipCodec().decode(bytes));
            }
            return Uint8List.fromList(bytes);
          })
          .catchError((Object e, StackTrace stack) {
            scheduleMicrotask(() {
              PaintingBinding.instance.imageCache.evict(uri);
            });
            return Future<Uint8List>.error(e, stack);
          })
          .whenComplete(chunkEvents.close)
          .then<ui.ImmutableBuffer>(ui.ImmutableBuffer.fromUint8List)
          .then<ui.Codec>(decode),
      chunkEvents: chunkEvents.stream,
      scale: 1.0,
      debugLabel: '"key"',
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<BlobURI>('URL', uri),
      ],
    );
  }
}
