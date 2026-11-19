import { readFile } from 'node:fs/promises'
import mysql from 'mysql2/promise'
try { process.loadEnvFile('.env') } catch (e) { if (e.code !== 'ENOENT') throw e }
const connection = await mysql.createConnection({ host: process.env.GAMEDB_HOST || process.env.DB_HOST || '127.0.0.1', port: Number(process.env.GAMEDB_PORT || process.env.DB_PORT || 3306), user: process.env.GAMEDB_USER || process.env.DB_USER || 'root', password: process.env.GAMEDB_PASSWORD || process.env.DB_PASSWORD || '', database: process.env.GAMEDB_NAME || 'gamedb_cmdl' })
try {
  const sql = await readFile(new URL('../../SoulLandDivine-server/docs/database/migrations/2026-11-19-code-cards.sql', import.meta.url), 'utf8')
  for (const statement of sql.replace(/^--.*$/gm, '').split(';').filter(x => x.trim())) await connection.query(statement)
  const [rows] = await connection.query("SHOW TABLES LIKE 'character_card_%'")
  console.log(`Code card migration verified: ${rows.length} tables`)
} finally { await connection.end() }
