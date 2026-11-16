#!/usr/bin/env node
/**
 * Consolidate only proven-equivalent SoulLandDivine normal items.
 *
 * Default: read-only preview.
 * Apply: stop ALL game server processes first; this command refuses to apply while they run.
 * Every apply automatically creates an SQL backup before changing the database.
 *
 * Usage: node scripts/migrate-item-consolidation.mjs [--apply]
 * Optional: --database=NAME --backup-dir=PATH
 *
 * Migration affects one named game database per invocation; execute for each game shard.
 */
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const mysql = require('mysql2/promise');
const HERE = path.dirname(fileURLToPath(import.meta.url));
const WEB_ROOT = path.resolve(HERE, '..');
const WORKSPACE = path.resolve(WEB_ROOT, '..');

export const VERSION = '20261116_normal_soulbone_boxes_v1';
export const LEGACY_TO_CANONICAL = Object.freeze({ 8507: 8505, 8508: 8506, 8511: 8501 });
export const STACK_LIMITS = Object.freeze({ 8501: 999, 8505: 999, 8506: 999 });
const OLD_IDS = Object.keys(LEGACY_TO_CANONICAL).map(Number);
const TARGET_IDS = [...new Set([...OLD_IDS, ...Object.values(LEGACY_TO_CANONICAL)])];
const PROCESS_NAMES = ['GlobalServer', 'GateServer', 'ManagerServer', 'RelationServer',
  'BarrackServer', 'CrossServer', 'ZoneServer', 'AdminAPI'];

export function canonicalId(id) {
  return LEGACY_TO_CANONICAL[id] ?? Number(id);
}

export function canonicalizeMailReward(reward) {
  if (reward == null || reward === '') return { value: reward, changed: false };
  if (typeof reward !== 'string') throw new Error('Expected mail reward to be a string');
  let changed = false;
  const tokens = reward.split('|').map(part => {
    // Reward format is item-id:reward-type:quantity[:special metadata].
    const match = part.match(/^(\d+):(\d+):(.+)$/);
    if (!match) {
      if (OLD_IDS.some(id => new RegExp('(^|[^0-9])' + id + '([^0-9]|$)').test(part)))
        throw new Error('Unrecognized mail reward syntax with a legacy ID');
      return part;
    }
    const [, rawId, rawRewardType, suffix] = match;
    const id = Number(rawId);
    if (rawRewardType !== '2' || !Object.hasOwn(LEGACY_TO_CANONICAL, id)) return part;
    changed = true;
    return String(canonicalId(id)) + ':' + rawRewardType + ':' + suffix;
  });
  return { value: tokens.join('|'), changed };
}

function groupKey(row) {
  return [row.ownerUid, canonicalId(row.typeId), row.equipIndex,
    row.generateTime, row.protectedRingSource].join('|');
}

export function planInventoryRows(allRows) {
  const groups = new Map();
  for (const row of allRows) {
    if (!TARGET_IDS.includes(Number(row.typeId))) continue;
    const key = groupKey(row);
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(row);
  }
  const updates = [], deletes = [], before = [], affectedOwners = new Set();
  let convertedUnits = 0n;
  for (const members of groups.values()) {
    if (!members.some(r => OLD_IDS.includes(Number(r.typeId)))) continue;
    const targetId = canonicalId(members[0].typeId);
    const stackLimit = BigInt(STACK_LIMITS[targetId]);
    if (!stackLimit || stackLimit <= 0n) throw new Error('Missing stack maximum');
    let total = 0n;
    for (const row of members) {
      const qty = BigInt(row.pileNum);
      if (qty <= 0n || qty > stackLimit) {
        throw new Error('Invalid or oversized existing stack: item UID ' + row.uid);
      }
      total += qty;
      if (OLD_IDS.includes(Number(row.typeId))) convertedUnits += qty;
      before.push(row);
      affectedOwners.add(String(row.ownerUid));
    }
    // Keep existing canonical UIDs first, then old UIDs. Do not generate a new UID.
    const ordered = [...members].sort((a, b) => {
      const ax = Number(a.typeId) === targetId ? 0 : 1;
      const bx = Number(b.typeId) === targetId ? 0 : 1;
      if (ax !== bx) return ax - bx;
      const auid = BigInt(a.uid), buid = BigInt(b.uid);
      return auid < buid ? -1 : auid > buid ? 1 : 0;
    });
    const required = Number((total + stackLimit - 1n) / stackLimit);
    if (required > ordered.length) throw new Error('Insufficient existing UIDs to split stacks');
    let remaining = total;
    for (let i = 0; i < ordered.length; i++) {
      const row = ordered[i];
      if (i >= required) {
        deletes.push(row);
        continue;
      }
      const newQty = remaining > stackLimit ? stackLimit : remaining;
      remaining -= newQty;
      if (Number(row.typeId) !== targetId || BigInt(row.pileNum) !== newQty) {
        updates.push({ row, typeId: targetId, pileNum: newQty.toString() });
      }
    }
    if (remaining !== 0n) throw new Error('Quantity conservation check failed');
  }
  return { before, updates, deletes, convertedUnits: convertedUnits.toString(),
    affectedOwners: [...affectedOwners] };
}

