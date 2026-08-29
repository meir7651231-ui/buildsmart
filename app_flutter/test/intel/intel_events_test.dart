// Studio Pillar 3 · step 87 — the IntelEvents registry + IntelEvent record.
//
// PROVED HERE (§5 registry contract), in the assertion style of
// test/telemetry_test.dart:
//   1. Every IntelEvents name is UNIQUE (no duplicate constant).
//   2. Every name is snake_case (^[a-z][a-z0-9_]*$) AND <= 40 chars (GA limit).
//   3. No event NAME or ALLOWED-PROP-KEY contains a PII token — with an
//      ANTI-VACUOUS guard: the detector fires on a planted `user_email`.
//   4. IntelEvent.toWire() OMITS displayName (R1-4) — the PII label never
//      reaches the wire, while the pseudonymous actorKey/uid DO.
//   5. `all` and `allowedProps` agree (single source — no drift).
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:flutter_test/flutter_test.dart';

/// snake_case: starts lower-alpha, then lower-alnum / underscore only.
final RegExp _snakeCase = RegExp(r'^[a-z][a-z0-9_]*$');

/// PII tokens that must never appear in an event name or an allowed prop key.
/// `uid` is included on purpose: it travels as a top-level pseudonymous field
/// (step 90), never as a free prop key (step 91.3).
const List<String> _piiTokens = <String>[
  'name',
  'email',
  'mail',
  'phone',
  'address',
  'passwd',
  'password',
  'secret',
  'ssn',
  'credit',
  'card',
  'cvv',
  'iban',
  'birth',
  'dob',
  'gps',
  'latitude',
  'longitude',
  'uid',
];

/// True when [key] contains any PII token (case-insensitive substring).
bool _looksLikePii(String key) {
  final lower = key.toLowerCase();
  return _piiTokens.any(lower.contains);
}

