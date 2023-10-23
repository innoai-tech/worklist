// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientProvider _$ClientProviderFromJson(Map<String, dynamic> json) =>
    ClientProvider(
      endpoint: json['endpoint'] as String,
      username: json['username'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$ClientProviderToJson(ClientProvider instance) =>
    <String, dynamic>{
      'endpoint': instance.endpoint,
      'username': instance.username,
      'password': instance.password,
    };
