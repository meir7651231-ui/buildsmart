import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kStorageKey = 'bs.chat-settings.v1';

enum ChatMediaDownload { wifiOnly, cellular, both, never }

enum ChatPrivacy { everyone, contacts, saved }

enum ChatBackupFreq { daily, weekly, monthly }

enum ChatLang { he, ar, en }

class ChatSettings {
  const ChatSettings({
    required this.readReceipts,
    required this.typingIndicator,
    required this.lockScreenPreview,
    required this.mediaDownload,
    required this.chatPrivacy,
    required this.backupEnabled,
    required this.backupFreq,
    required this.lang,
    required this.businessHoursEnabled,
    required this.businessStartHour,
    required this.businessStartMin,
    required this.businessEndHour,
    required this.businessEndMin,
    required this.autoReplyMessage,
  });

  final bool readReceipts;
  final bool typingIndicator;
  final bool lockScreenPreview;
  final ChatMediaDownload mediaDownload;
  final ChatPrivacy chatPrivacy;
  final bool backupEnabled;
  final ChatBackupFreq backupFreq;
  final ChatLang lang;
  final bool businessHoursEnabled;
  final int businessStartHour;
  final int businessStartMin;
  final int businessEndHour;
  final int businessEndMin;
  final String autoReplyMessage;

  static const ChatSettings defaults = ChatSettings(
    readReceipts: true,
    typingIndicator: true,
    lockScreenPreview: true,
    mediaDownload: ChatMediaDownload.wifiOnly,
    chatPrivacy: ChatPrivacy.contacts,
    backupEnabled: false,
    backupFreq: ChatBackupFreq.daily,
    lang: ChatLang.he,
    businessHoursEnabled: false,
    businessStartHour: 8,
    businessStartMin: 0,
    businessEndHour: 18,
    businessEndMin: 0,
    autoReplyMessage: '',
  );

  TimeOfDay get businessStart =>
      TimeOfDay(hour: businessStartHour, minute: businessStartMin);
  TimeOfDay get businessEnd =>
      TimeOfDay(hour: businessEndHour, minute: businessEndMin);

  ChatSettings copyWith({
    bool? readReceipts,
    bool? typingIndicator,
    bool? lockScreenPreview,
    ChatMediaDownload? mediaDownload,
    ChatPrivacy? chatPrivacy,
    bool? backupEnabled,
    ChatBackupFreq? backupFreq,
    ChatLang? lang,
    bool? businessHoursEnabled,
    int? businessStartHour,
    int? businessStartMin,
    int? businessEndHour,
    int? businessEndMin,
    String? autoReplyMessage,
  }) {
    return ChatSettings(
      readReceipts: readReceipts ?? this.readReceipts,
      typingIndicator: typingIndicator ?? this.typingIndicator,
      lockScreenPreview: lockScreenPreview ?? this.lockScreenPreview,
      mediaDownload: mediaDownload ?? this.mediaDownload,
      chatPrivacy: chatPrivacy ?? this.chatPrivacy,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      backupFreq: backupFreq ?? this.backupFreq,
      lang: lang ?? this.lang,
      businessHoursEnabled: businessHoursEnabled ?? this.businessHoursEnabled,
      businessStartHour: businessStartHour ?? this.businessStartHour,
      businessStartMin: businessStartMin ?? this.businessStartMin,
      businessEndHour: businessEndHour ?? this.businessEndHour,
      businessEndMin: businessEndMin ?? this.businessEndMin,
      autoReplyMessage: autoReplyMessage ?? this.autoReplyMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'readReceipts': readReceipts,
        'typingIndicator': typingIndicator,
        'lockScreenPreview': lockScreenPreview,
        'mediaDownload': mediaDownload.name,
        'chatPrivacy': chatPrivacy.name,
        'backupEnabled': backupEnabled,
        'backupFreq': backupFreq.name,
        'lang': lang.name,
        'businessHoursEnabled': businessHoursEnabled,
        'businessStartHour': businessStartHour,
        'businessStartMin': businessStartMin,
        'businessEndHour': businessEndHour,
        'businessEndMin': businessEndMin,
        'autoReplyMessage': autoReplyMessage,
      };

  // Dispatches to defaults via [_enum] / null fallbacks; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static ChatSettings fromJson(Map<String, dynamic> j) {
    int i(String k, int fallback) => (j[k] as num?)?.toInt() ?? fallback;
    bool b(String k, {bool fallback = true}) =>
        j[k] is bool ? j[k] as bool : fallback;
    return ChatSettings(
      readReceipts: b('readReceipts'),
      typingIndicator: b('typingIndicator'),
      lockScreenPreview: b('lockScreenPreview'),
      mediaDownload: _enum(
        j['mediaDownload'],
        ChatMediaDownload.values,
        ChatMediaDownload.wifiOnly,
      ),
      chatPrivacy: _enum(
        j['chatPrivacy'],
        ChatPrivacy.values,
        ChatPrivacy.contacts,
      ),
      backupEnabled: b('backupEnabled', fallback: false),
      backupFreq: _enum(
        j['backupFreq'],
        ChatBackupFreq.values,
        ChatBackupFreq.daily,
      ),
      lang: _enum(
        j['lang'],
        ChatLang.values,
        ChatLang.he,
      ),
      businessHoursEnabled: b('businessHoursEnabled', fallback: false),
      businessStartHour: i('businessStartHour', 8),
      businessStartMin: i('businessStartMin', 0),
      businessEndHour: i('businessEndHour', 18),
      businessEndMin: i('businessEndMin', 0),
      autoReplyMessage: (j['autoReplyMessage'] as String?) ?? '',
    );
  }
}

T _enum<T extends Enum>(Object? raw, List<T> values, T fallback) {
  if (raw is String) {
    for (final v in values) {
      if (v.name == raw) return v;
    }
  }
  return fallback;
}

class ChatSettingsNotifier extends StateNotifier<ChatSettings> {
  ChatSettingsNotifier() : super(ChatSettings.defaults) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      state = ChatSettings.fromJson(j);
    } on Object catch (_) {/* keep defaults */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStorageKey, jsonEncode(state.toJson()));
    } on Object catch (_) {/* best-effort */}
  }

  void update(ChatSettings Function(ChatSettings) f) {
    state = f(state);
    unawaited(_persist());
  }

  Future<void> reset() async {
    state = ChatSettings.defaults;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
    } on Object catch (_) {/* ignore */}
  }
}

final chatSettingsProvider =
    StateNotifierProvider<ChatSettingsNotifier, ChatSettings>(
  (_) => ChatSettingsNotifier(),
);
