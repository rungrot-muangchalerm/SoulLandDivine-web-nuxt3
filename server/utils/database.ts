import mysql, { type Pool } from 'mysql2/promise'

let pool: Pool | undefined
let gamePool: Pool | undefined

export function getDatabase() {
  const config = useRuntimeConfig()
  pool ??= mysql.createPool({
    host: config.dbHost,
    port: config.dbPort,
    database: config.dbName,
    user: config.dbUser,
    password: config.dbPassword,
    waitForConnections: true,
    connectionLimit: 5,
    timezone: '+08:00',
  })
  return pool
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