function parseLocalEnv(filepath) {
  const vars = {};
  for (const line of fs.readFileSync(filepath, 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Za-z_][A-Za-z_0-9]*)\s*=\s*(.*)$/);
    if (!m) continue;
    let v = m[2].trim();
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'")))
      v = v.slice(1, -1);
    vars[m[1]] = v;
  }
  return vars;
}

function dbSettings(databaseOverride) {
  const e = { ...parseLocalEnv(path.join(WEB_ROOT, '.env')), ...process.env };
  const host = e.GAMEDB_HOST || e.DB_HOST;
  const port = Number(e.GAMEDB_PORT || e.DB_PORT || 3306);
  const user = e.GAMEDB_USER || e.DB_USER;
  const password = e.GAMEDB_PASSWORD || e.DB_PASSWORD;
  const database = databaseOverride || e.GAMEDB_NAME || e.DB_NAME;
  if (!host || !user || !database || !Number.isInteger(port) || port < 1 ||
      port > 65535 || password == null) throw new Error('Missing database connection settings');
  if (!/^[A-Za-z0-9_]+$/.test(database)) throw new Error('Unsafe database name');
  return { host, port, user, password, database, connectTimeout: 15000,
    supportBigNumbers: true, bigNumberStrings: true, multipleStatements: false };
}

function assertGameServersStopped() {
  if (process.platform === 'win32') {
    const ps = "(Get-Process -Name " +
      PROCESS_NAMES.map(name => "'" + name + "'").join(',') +
      " -ErrorAction SilentlyContinue | Measure-Object).Count";
    const r = spawnSync('powershell.exe', ['-NoProfile', '-Command', ps],
      { encoding: 'utf8', timeout: 15000 });
    if (r.status !== 0 || !/^\s*0\s*$/.test(r.stdout))
      throw new Error('Game server processes still running or could not verify they are stopped');
  } else {
    const r = spawnSync('pgrep', ['-f', PROCESS_NAMES.join('|')],
      { encoding: 'utf8', timeout: 15000 });
    if (r.status !== 1)
      throw new Error('Game server processes still running or could not verify they are stopped');
  }
}

function backupDatabase(settings, directory) {
  fs.mkdirSync(directory, { recursive: true });
  const name = 'item-consolidation-' + settings.database + '-' +
    new Date().toISOString().replace(/[:.]/g, '-') + '.sql';
  const file = path.resolve(directory, name);
  const exe = process.env.MARIADB_DUMP || (process.platform === 'win32'
    ? 'C:\\Program Files\\MariaDB 10.6\\bin\\mariadb-dump.exe' : 'mariadb-dump');
  const args = ['--host=' + settings.host, '--port=' + settings.port,
    '--user=' + settings.user, '--default-character-set=utf8mb4',
    '--single-transaction', '--routines', '--triggers', '--events', '--hex-blob',
    '--result-file=' + file, settings.database];
  const { password, ...rest } = settings;
  const r = spawnSync(exe, args, {
    env: { ...process.env, MYSQL_PWD: password },
    windowsHide: true, timeout: 600000, encoding: 'utf8'
  });
  if (r.status !== 0 || !fs.existsSync(file) || fs.statSync(file).size < 500) {
    if (fs.existsSync(file)) fs.unlinkSync(file);
    throw new Error('MariaDB backup failed; transaction was not started (exit ' +
      r.status + ', ' + (r.error?.code || '').slice(0, 80) + ')');
  }
  console.log('Backup created:', file, '(' + fs.statSync(file).size + ' bytes)');
  return file;
}

const placeholders = target => target.map(() => '?').join(',');
async function fetchInventory(db) {
  const [rows] = await db.query(
    'SELECT uid,ownerUid,typeId,pileNum,equipIndex,generateTime,protectedRingSource ' +
    'FROM items WHERE typeId IN (' + placeholders(TARGET_IDS) + ') ' +
    'ORDER BY ownerUid,uid', TARGET_IDS);
  return rows;
}

async function fetchMail(db) {
  const [rows] = await db.query('SELECT uid,owner_uid,reward,is_get FROM email_items ' +
    'WHERE reward IS NOT NULL AND reward <> "" ORDER BY owner_uid,uid');
  return rows;
}

async function ownerQuantities(db) {
  const [rows] = await db.query('SELECT ownerUid,SUM(pileNum) AS total FROM items GROUP BY ownerUid');
  return new Map(rows.map(r => [String(r.ownerUid), String(r.total)]));
}

