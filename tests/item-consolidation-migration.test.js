import test from 'node:test';
import assert from 'node:assert/strict';
import {
  LEGACY_TO_CANONICAL, canonicalId,
  canonicalizeMailReward, planInventoryRows
} from '../scripts/migrate-item-consolidation.mjs';

const row = (uid, typeId, pileNum, opts = {}) => ({
  uid: String(uid), ownerUid: 42, typeId, pileNum: String(pileNum),
  equipIndex: 0, generateTime: 1700000000, protectedRingSource: 0, ...opts
});

test('Only fully equivalent SoulBone boxes have aliases', () => {
  assert.deepEqual(LEGACY_TO_CANONICAL, { 8507: 8505, 8508: 8506, 8511: 8501 });
  assert.equal(canonicalId(8507), 8505);
  assert.equal(canonicalId(8508), 8506);
  assert.equal(canonicalId(8511), 8501);
  for (const id of [7201, 4007, 4008, 4029, 4030, 7409, 7809, 9421])
    assert.equal(canonicalId(id), id);
});

test('Mail converts only normal-item rewards and preserves quantities and attributes', () => {
  assert.deepEqual(
    canonicalizeMailReward('8511:2:4@abc|8507:2:3|8508:1:5|18511:2:6'),
    { value: '8501:2:4@abc|8505:2:3|8508:1:5|18511:2:6', changed: true });
  assert.deepEqual(canonicalizeMailReward('4007:2:99|8507:1:2'),
    { value: '4007:2:99|8507:1:2', changed: false });
  assert.deepEqual(canonicalizeMailReward(null), { value: null, changed: false });
  assert.throws(() => canonicalizeMailReward('other reward 8507'), /Unrecognized/);
});

test('One-to-one ID migration and compatible stack merge conserve quantity', () => {
  const data = [row(10, 8507, 20), row(11, 8505, 10), row(12, 8507, 15)];
  const p = planInventoryRows(data);
  assert.equal(p.convertedUnits, '35');
  assert.deepEqual(p.affectedOwners, ['42']);
  assert.equal(p.updates.length, 1);
  assert.equal(p.updates[0].row.uid, '11');
  assert.equal(p.updates[0].typeId, 8505);
  assert.equal(p.updates[0].pileNum, '45');
  assert.deepEqual(p.deletes.map(x => x.uid).sort(), ['10', '12']);
  assert.equal(p.before.reduce((n, x) => n + BigInt(x.pileNum), 0n), 45n);
});

test('Different generation times, ownership, protection, equip states stay separate', () => {
  const data = [
    row(10, 8507, 20),
    row(11, 8505, 10, { generateTime: 1700000001 }),
    row(12, 8507, 15, { protectedRingSource: 1 }),
    row(13, 8508, 8, { ownerUid: 43 }),
    row(14, 8507, 7, { equipIndex: 1 })
  ];
  const p = planInventoryRows(data);
  assert.equal(p.updates.length, 4);
  assert.equal(p.deletes.length, 0);
  assert.equal(p.convertedUnits, '50');
  assert.deepEqual(p.affectedOwners, ['42', '43']);
});

test('Existing UIDs are reused to fit within canonical stack limits', () => {
  const p = planInventoryRows([row(10, 8507, 999), row(11, 8505, 10)]);
  assert.equal(p.updates.length, 2);
  assert.equal(p.deletes.length, 0);
  assert.deepEqual(p.updates.map(x => x.pileNum), ['999', '10']);
  assert.equal(p.convertedUnits, '999');
});

test('Oversized preexisting stacks fail closed rather than silently losing item quantity', () => {
  assert.throws(() => planInventoryRows([row(10, 8507, 1000)]), /oversized/);
});

test('Already-canonical stacks do not receive duplicated quantities on retry', () => {
  const p = planInventoryRows([row(10, 8505, 45), row(11, 8501, 7)]);
  assert.deepEqual(p.updates, []);
  assert.deepEqual(p.deletes, []);
  assert.equal(p.convertedUnits, '0');
  assert.deepEqual(p.affectedOwners, []);
});
