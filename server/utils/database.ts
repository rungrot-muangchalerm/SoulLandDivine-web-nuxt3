import mysql, { type Pool } from 'mysql2/promise'

let gamePool: Pool | undefined

export function getDatabase() {
  return getGameDatabase()
}

export function getGameDatabase() {
  const config = useRuntimeConfig()
  gamePool ??= mysql.createPool({
    host: config.gameDbHost,
    port: config.gameDbPort,
    database: config.gameDbName,
    user: config.gameDbUser,
    password: config.gameDbPassword,
    waitForConnections: true,
    connectionLimit: 5,
    timezone: '+08:00',
  })
  return gamePool
}