void main() {
  group('IntelEvents registry — names (§5)', () {
    test('every name is UNIQUE (no duplicate constant)', () {
      expect(
        IntelEvents.all.toSet().length,
        IntelEvents.all.length,
        reason: 'duplicate event name in IntelEvents.all',
      );
    });

    test('every name is snake_case and <= 40 chars', () {
      for (final name in IntelEvents.all) {
        expect(name.isNotEmpty, isTrue);
        expect(
          _snakeCase.hasMatch(name),
          isTrue,
          reason: '"$name" is not snake_case',
        );
        expect(
          name.length,
          lessThanOrEqualTo(40),
          reason: '"$name" exceeds the 40-char GA limit',
        );
      }
    });

    test('all == allowedProps.keys (single source, no drift)', () {
      expect(
        IntelEvents.allowedProps.keys.toSet(),
        IntelEvents.all.toSet(),
        reason: 'IntelEvents.all and allowedProps drifted apart',
      );
    });

    test('the well-known taxonomy names are present verbatim', () {
      // Locks the exact strings the later call-sites (steps 91-94/97) emit, so a
      // rename here fails loudly instead of silently drifting from a call-site.
      expect(IntelEvents.screenView, 'screen_view');
      expect(IntelEvents.searchSubmit, 'search_submit');
      expect(IntelEvents.searchNoResult, 'search_no_result');
      expect(IntelEvents.productView, 'product_view');
      expect(IntelEvents.addToCart, 'add_to_cart');
      expect(IntelEvents.cartView, 'cart_view');
      expect(IntelEvents.checkoutStart, 'checkout_start');
      expect(IntelEvents.checkoutStep, 'checkout_step');
      expect(IntelEvents.orderPlaced, 'order_placed');
      expect(IntelEvents.sessionStart, 'session_start');
      expect(IntelEvents.sessionHeartbeat, 'session_heartbeat');
      expect(IntelEvents.sessionEnd, 'session_end');
      expect(IntelEvents.identify, 'identify');
    });
  });

  group('IntelEvents registry — no PII (§4)', () {
    test('no event NAME contains a PII token', () {
      for (final name in IntelEvents.all) {
        expect(
          _looksLikePii(name),
          isFalse,
          reason: '"$name" contains a PII token',
        );
      }
    });

    test('no ALLOWED PROP KEY contains a PII token', () {
      IntelEvents.allowedProps.forEach((String event, Set<String> keys) {
        for (final key in keys) {
          expect(
            _looksLikePii(key),
            isFalse,
            reason: 'event "$event" allows PII-ish prop key "$key"',
          );
        }
      });
    });

    test('the PII detector is NOT vacuous (anti-vacuous guard)', () {
      // A planted PII key MUST trip the detector, and a clean key MUST NOT —
      // proving the two assertions above can actually fail.
      expect(_looksLikePii('user_email'), isTrue);
      expect(_looksLikePii('full_name'), isTrue);
      expect(_looksLikePii('phone_number'), isTrue);
      expect(_looksLikePii('home_address'), isTrue);
      expect(_looksLikePii('uid'), isTrue);
      expect(_looksLikePii('sku'), isFalse);
      expect(_looksLikePii('q_len'), isFalse);
      expect(_looksLikePii('screen'), isFalse);
    });
  });

  group('IntelEvent record — R1-4 displayName never leaves the device', () {
    test('toWire OMITS displayName but keeps it in memory', () {
      final e = IntelEvent(
        name: IntelEvents.screenView,
        at: DateTime.utc(2026, 1, 1, 12),
        actorKey: 'anon-abc',
        uid: 'fb-uid-9',
        sessionId: 'sess-1',
        screen: 'catalog',
        displayName: 'מאיר כהן <PLANTED-LABEL>',
        props: const <String, String>{'prev': 'home'},
      );

      // In-memory the label IS kept (the local live-feed renders it)...
      expect(e.displayName, 'מאיר כהן <PLANTED-LABEL>');

      // ...but the wire map neither keys on it nor leaks its value anywhere.
      final wire = e.toWire();
      expect(wire.containsKey('displayName'), isFalse);
      final serialized = wire.toString();
      expect(
        serialized.contains('PLANTED-LABEL'),
        isFalse,
        reason: 'displayName VALUE leaked into toWire()',
      );
      expect(serialized.contains('מאיר'), isFalse);
    });

    test('toWire carries the pseudonymous keys + scalar props (anti-vacuous)',
        () {
      final e = IntelEvent(
        name: IntelEvents.addToCart,
        at: DateTime.utc(2026, 1, 2),
        actorKey: 'anon-abc',
        uid: 'fb-uid-9',
        sessionId: 'sess-2',
        screen: 'catalog',
        props: const <String, String>{'sku': 'BS-42', 'qty': '2'},
      );
      final wire = e.toWire();
      expect(wire['name'], 'add_to_cart');
      expect(wire['actor_key'], 'anon-abc');
      expect(wire['uid'], 'fb-uid-9');
      expect(wire['session_id'], 'sess-2');
      expect(wire['screen'], 'catalog');
      expect(
        wire['props'],
        const <String, String>{'sku': 'BS-42', 'qty': '2'},
      );
      // never a displayName key, even when the field was never set
      expect(wire.containsKey('displayName'), isFalse);
    });

    test('a minimal event omits absent optional fields (no null leakage)', () {
      final e = IntelEvent(
        name: IntelEvents.identify,
        at: DateTime.utc(2026, 1, 3),
      );
      final wire = e.toWire();
      expect(wire['name'], 'identify');
      expect(wire.containsKey('actor_key'), isFalse);
      expect(wire.containsKey('uid'), isFalse);
      expect(wire.containsKey('session_id'), isFalse);
      expect(wire.containsKey('screen'), isFalse);
      expect(wire.containsKey('displayName'), isFalse);
      // props defaults to an empty map — always present and empty.
      expect(wire['props'], const <String, String>{});
    });
  });
}
