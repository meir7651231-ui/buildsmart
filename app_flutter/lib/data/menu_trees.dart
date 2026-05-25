import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/data/sections.dart';

/// Home dial — @legacy view-home in index.html:4416-4517.
/// 4 top leaves with drills:
///   🤖 → 9 AI tools (openAIHub @21125-21133)
///   📐 → 4 plan categories (PLAN_TYPES @9659-9728)
///   📦 → 2 stock tabs (@5183-5184)
///   📋 → 10 site tools (openSiteHub @19858-19868)
const List<Section> kHomeTree = [
  Section(
    id: 'home-ai',
    emoji: '🤖',
    title: 'בינה מלאכותית ואוטומציה',
    children: [
      Section(id: 'ai-stock',     emoji: '📦',  title: 'חיזוי מלאי'),
      Section(id: 'ai-barcode',   emoji: '📷',  title: 'סורק ברקוד'),
      Section(id: 'ai-voice',     emoji: '🎙️', title: 'דיבור למשימה'),
      Section(id: 'ai-alt',       emoji: '💡',  title: 'חלופות זולות'),
      Section(id: 'ai-plan',      emoji: '📐',  title: 'סריקת תוכניות'),
      Section(id: 'ai-3way',      emoji: '🔗',  title: 'התאמה משולשת'),
      Section(id: 'ai-weather',   emoji: '🌦️', title: 'אוטומציית מזג אוויר'),
      Section(id: 'ai-wear',      emoji: '🔧',  title: 'זיהוי בלאי'),
      Section(id: 'ai-analytics', emoji: '📊',  title: 'Analytics חכם'),
    ],
  ),
  Section(
    id: 'home-scan',
    emoji: '📐',
    title: 'סרוק תוכנית עבודה',
    children: [
      Section(id: 'plan-plumbing', emoji: '🚿',  title: 'אינסטלציה'),
      Section(id: 'plan-electric', emoji: '⚡',  title: 'חשמל'),
      Section(id: 'plan-arch',     emoji: '🏛️', title: 'אדריכלות'),
      Section(id: 'plan-finish',   emoji: '🎨',  title: 'גמר'),
    ],
  ),
  Section(
    id: 'home-stock',
    emoji: '📦',
    title: 'המלאי שלי',
    children: [
      Section(id: 'stock-warehouse', emoji: '🏬',  title: 'המחסן'),
      Section(id: 'stock-site',      emoji: '🏗️', title: 'האתר'),
    ],
  ),
  Section(
    id: 'home-tasks',
    emoji: '📋',
    title: 'משימות העבודה',
    children: [
      Section(id: 'site-gantt',   emoji: '📅',  title: 'תרשים גאנט'),
      Section(id: 'site-snag',    emoji: '🔧',  title: 'רשימת ליקויים'),
      Section(id: 'site-loc',     emoji: '🏢',  title: 'קומה · דירה · חדר'),
      Section(id: 'site-attend',  emoji: '📍',  title: 'נוכחות GPS'),
      Section(id: 'site-diary',   emoji: '📓',  title: 'יומן עבודה'),
      Section(id: 'site-safety',  emoji: '🦺',  title: 'התראות בטיחות'),
      Section(id: 'site-deps',    emoji: '🔗',  title: 'תלויות חומרים'),
      Section(id: 'site-photos',  emoji: '📸',  title: 'צילום לפני/אחרי'),
      Section(id: 'site-inspect', emoji: '🔍',  title: 'ביקורות מפקח'),
      Section(id: 'site-archive', emoji: '🗄️', title: 'ארכיון פרויקטים'),
    ],
  ),
];

/// Cart dial — @legacy index.html:5060-5061 + :5103-5104 (vs-btn switch)
/// + :5074-5081 (ca-svc supply-chain services).
const List<Section> kCartTree = [
  Section(id: 'cart-mine', emoji: '🛒', title: 'הסל שלי'),
  Section(
    id: 'cart-orders',
    emoji: '📦',
    title: 'ההזמנות שלי',
    children: [
      Section(id: 'svc-rental',   emoji: '🔧',  title: 'השכרת כלים'),
      Section(id: 'svc-deposits', emoji: '💰',  title: 'פקדונות'),
      Section(id: 'svc-return',   emoji: '↩️', title: 'החזרה חדשה'),
      Section(id: 'svc-rfq',      emoji: '📨',  title: 'מכרז ספקים'),
      Section(id: 'svc-msds',     emoji: '🧪',  title: 'גיליונות בטיחות'),
      Section(id: 'svc-compare',  emoji: '📊',  title: 'השוואת מחירים'),
    ],
  ),
];

/// Finance hub — @legacy openFinanceHub @ index.html:19489-19498.
/// 10 tiles, ic+t verbatim.
const List<Section> kFinanceHub = [
  Section(id: 'fin-index',     emoji: '📈',  title: 'הצמדה למדד'),
  Section(id: 'fin-payterms',  emoji: '🗓️', title: 'תנאי תשלום'),
  Section(id: 'fin-subs',      emoji: '👷',  title: 'קבלני משנה'),
  Section(id: 'fin-approvals', emoji: '✅',  title: 'אישורי רכש'),
  Section(id: 'fin-thresh',    emoji: '🔔',  title: 'התראות חריגה'),
  Section(id: 'fin-roi',       emoji: '📊',  title: 'ניתוח ROI'),
  Section(id: 'fin-invsplit',  emoji: '🧾',  title: 'פיצול חשבוניות'),
  Section(id: 'fin-penalty',   emoji: '⏰',  title: 'פיצויים וקנסות'),
  Section(id: 'fin-reports',   emoji: '📄',  title: 'דוחות PDF'),
  Section(id: 'fin-fx',        emoji: '💱',  title: 'רכש במט״ח'),
];

/// Projects dial — 3 project names + finance hub.
List<Section> projectsTree() => [
      for (final p in kProjects)
        Section(id: p.id, emoji: '🏗️', title: p.name),
      const Section(
        id: 'fin-hub',
        emoji: '📊',
        title: 'מרכז פיננסים',
        children: kFinanceHub,
      ),
    ];
