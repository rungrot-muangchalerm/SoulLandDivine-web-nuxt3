import { getDatabase } from './database'

const operationLogLockName = 'dlgm_operationlog_id'

interface OperationLogEntry {
  username: string
  ip: string
  content: string
  type: string
}

export async function recordOperationLog(entry: OperationLogEntry) {
  const connection = await getDatabase().getConnection()
  let lockAcquired = false

  try {
    const [lockRows] = await connection.execute(
      'SELECT GET_LOCK(?, 5) AS acquired',
      [operationLogLockName],
    )
    lockAcquired = (lockRows as Array<{ acquired: number | null }>)[0]?.acquired === 1
    if (!lockAcquired) {
      throw createError({ statusCode: 503, statusMessage: 'ไม่สามารถบันทึกประวัติการทำรายการได้' })
    }

    const [idRows] = await connection.execute(
      'SELECT COALESCE(MAX(id), 0) + 1 AS nextId FROM operationlog',
    )
    const id = (idRows as Array<{ nextId: number }>)[0].nextId
    await connection.execute(
      'INSERT INTO operationlog (id, username, ip, content, time, type) VALUES (?, ?, ?, ?, NOW(), ?)',
      [id, entry.username, entry.ip, entry.content, entry.type],
    )
  } finally {
    try {
      if (lockAcquired) {
        await connection.execute('SELECT RELEASE_LOCK(?)', [operationLogLockName])
      }
    } finally {
      connection.release()
    }
  }
}
