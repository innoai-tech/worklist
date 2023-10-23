import 'package:crpe/registry/auth.dart';
import 'package:crpe/registry/src/remote/client.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';
import 'package:worklistapp/common/ext.dart';

import './harbor_oidc_login.dart';
import './registry.dart';

class RegistryStore extends CommonStore<Map<String, Registry>> {
  static final context =
      Context<RegistryStore>.create(() => RegistryStore.seeded({}));

  factory RegistryStore.seeded(Map<String, Registry> value) {
    final subject = BehaviorSubject<Map<String, Registry>>.seeded(value);
    return RegistryStore(stream: subject, sink: subject);
  }

  RegistryStore({
    required super.stream,
    required super.sink,
  });

  Registry? get defaultRegistry =>
      this.stream.value.values.where((e) => e.isDefault ?? false).firstOrNull ??
      this.stream.value.values.firstOrNull;

  static Map<String, Registry> valueFromJson(Map<String, dynamic> values) {
    return values.map((key, value) => MapEntry(key, Registry.fromJson(value)));
  }

  get name => "registry";

  put(Registry registry) {
    sink.add({
      ...stream.value,
      registry.key: registry,
    });
  }

  del(String key) {
    sink.add({
      ...(stream.value..removeWhere((k, value) => key == k)),
    });
  }

  Registry? get(String key) {
    return stream.value[key];
  }

  Map<String, ClientProvider> _clientProviders = {};

  void setDefault(Registry registry) {
    sink.add({
      ...(stream.value.map((key, value) => MapEntry(
          key,
          value.copyWith(
            isDefault: registry.key == value.key,
          )))),
    });
  }

  ClientProvider clientProvider(BuildContext context, String key) {
    return _clientProviders[key] ??= () {
      final p = get(key)?.let((r) {
        return ClientProvider(endpoint: r.endpoint, roundTripBuilders: [
          HarborOidcAutoLogin(
            context: context,
            onLogon: (Registry registry) {
              put(registry);
            },
          ),
          WwwAuthentication(() {
            final r = get(key);

            return BasicAuth(
              username: r?.username ?? "",
              password: r?.password ?? "",
            );
          })
        ]);
      });

      if (p == null) {
        throw Exception("registry not found");
      }

      return p;
    }();
  }
}
