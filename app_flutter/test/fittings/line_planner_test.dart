// 🔑 Phase D (intel) — line planner golden: the bridge from the connection-graph
// (products) into the fittings engine (RunElement route → 3D/spec). Verifies the
// product→route mapping (families, ODs, reducer od2, elbow default-dir), that
// non-fitting products are skipped, and that a from==to plan is complete.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String nameHe, String categoryHe) => LipskeyCatalogProduct(
      sku: 'L-$nameHe',
      nameHe: nameHe,
      nameEn: '',
      categoryHe: categoryHe,
      categoryEn: '',
      categoryEmoji: '🔧',
      page: 1,
    );

void main() {
  group('routeFromProducts — connection-graph → engine route', () {
    test('🔑 a PPR chain maps to families + ODs; elbow gets a default bend', () {
      final route = routeFromProducts([
        _p('מצמד PPR 32', kPprCouplers),
        _p('ברך PPR 90° 32', kPprElbows),
        _p('מצמד PPR 32', kPprCouplers),
      ]);
      expect(route.map((r) => r.family).toList(),
          [Family.coupler, Family.elbow90, Family.coupler],);
      expect(route.every((r) => r.od == 32), isTrue);
      // the elbow bends (up) so the 3D shows a turn; straight parts stay right
      expect(route[1].dir, Dir.up);
      expect(route[0].dir, Dir.right);
    });

    test('🔑 a reducer carries its second diameter (od2)', () {
      final route = routeFromProducts([_p('מצמד מעבר PPR 50x32', kPprCouplers)]);
      expect(route, hasLength(1));
      expect(route.single.family, Family.reducer);
      expect(route.single.od, 50);
      expect(route.single.od2, 32);
    });

    test('🔑 non-fitting products (pipe/fixture) are skipped — never mis-placed', () {
      final route = routeFromProducts([
        _p('מצמד PPR 32', kPprCouplers),
        _p('צינור PPR 32', 'צינורות PPR'), // not an engine family → skipped
        _p('מסעף PPR 32', kPprTees),
      ]);
      expect(route.map((r) => r.family).toList(), [Family.coupler, Family.tee]);
    });

    test('empty / all-unmappable → empty route (no crash)', () {
      expect(routeFromProducts(const []), isEmpty);
      expect(routeFromProducts([_p('צינור PPR', 'צינורות PPR')]), isEmpty);
    });
  });

  group('planFittingLine — grounded in findShortestPath', () {
    test('🔑 from==to → complete plan with a single-fitting route', () {
      final c = _p('מצמד PPR 32', kPprCouplers);
      final plan = planFittingLine(c, c);
      expect(plan.complete, isTrue);
      expect(plan.products, hasLength(1));
      expect(plan.route.single.family, Family.coupler);
      expect(plan.isRenderable, isTrue);
    });

    test('the plan wraps the raw path + the renderable sub-route consistently', () {
      final c = _p('מצמד PPR 40', kPprCouplers);
      final plan = planFittingLine(c, c);
      // the route is exactly routeFromProducts(products) — no drift (compare by
      // fields; RunElement has no value-equality).
      final expected = routeFromProducts(plan.products);
      String sig(RunElement r) => '${r.family}|${r.od}|${r.od2}|${r.dir}';
      expect(plan.route.map(sig).toList(), expected.map(sig).toList());
    });
  });
}