async function assertSchema(db) {
  for (const [table, columns] of Object.entries({
    items: ['uid', 'ownerUid', 'typeId', 'pileNum', 'equipIndex',
      'generateTime', 'protectedRingSource'],
    email_items: ['uid', 'owner_uid', 'reward', 'is_get'],
    character: ['uid']
  })) {
    const [rows] = await db.query('SELECT column_name FROM information_schema.columns ' +
      'WHERE table_schema = DATABASE() AND table_name = ?', [table]);
    const actual = new Set(rows.map(r => r.column_name));
    if (!columns.every(x => actual.has(x))) throw new Error('Unexpected database schema: ' + table);
  }
}

async function ensureMigrationTables(db) {
  await db.query('CREATE TABLE IF NOT EXISTS item_consolidation_log (' +
    'version VARCHAR(100) NOT NULL PRIMARY KEY, applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, ' +
    'backup_path VARCHAR(1024) NOT NULL, players_checked BIGINT NOT NULL, ' +
    'players_migrated BIGINT NOT NULL, instances_updated BIGINT NOT NULL, ' +
    'instances_merged BIGINT NOT NULL, quantity_converted BIGINT NOT NULL, ' +
    'mail_rows_updated BIGINT NOT NULL, inventory_total_before DECIMAL(30,0) NOT NULL, ' +
    'inventory_total_after DECIMAL(30,0) NOT NULL) ENGINE=InnoDB');
  await db.query('CREATE TABLE IF NOT EXISTS item_consolidation_item_before (' +
    'version VARCHAR(100) NOT NULL, uid BIGINT UNSIGNED NOT NULL, ' +
    'ownerUid INT UNSIGNED NOT NULL, typeId INT UNSIGNED NOT NULL, ' +
    'pileNum BIGINT NOT NULL, equipIndex INT NOT NULL, generateTime INT NOT NULL, ' +
    'protectedRingSource TINYINT NOT NULL, PRIMARY KEY (version,uid)) ENGINE=InnoDB');
  await db.query('CREATE TABLE IF NOT EXISTS item_consolidation_mail_before (' +
    'version VARCHAR(100) NOT NULL, uid BIGINT UNSIGNED NOT NULL, ' +
    'owner_uid INT UNSIGNED NOT NULL, reward VARCHAR(255), ' +
    'PRIMARY KEY(version,uid,owner_uid)) ENGINE=InnoDB');
}

function inventoryTotal(totals) {
  let n = 0n;
  for (const v of totals.values()) n += BigInt(v);
  return n.toString();
}

function assertQuantitiesUnchanged(before, after) {
  if (before.size !== after.size)
    throw new Error('Quantity audit failed: owner count changed');
  for (const [owner, quantity] of before) {
    if (after.get(owner) !== quantity)
      throw new Error('Quantity audit failed for owner ' + owner);
  }
}

function mailPlans(mailRows) {
  const rows = [];
  for (const row of mailRows) {
    // Claimed mail is historical evidence; keep its original reward string.
    if (Number(row.is_get) !== 0) continue;
    const result = canonicalizeMailReward(row.reward);
    if (result.changed) rows.push({ row, reward: result.value });
  }
  return rows;
}

export async function inspectDatabase(db) {
  await assertSchema(db);
  const [characters] = await db.query('SELECT COUNT(*) AS n FROM `character`');
  const [total] = await db.query('SELECT COUNT(*) AS n, COALESCE(SUM(pileNum),0) AS qty FROM items');
  const inventory = planInventoryRows(await fetchInventory(db));
  const mail = mailPlans(await fetchMail(db));
  return { playersChecked: Number(characters[0].n),
    inventoryRows: Number(total[0].n),
    inventoryQuantity: String(total[0].qty),
    playersNeedingMigration: inventory.affectedOwners.length,
    itemInstancesToUpdate: inventory.updates.length,
    itemInstancesToMerge: inventory.deletes.length,
    itemQuantityToConvert: inventory.convertedUnits,
    mailRowsToUpdate: mail.length };
}

