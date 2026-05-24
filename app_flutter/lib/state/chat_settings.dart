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

enum ChatLastSeen { everyone, contacts, nobody }

enum ChatImageQuality { original, high, medium }

enum ChatAutoDelete { disabled, days30, days90, days180 }

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
    // Section 1 — Presence
    required this.initialResponseEnabled,
    required this.lastSeenPrivacy,
    // Section 2 — Chat Notifications
    required this.callRingEnabled,
    required this.messageAlertEnabled,
    required this.chatVibration,
    // Section 3 — Media
    required this.imageQuality,
    required this.compressVideo,
    // Section 6 — Language
    required this.autoTranslate,
    // Section 7 — Business
    required this.catalogInChat,
    required this.paymentInChat,
    // Section 8 — Bot
    required this.botEnabled,
    required this.greetingEnabled,
    required this.greetingMessage,
    // Section 9 — Archive
    required this.autoArchive,
    required this.autoDeletePolicy,
    required this.spamFilter,
    required this.backupBeforeDelete,
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

  // Section 1 — Presence
  final bool initialResponseEnabled;
  final ChatLastSeen lastSeenPrivacy;

  // Section 2 — Chat Notifications
  final bool callRingEnabled;
  final bool messageAlertEnabled;
  final bool chatVibration;

  // Section 3 — Media
  final ChatImageQuality imageQuality;
  final bool compressVideo;

  // Section 6 — Language
  final bool autoTranslate;

  // Section 7 — Business
  final bool catalogInChat;
  final bool paymentInChat;

  // Section 8 — Bot
  final bool botEnabled;
  final bool greetingEnabled;
  final String greetingMessage;

  // Section 9 — Archive
  final bool autoArchive;
  final ChatAutoDelete autoDeletePolicy;
  final bool spamFilter;
  final bool backupBeforeDelete;

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
    initialResponseEnabled: false,
    lastSeenPrivacy: ChatLastSeen.contacts,
    callRingEnabled: true,
    messageAlertEnabled: true,
    chatVibration: true,
    imageQuality: ChatImageQuality.high,
    compressVideo: true,
    autoTranslate: false,
    catalogInChat: false,
    paymentInChat: false,
    botEnabled: false,
    greetingEnabled: false,
    greetingMessage: '',
    autoArchive: false,
    autoDeletePolicy: ChatAutoDelete.disabled,
    spamFilter: true,
    backupBeforeDelete: true,
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
    bool? initialResponseEnabled,
    ChatLastSeen? lastSeenPrivacy,
    bool? callRingEnabled,
    bool? messageAlertEnabled,
    bool? chatVibration,
    ChatImageQuality? imageQuality,
    bool? compressVideo,
    bool? autoTranslate,
    bool? catalogInChat,
    bool? paymentInChat,
    bool? botEnabled,
    bool? greetingEnabled,
    String? greetingMessage,
    bool? autoArchive,
    ChatAutoDelete? autoDeletePolicy,
    bool? spamFilter,
    bool? backupBeforeDelete,
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
      initialResponseEnabled:
          initialResponseEnabled ?? this.initialResponseEnabled,
      lastSeenPrivacy: lastSeenPrivacy ?? this.lastSeenPrivacy,
      callRingEnabled: callRingEnabled ?? this.callRingEnabled,
      messageAlertEnabled: messageAlertEnabled ?? this.messageAlertEnabled,
      chatVibration: chatVibration ?? this.chatVibration,
      imageQuality: imageQuality ?? this.imageQuality,
      compressVideo: compressVideo ?? this.compressVideo,
      autoTranslate: autoTranslate ?? this.autoTranslate,
      catalogInChat: catalogInChat ?? this.catalogInChat,
      paymentInChat: paymentInChat ?? this.paymentInChat,
      botEnabled: botEnabled ?? this.botEnabled,
      greetingEnabled: greetingEnabled ?? this.greetingEnabled,
      greetingMessage: greetingMessage ?? this.greetingMessage,
      autoArchive: autoArchive ?? this.autoArchive,
      autoDeletePolicy: autoDeletePolicy ?? this.autoDeletePolicy,
      spamFilter: spamFilter ?? this.spamFilter,
      backupBeforeDelete: backupBeforeDelete ?? this.backupBeforeDelete,
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
        'initialResponseEnabled': initialResponseEnabled,
        'lastSeenPrivacy': lastSeenPrivacy.name,
        'callRingEnabled': callRingEnabled,
        'messageAlertEnabled': messageAlertEnabled,
        'chatVibration': chatVibration,
        'imageQuality': imageQuality.name,
        'compressVideo': compressVideo,
        'autoTranslate': autoTranslate,
        'catalogInChat': catalogInChat,
        'paymentInChat': paymentInChat,
        'botEnabled': botEnabled,
        'greetingEnabled': greetingEnabled,
        'greetingMessage': greetingMessage,
        'autoArchive': autoArchive,
        'autoDeletePolicy': autoDeletePolicy.name,
        'spamFilter': spamFilter,
        'backupBeforeDelete': backupBeforeDelete,
      };

  // Dispatches to defaults via [_enum] / null fallbacks; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static ChatSettings fromJson(Map<String, dynamic> j) {
    int i(String k, int fallback) => (j[k] as num?)?.toInt() ?? fallback;
    return ChatSettings(
      readReceipts: j['readReceipts'] != false,
      typingIndicator: j['typingIndicator'] != false,
      lockScreenPreview: j['lockScreenPreview'] != false,
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
      backupEnabled: j['backupEnabled'] == true,
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
      businessHoursEnabled: j['businessHoursEnabled'] == true,
      businessStartHour: i('businessStartHour', 8),
      businessStartMin: i('businessStartMin', 0),
      businessEndHour: i('businessEndHour', 18),
      businessEndMin: i('businessEndMin', 0),
      autoReplyMessage: (j['autoReplyMessage'] as String?) ?? '',
      initialResponseEnabled: j['initialResponseEnabled'] == true,
      lastSeenPrivacy: _enum(
        j['lastSeenPrivacy'],
        ChatLastSeen.values,
        ChatLastSeen.contacts,
      ),
      callRingEnabled: j['callRingEnabled'] != false,
      messageAlertEnabled: j['messageAlertEnabled'] != false,
      chatVibration: j['chatVibration'] != false,
      imageQuality: _enum(
        j['imageQuality'],
        ChatImageQuality.values,
        ChatImageQuality.high,
      ),
      compressVideo: j['compressVideo'] != false,
      autoTranslate: j['autoTranslate'] == true,
      catalogInChat: j['catalogInChat'] == true,
      paymentInChat: j['paymentInChat'] == true,
      botEnabled: j['botEnabled'] == true,
      greetingEnabled: j['greetingEnabled'] == true,
      greetingMessage: (j['greetingMessage'] as String?) ?? '',
      autoArchive: j['autoArchive'] == true,
      autoDeletePolicy: _enum(
        j['autoDeletePolicy'],
        ChatAutoDelete.values,
        ChatAutoDelete.disabled,
      ),
      spamFilter: j['spamFilter'] != false,
      backupBeforeDelete: j['backupBeforeDelete'] != false,
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
