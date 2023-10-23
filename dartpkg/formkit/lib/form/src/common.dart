import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:setup_widget/setup_widget.dart';

import 'ext.dart';

class Section extends SetupWidget<Section> {
  final Widget? label;
  final List<Widget> children;
  final List<Widget>? actions;

  const Section({
    required this.children,
    this.label,
    this.actions,
    super.key,
  });

  @override
  setup(sc) {
    return () {
      return sc.widget.label?.let(
            (label) => DefaultTextStyle.merge(
              style: Theme.of(sc.context).primaryTextTheme.bodySmall,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.all(0),
                      style: ListTileStyle.drawer,
                      title: DefaultTextStyle.merge(
                        child: label,
                        style: TextStyle(
                          color: Theme.of(sc.context).colorScheme.primary,
                        ),
                      ),
                      trailing: sc.widget.actions?.let((actions) => Wrap(
                            children: actions,
                          )),
                    ),
                    Wrap(
                      runSpacing: 16,
                      children: sc.widget.children,
                    ),
                  ]),
            ),
          ) ??
          Wrap(
            runSpacing: 16,
            children: sc.widget.children,
          );
    };
  }
}

class InputView extends SetupWidget<InputView> {
  final Widget label;
  final Widget Function(dynamic value) builder;
  final dynamic value;
  final FormFieldValidator? validator;

  const InputView({
    required this.label,
    required this.builder,
    this.value,
    this.validator,
    super.key,
  });

  @override
  setup(sc) {
    final formFieldKey = GlobalKey<FormFieldState<String?>>();

    toObservable(() => sc.widget.value).doOnData((newValue) {
      formFieldKey.currentState?.didChange(newValue);
    }).listenOnMountedUntilUnmounted();

    return () {
      return FormField(
          key: formFieldKey,
          initialValue: sc.widget.value,
          validator: sc.widget.validator,
          builder: (state) {
            return InputDecorator(
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: InputBorder.none,
                label: label,
                isDense: true,
                errorText: state.errorText,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: DefaultTextStyle.merge(
                    child: sc.widget.builder(state.value),
                    style: Theme.of(sc.context).textTheme.bodyLarge),
              ),
            );
          });
    };
  }
}
