// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__ai_hub_screen.dart (בנייה-חכמה main) · מחווט: 8 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/logic/ai_hub_logic.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/services/weather.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/ai_hub_screen.g.dart';

class AiHubScreenBoard extends ConsumerWidget {
  const AiHubScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiHubScreenComposed(
      onTap: () {} /* TODO-לוח */,
      aiCardItems: preds.map((p) => AiCardItem(child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AiCardTop(
                    title: p.name,
                    pill: '${p.urgent ? '⚠️ ' : ''}עוד ${p.days} ימים',
                    danger: p.urgent,
                  ),
                  const SizedBox(height: 4),
                  AiCardSub('מלאי ${p.stock} · צריכה ${p.rate}/יום'),
                  if (p.urgent) ...[
                    const SizedBox(height: 8),
                    AiCardBtn(
                      label: 'הזמן עכשיו',
                      onTap: () {
                        // REAL: add one unit of the running-out product to the
                        // live cart, rebuilt from the genuine captured order-line
                        // fields the forecast carries (name · emoji · unit price).
                        ref
                            .read(smartCartProvider.notifier)
                            .add(
                              SmartCartLine(
                                productKey: 'ai-restock:${p.name}',
                                productName: p.name,
                                productEmoji: p.emoji,
                                brandName: 'מומלץ AI',
                                brandPrice: p.unitPrice,
                                productQty: 1,
                                accessories: const [],
                              ),
                            );
                        showToast(context, '${p.name} נוסף לסל');
                      },
                    ),
                  ],
                ],
              ), overdue: p.urgent)).toList(),
      aiFinTileItems: _visibleTiles.map((t) => AiFinTileItem(ic: t.ic, title: t.t, sub: t.s, onTap: () {
                      switch (t.id) {
                        case 'describe':
                          Navigator.of(
                            context,
                          ).push(DescribeToCartScreen.route());
                        case 'assistant':
                          Navigator.of(context).push(AiAssistantScreen.route());
                        case 'barcode':
                          _runBarcode(context, ref);
                        case 'voice':
                          _runVoice(context, ref);
                        case 'alt':
                          // Canonical R9 modal sheet (no duplicate full screen).
                          openCheaperAlternativesSheet(context);
                        case 'plan':
                          // Canonical R9 modal sheet (no duplicate full screen).
                          openScanPlanSheet(context);
                        default:
                          Navigator.of(
                            context,
                          ).push(_AIFeatureScreen.route(t.id));
                      }
                    })).toList(),
      bad: false,
      danger: p.urgent,
      ic: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      pct: g.pct.clamp(0, 100),
      pill: '' /* TODO-לוח: String */,
      sub: '' /* TODO-לוח: String */,
      text: '🧮 מחושב מתוך היסטוריית ההזמנות והעגלה החיה — קצב צריכה ומלאי נוכחי',
      title: p.name,
      value: fMoney(d.order),
      t: AiHubScreenTokens(),
    );
  }
}
