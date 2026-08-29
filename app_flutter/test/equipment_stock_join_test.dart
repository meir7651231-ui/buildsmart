// Wave E2b — PURE unit test for the equipment ⋈ employer-stock JOIN.
//
// Locks the FROZEN contract of `lib/logic/equipment_stock_join.dart`
// (Builder E2a, written in parallel):
//   enum StockAvailability { warehouse, site, unknown }
//   StockAvailability availabilityFor(String equipmentLabel,
//                                     List<EmployerStockItem> stock)
//
// Semantics under test (the "אין-המצאות honest match" of the contract):
//   • exact name match (normalized)            → that item's location
//   • CONTAINS-match (label's core term inside  → that item's location
//     a stock item's name, case/space-norm.)
//   • no match (unrelated names)               → unknown
//   • empty stock                              → unknown  (NEVER fabricates)
//   • normalization pinned: different case / extra (incl. inner) spaces
//     still match.
//
// PURE / Firebase-free / no widget pump: builds EmployerStockItems directly
// and calls availabilityFor — no Riverpod container, no ProviderScope.
import 'package:buildsmart/logic/equipment_stock_join.dart';
import 'package:buildsmart/state/employer_stock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('availabilityFor — exact name match → its location', () {
    test('warehouse item resolves to StockAvailability.warehouse', () {
      const stock = [
        EmployerStockItem('סרט טפלון', 'warehouse'),
        EmployerStockItem('סיליקון סניטרי', 'site'),
      ];
      expect(availabilityFor('סרט טפלון', stock), StockAvailability.warehouse);
    });

    test('site item resolves to StockAvailability.site', () {
      const stock = [
        EmployerStockItem('סרט טפלון', 'warehouse'),
        EmployerStockItem('סיליקון סניטרי', 'site'),
      ];
      expect(availabilityFor('סיליקון סניטרי', stock), StockAvailability.site);
    });
  });

  group('availabilityFor — contains-match (core term inside a stock name)', () {
    test('label core term contained in a longer stock name → its location', () {
      // Equipment label is the short core term; the stock row is the fuller
      // catalog name that CONTAINS it.
      const stock = [
        EmployerStockItem('סרט טפלון לאיטום הברגות', 'warehouse'),
      ];
      expect(
        availabilityFor('סרט טפלון', stock),
        StockAvailability.warehouse,
      );
    });

    test('stock name contained inside the equipment label → its location', () {
      // The reverse direction also counts as a contains-match: the (shorter)
      // stock name sits inside the (longer) equipment label.
      const stock = [
        EmployerStockItem('מפתח שוודי', 'site'),
      ];
      expect(
        availabilityFor('מפתח שוודי 12"', stock),
        StockAvailability.site,
      );
    });
  });

  group('availabilityFor — no match → unknown (no fabrication)', () {
    test('unrelated stock names never resolve to a location', () {
      const stock = [
        EmployerStockItem('סרט טפלון', 'warehouse'),
        EmployerStockItem('סיליקון סניטרי', 'site'),
      ];
      expect(
        availabilityFor('פטיש', stock),
        StockAvailability.unknown,
      );
    });

    test('partial-word overlap that is not the core term stays unknown', () {
      // "ברז" vs "ברגי" must NOT be conflated into a fabricated match.
      const stock = [
        EmployerStockItem('ברגי קיבוע', 'warehouse'),
      ];
      expect(
        availabilityFor('ברז ניל', stock),
        StockAvailability.unknown,
      );
    });
  });

  group('availabilityFor — empty stock → unknown (NEVER fabricates)', () {
    test('empty list yields unknown', () {
      expect(availabilityFor('סרט טפלון', const []), StockAvailability.unknown);
    });

    test('empty list yields unknown even for an empty label', () {
      expect(availabilityFor('', const []), StockAvailability.unknown);
    });
  });

  group('availabilityFor — whole-token honesty (no fabricated substring)', () {
    // אין-המצאות: a generic SINGLE stock token that merely sits inside a longer
    // label must NOT fabricate availability. Single tokens match by exact
    // equality only; containment requires the contained side to have ≥2 tokens.
    test('generic single token מפתח inside a longer label → unknown', () {
      const stock = [
        EmployerStockItem('מפתח', 'warehouse'),
      ];
      expect(
        availabilityFor('מפתח חבישה DN25 ל-HDPE', stock),
        StockAvailability.unknown,
      );
    });

    test('generic single token שקע inside מכונת ריתוך-שקע → unknown', () {
      const stock = [
        EmployerStockItem('שקע', 'site'),
      ];
      expect(
        availabilityFor('מכונת ריתוך-שקע', stock),
        StockAvailability.unknown,
      );
    });

    test('generic single token עט inside עט סימון עומק → unknown', () {
      const stock = [
        EmployerStockItem('עט', 'warehouse'),
      ];
      expect(
        availabilityFor('עט סימון עומק', stock),
        StockAvailability.unknown,
      );
    });

    // Mid-word substrings: token comparison makes these impossible to match.
    test('mid-word substring גו ⊂ גומי → unknown', () {
      const stock = [
        EmployerStockItem('גו', 'warehouse'),
      ];
      expect(
        availabilityFor('אטם גומי לברז', stock),
        StockAvailability.unknown,
      );
    });

    test('mid-word substring ני ⊂ סניטרי → unknown', () {
      const stock = [
        EmployerStockItem('ני', 'site'),
      ];
      expect(
        availabilityFor('סיליקון סניטרי', stock),
        StockAvailability.unknown,
      );
    });

    // Cross-space substring: 'ור pe' spans the normalized space inside
    // 'צינור pex' as a raw substring, but tokenization ([צינור, pex]) makes it
    // impossible — the stock tokens [ור, pe] align with nothing.
    test("cross-space substring 'ור pe' ⊂ 'צינור pex' → unknown", () {
      const stock = [
        EmployerStockItem('ור pe', 'warehouse'),
      ];
      expect(
        availabilityFor('צינור pex', stock),
        StockAvailability.unknown,
      );
    });
  });

  group('availabilityFor — normalization pinned (case / spaces)', () {
    test('case differences still match (latin)', () {
      const stock = [
        EmployerStockItem('PTFE Tape', 'warehouse'),
      ];
      expect(
        availabilityFor('ptfe tape', stock),
        StockAvailability.warehouse,
      );
    });

    test('leading / trailing whitespace is trimmed before matching', () {
      const stock = [
        EmployerStockItem('  סרט טפלון  ', 'site'),
      ];
      expect(
        availabilityFor('סרט טפלון', stock),
        StockAvailability.site,
      );
    });

    test('collapsed inner whitespace still matches', () {
      // Extra inner spaces in the label must normalize to the stock name.
      const stock = [
        EmployerStockItem('סרט טפלון', 'warehouse'),
      ];
      expect(
        availabilityFor('סרט   טפלון', stock),
        StockAvailability.warehouse,
      );
    });
  });
}
