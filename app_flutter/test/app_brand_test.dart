// STAGE-3.2 — the AppBrand contract: the company-identity single source.
//
// Locks (a) today's exact values — the byte-identity DoD for the default
// build; (b) the club derivation (club follows name — swapping the name for
// company #2 re-brands the club cluster automatically); (c) shape sanity for
// the share domain (an origin, no trailing slash — call-sites append '/p/').

import 'package:buildsmart/config/app_brand.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default brand values are byte-identical to the pre-3.2 hardcodes', () {
    expect(AppBrand.name, 'BuildSmart');
    expect(AppBrand.club, 'מועדון BuildSmart');
    expect(AppBrand.shareDomain, 'https://buildsmart.app');
  });

  test('the club title derives from the name (company #2 re-brands it free)',
      () {
    expect(AppBrand.club, 'מועדון ${AppBrand.name}');
  });

  test('shareDomain is an https origin without a trailing slash', () {
    expect(AppBrand.shareDomain, startsWith('https://'));
    expect(AppBrand.shareDomain.endsWith('/'), isFalse,
        reason: "call-sites append '/p/<sku>'");
  });
}
