// 🗄️ דאטה · חולץ מ-dart-maor/plan-demo-cleanup.dart ע"י machtzev/purify.mjs. נערך בלי לגעת במנוע.
const kFpFields = {
  'families': ['name', 'father', 'mother', 'phone', 'phone2', 'city', 'address', 'email'],
  'supporters': ['name', 'phone', 'email', 'idNum', 'cat', 'forWho'],
  'courses': ['name', 'description', 'price', 'price1', 'price2'],
  'teachers': ['name', 'phone', 'email', 'idNum', 'specialty'],
  'rooms': ['name', 'location', 'cap'],
  'events': ['title', 'type', 'customType', 'notes', 'price', 'time'],
  'volunteers': ['name', 'phone', 'area'],
  'distributionDays': ['title', 'note'],
  'tzCoordinators': ['name', 'phone'],
  'tzCampaigns': ['name', 'title', 'goal'],
  'tzEvents': ['title', 'name', 'notes'],
  'shopItems': ['name', 'kind', 'value', 'basePrice'],
  'shopStores': ['name', 'phone', 'address'],
  'shopCriteria': ['name', 'label', 'desc'],
  'shopProducts': ['name', 'title', 'kind'],
  'shopEvents': ['title', 'name', 'notes'],
  'shopIntakes': ['name', 'note'],
  'tasks': ['title', 'note', 'desc'],
  'warehouse': ['name', 'sku', 'note'],
};
// re-export שם-המקור לנוחות-הזרקה:
final fpFields = kFpFields;
