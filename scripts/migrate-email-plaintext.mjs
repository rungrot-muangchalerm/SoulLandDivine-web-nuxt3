// Run with the web stopped: node --env-file=.env scripts/migrate-email-plaintext.mjs
import mysql from 'mysql2/promise'
import { createDecipheriv } from 'node:crypto'

const db = await mysql.createConnection({
  host: process.env.DB_HOST || '127.0.0.1', port: Number(process.env.DB_PORT || 3306),
  database: process.env.DB_NAME || 'dlbackstage', user: process.env.DB_USER || 'root', password: process.env.DB_PASSWORD || '',
  charset: 'utf8mb4',
})
try {
  const [columns] = await db.query('SHOW COLUMNS FROM admin_email_accounts')
  if (!columns.some(c => c.Field === 'password_cipher')) {
    if (!columns.some(c => c.Field === 'password_plaintext')) throw new Error('Unexpected account schema')
    console.log('Plaintext schema already ready')
  } else {
    const secret = process.env.EMAIL_VAULT_KEY || ''
    if (!/^[a-f0-9]{64}$/i.test(secret)) throw new Error('Original EMAIL_VAULT_KEY is required')
    if (!columns.some(c => c.Field === 'password_plaintext')) {
      await db.query('ALTER TABLE admin_email_accounts ADD COLUMN password_plaintext TEXT NULL')
    }
    await db.beginTransaction()
    const [rows] = await db.query('SELECT id, password_cipher FROM admin_email_accounts FOR UPDATE')
    for (const row of rows) {
      const [iv, tag, data] = row.password_cipher.split('.').map(v => Buffer.from(v, 'base64'))
      const decipher = createDecipheriv('aes-256-gcm', Buffer.from(secret, 'hex'), iv)
      decipher.setAuthTag(tag)
      const password = Buffer.concat([decipher.update(data), decipher.final()]).toString('utf8')
      await db.execute('UPDATE admin_email_accounts SET password_plaintext=? WHERE id=?', [password, row.id])
      const [check] = await db.execute('SELECT password_plaintext FROM admin_email_accounts WHERE id=?', [row.id])
      if (check[0]?.password_plaintext !== password) throw new Error('Password verification failed')
    }
    await db.commit()
    await db.query('ALTER TABLE admin_email_accounts MODIFY password_plaintext TEXT NOT NULL, DROP COLUMN password_cipher')
    console.log(`Migrated and verified ${rows.length} accounts; passwords were not printed`)
  }
} catch (error) {
  await db.rollback()
  throw error
} finally { await db.end() }
