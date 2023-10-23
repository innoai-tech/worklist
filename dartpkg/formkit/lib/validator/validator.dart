import 'package:flutter/material.dart';

FormFieldValidator<T> validateRequired<T>({String? msg}) {
  final errMsg = msg ?? "不能为空";

  return (T? value) {
    if (value == null || (value is String && value.isEmpty)) {
      return errMsg;
    }
    return null;
  };
}

FormFieldValidator<T> validateFormatURL<T>({String? msg}) {
  final errMsg = msg ?? "URL 地址不合法";

  return (T? value) {
    if (value == null || !(value is String)) {
      return errMsg;
    }

    try {
      final u = Uri.parse(value.trim());

      if (u.scheme == "" || u.host == "") {
        return errMsg;
      }

      return null;
    } catch (err) {
      return errMsg;
    }
  };
}

FormFieldValidator<T> compose<T>(List<FormFieldValidator<T>> validators) {
  return (T? value) {
    for (var validator in validators) {
      final errMsg = validator(value);

      if (errMsg != null) {
        return errMsg;
      }
    }
    return null;
  };
}
