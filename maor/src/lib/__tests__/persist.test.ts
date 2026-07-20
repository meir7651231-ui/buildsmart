import { describe, it, expect } from 'vitest';
import { migrate } from '../../store/persist';
import { DB_VERSION } from '../../types/domain';

/** Minimal v1 prototype-style blob (missing most v2 fields). */
function v1Blob(): Record<string, unknown> {
  return {
    v: 1,
    families: [
      { id: 'f1', name: 'כהן', members: [{ id: 'm1', first: 'דוד' }] },
      // duplicate id — must be deduped
      { id: 'f1', name: 'כהן (כפול)' },
      // missing id + missing arrays — must be repaired
      { name: 'לוי' },
    ],
    courses: [{ id: 'c1', name: 'ציור' }],
    seq: 7,
  };
}

describe('migrate', () => {
  it('upgrades a v1 prototype blob to the current version', () => {
    const db = migrate(v1Blob());
    expect(db).not.toBeNull();
    expect(db!.v).toBe(DB_VERSION);
    expect(db!.courses).toHaveLength(1);
    // fields absent in v1 get defaults from emptyDb
    expect(db!.orgName).toBeTruthy();
    expect(Array.isArray(db!.supporters)).toBe(true);
    expect(db!.notif).toBeDefined();
    expect(db!.ui).toBeDefined();
    // seq never goes below the base floor
    expect(db!.seq).toBeGreaterThanOrEqual(7);
  });

  it('dedups families by id and repairs missing ids/arrays', () => {
    const db = migrate(v1Blob())!;
    const ids = db.families.map((f) => f.id);
    expect(new Set(ids).size).toBe(ids.length); // no duplicates
    expect(ids.filter((id) => id === 'f1')).toHaveLength(1);
    // first occurrence wins
    expect(db.families.find((f) => f.id === 'f1')!.name).toBe('כהן');
    // family without id got a generated one; missing arrays filled
    const levi = db.families.find((f) => f.name === 'לוי')!;
    expect(levi.id).toBeTruthy();
    expect(levi.members).toEqual([]);
    expect(levi.docs).toEqual([]);
  });

  it('returns null on unknown (future) version', () => {
    expect(migrate({ v: DB_VERSION + 1, families: [] })).toBeNull();
    expect(migrate({ v: 999 })).toBeNull();
  });

  it('returns null on non-objects and blobs without a version', () => {
    expect(migrate(null)).toBeNull();
    expect(migrate(undefined)).toBeNull();
    expect(migrate('nope')).toBeNull();
    expect(migrate(42)).toBeNull();
    expect(migrate({})).toBeNull();
    expect(migrate({ families: [] })).toBeNull();
  });

  it('accepts a current-version blob and normalizes bad arrays', () => {
    const db = migrate({ v: DB_VERSION, families: 'garbage', events: null });
    expect(db).not.toBeNull();
    expect(db!.families).toEqual([]);
    expect(db!.events).toEqual([]);
  });
});
