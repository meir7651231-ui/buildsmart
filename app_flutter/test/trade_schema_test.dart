// Pins the Pillar-2 core schema (step 32): every type round-trips through
// toJson/fromJson (the Pillar-5 server seam) with EXACT value-equality, string ids
// are stable, nullable fields survive both set and null, and fromJson is tolerant
// (garbage ⇒ defaults, never throws). Pure data — no live consumer yet.
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Trade round-trips; schemaVersion defaults', () {
    const x = Trade(
      id: 'electrician',
      nameHe: 'חשמל',
      emoji: '⚡',
      color: 0xFF112233,
      personaId: 'p.elec',
      published: true,
      brandIds: ['gewiss', 'legrand'],
    );
    expect(Trade.fromJson(x.toJson()), x);
    expect(Trade.fromJson(x.toJson()).schemaVersion, kTradeSchemaVersion);
  });

  test('TradeCategory round-trips (parentId set + null)', () {
    const child = TradeCategory(
      id: 'c.breakers',
      tradeId: 'electrician',
      titleHe: 'מאמ"תים',
      emoji: '🔌',
      parentId: 'c.panel',
      sortIndex: 2,
      attributeSchemaIds: ['a.amp', 'a.poles'],
      smartFixtureId: 'f.x',
    );
    expect(TradeCategory.fromJson(child.toJson()), child);
    const top =
        TradeCategory(id: 'c.panel', tradeId: 'electrician', titleHe: 'לוח', emoji: '🗄️');
    expect(TradeCategory.fromJson(top.toJson()), top);
    expect(TradeCategory.fromJson(top.toJson()).parentId, isNull);
  });

  test('AttributeValue + AttributeDef round-trip; unknown kind ⇒ freeText', () {
    const v = AttributeValue(id: 'v.16', labelHe: '16 אמפר', canonical: '16', sortIndex: 1);
    expect(AttributeValue.fromJson(v.toJson()), v);
    expect(AttributeValue.fromJson(const {'id': 'x', 'labelHe': 'א'}).canonical, isNull);

    const a = AttributeDef(
      id: 'a.amp',
      tradeId: 'electrician',
      nameHe: 'אמפר',
      emoji: '📐',
      kind: AttributeKind.dimension,
      values: [
        AttributeValue(id: 'v.16', labelHe: '16A'),
        AttributeValue(id: 'v.25', labelHe: '25A'),
      ],
      unitHe: 'A',
      isVariantAxis: true,
      required: true,
      matchTokens: ['16A', '25A'],
    );
    expect(AttributeDef.fromJson(a.toJson()), a);
    expect(
      AttributeDef.fromJson(const {'id': 'a', 'kind': 'bogus'}).kind,
      AttributeKind.freeText, // tolerant fallback
    );
  });

  test('TradeProduct round-trips (attributes + dims + image lists)', () {
    const p = TradeProduct(
      id: 'SKU-1',
      tradeId: 'electrician',
      categoryId: 'c.breakers',
      brandId: 'gewiss',
      nameHe: 'מאמ"ת 16A',
      nameEn: 'Breaker 16A',
      attributes: {'a.amp': 'v.16', 'a.poles': '1'},
      dims: {'DN': 16, 'note': 'C-curve'},
      imageFiles: ['a.png', 'b.png'],
      specImageFiles: ['spec.png'],
      qtyPack: 10,
      qtyPallet: 200,
      page: 7,
    );
    expect(TradeProduct.fromJson(p.toJson()), p);
    expect(TradeProduct.fromJson(p.toJson()).dims['DN'], 16); // legacy parity kept
  });

  test('AccessoryRule round-trips (product target + nulls)', () {
    const r = AccessoryRule(
      id: 'acc.1',
      tradeId: 'electrician',
      appliesToCategoryId: 'c.breakers',
      appliesToProductId: 'SKU-1',
      nameHe: 'מסילת DIN',
      emoji: '🔩',
      whyHe: 'נדרש להתקנה',
      mustHave: true,
      price: 12,
      linkSku: 'SKU-DIN',
    );
    expect(AccessoryRule.fromJson(r.toJson()), r);
    const r2 = AccessoryRule(
      id: 'acc.2',
      tradeId: 'electrician',
      appliesToCategoryId: 'c.breakers',
      nameHe: 'x',
      emoji: '•',
      whyHe: 'y',
    );
    expect(AccessoryRule.fromJson(r2.toJson()).appliesToProductId, isNull);
  });

  test('SmartFixture (+ SmartBrandRef + InstallStage) round-trips nested', () {
    const f = SmartFixture(
      id: 'f.panel',
      tradeId: 'electrician',
      categoryId: 'c.panel',
      nameHe: 'לוח דירתי',
      emoji: '🗄️',
      diagramTitleHe: 'חיווט לוח',
      brandRefs: [
        SmartBrandRef(name: 'Gewiss', tag: 'מומלץ', rec: true, sku: 'G1'),
        SmartBrandRef(name: 'Legrand', tag: 'חלופה'),
      ],
      accessoryRuleIds: ['acc.1', 'acc.2'],
      stages: [
        InstallStage(emoji: '1️⃣', labelHe: 'התקנת מסילה', matchTokens: ['din']),
        InstallStage(emoji: '✅', labelHe: 'בדיקה', isFinal: true),
      ],
    );
    expect(SmartFixture.fromJson(f.toJson()), f);
    final back = SmartFixture.fromJson(f.toJson());
    expect(back.brandRefs.first.rec, isTrue);
    expect(back.stages.last.isFinal, isTrue);
  });

  test('fromJson is tolerant — empty maps ⇒ defaults, never throws', () {
    expect(Trade.fromJson(const {}).id, '');
    expect(TradeProduct.fromJson(const {}).dims, isEmpty);
    expect(AttributeDef.fromJson(const {}).values, isEmpty);
    expect(SmartFixture.fromJson(const {}).stages, isEmpty);
  });
}