export async function applyDatabase(db, backupPath) {
  await assertSchema(db);
  await ensureMigrationTables(db); // DDL is intentionally after backup and before transaction.
  await db.beginTransaction();
  try {
    const [logged] = await db.query(
      'SELECT version FROM item_consolidation_log WHERE version = ? FOR UPDATE', [VERSION]);
    if (logged.length) {
      const preview = await inspectDatabase(db);
      if (preview.itemQuantityToConvert !== '0' || preview.mailRowsToUpdate) {
        throw new Error('Migration is logged but legacy items appeared again: investigate the grant path');
      }
      await db.rollback();
      return { version: VERSION, alreadyApplied: true, preview };
    }
    const before = await ownerQuantities(db);
    const [characters] = await db.query('SELECT COUNT(*) AS n FROM `character`');
    const rows = await fetchInventory(db);
    const plan = planInventoryRows(rows);
    const emails = mailPlans(await fetchMail(db));

    for (const row of plan.before) {
      await db.execute('INSERT INTO item_consolidation_item_before ' +
        '(version,uid,ownerUid,typeId,pileNum,equipIndex,generateTime,protectedRingSource) ' +
        'VALUES (?,?,?,?,?,?,?,?)',
      [VERSION, row.uid, row.ownerUid, row.typeId, row.pileNum,
        row.equipIndex, row.generateTime, row.protectedRingSource]);
    }
    for (const { row, typeId, pileNum } of plan.updates) {
      const [result] = await db.execute(
        'UPDATE items SET typeId=?,pileNum=? WHERE uid=? AND ownerUid=? AND typeId=? AND pileNum=?',
        [typeId, pileNum, row.uid, row.ownerUid, row.typeId, row.pileNum]);
      if (result.affectedRows !== 1)
        throw new Error('Inventory row modified concurrently or disappeared: ' + row.uid);
    }
    for (const row of plan.deletes) {
      const [result] = await db.execute('DELETE FROM items WHERE uid=? AND ownerUid=? ' +
        'AND typeId=? AND pileNum=?', [row.uid, row.ownerUid, row.typeId, row.pileNum]);
      if (result.affectedRows !== 1)
        throw new Error('Inventory stack changed concurrently: ' + row.uid);
    }
    for (const { row, reward } of emails) {
      await db.execute('INSERT INTO item_consolidation_mail_before ' +
        '(version,uid,owner_uid,reward) VALUES (?,?,?,?)',
      [VERSION, row.uid, row.owner_uid, row.reward]);
      const [result] = await db.execute(
        'UPDATE email_items SET reward=? WHERE uid=? AND owner_uid=? AND reward=?',
        [reward, row.uid, row.owner_uid, row.reward]);
      if (result.affectedRows !== 1)
        throw new Error('Mail changed concurrently: ' + row.uid);
    }
    const after = await ownerQuantities(db);
    assertQuantitiesUnchanged(before, after);
    const inventory = planInventoryRows(await fetchInventory(db));
    if (inventory.convertedUnits !== '0')
      throw new Error('Old item IDs remain after inventory migration');
    const remaining = mailPlans(await fetchMail(db));
    if (remaining.length) throw new Error('Old unclaimed mail attachments remain after migration');
    const summary = { version: VERSION, alreadyApplied: false, backupPath,
      playersChecked: Number(characters[0].n),
      playersMigrated: plan.affectedOwners.length,
      instancesUpdated: plan.updates.length,
      instancesMerged: plan.deletes.length,
      quantityConverted: plan.convertedUnits,
      mailRowsUpdated: emails.length,
      inventoryBefore: inventoryTotal(before), inventoryAfter: inventoryTotal(after) };
    await db.execute('INSERT INTO item_consolidation_log ' +
      '(version,backup_path,players_checked,players_migrated,instances_updated,' +
      'instances_merged,quantity_converted,mail_rows_updated,inventory_total_before,' +
      'inventory_total_after) VALUES (?,?,?,?,?,?,?,?,?,?)', [
        VERSION, backupPath, summary.playersChecked, summary.playersMigrated,
        summary.instancesUpdated, summary.instancesMerged,
        summary.quantityConverted, summary.mailRowsUpdated,
        summary.inventoryBefore, summary.inventoryAfter]);
    await db.commit();
    return summary;
  } catch (err) {
    await db.rollback();
    throw err;
  }
}

async function main() {
  const args = process.argv.slice(2);
  const apply = args.includes('--apply');
  const getValue = flag => args.find(x => x.startsWith(flag + '='))?.slice(flag.length + 1);
  const unknown = args.filter(x => x !== '--apply' &&
    !x.startsWith('--database=') && !x.startsWith('--backup-dir='));
  if (unknown.length) throw new Error('Unknown options: ' + unknown.join(', '));
  const settings = dbSettings(getValue('--database'));
  const db = await mysql.createConnection(settings);
  try {
    const preview = await inspectDatabase(db);
    console.log('Database:', settings.database);
    console.log('Read-only migration preview:', JSON.stringify(preview));
    if (!apply) return;
    assertGameServersStopped();
    const backup = backupDatabase(settings, getValue('--backup-dir') ||
      path.join(WORKSPACE, 'database-backups', 'item-consolidation'));
    const outcome = await applyDatabase(db, backup);
    console.log('Transaction outcome:', JSON.stringify(outcome));
    console.log('Verified post-migration:', JSON.stringify(await inspectDatabase(db)));
  } finally {
    await db.end();
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url))
  main().catch(err => { console.error('MIGRATION_FAILED:', err.message); process.exitCode = 1; });
