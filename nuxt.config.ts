export default defineNuxtConfig({
  compatibilityDate: '2025-03-01',
  devServer: { host: '0.0.0.0', port: 8081 },
  devtools: { enabled: false },
  css: ['~/assets/css/admin-theme.css'],
  app: {
    head: {
      link: [
        {
          rel: 'stylesheet',
          href: 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css',
        },
      ],
      script: [
        {
          src: 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js',
          defer: true,
        },
      ],
    },
  },
  runtimeConfig: {
    dbHost: process.env.DB_HOST || '127.0.0.1',
    dbPort: Number(process.env.DB_PORT || 3306),
    dbName: process.env.DB_NAME || 'dlbackstage',
    dbUser: process.env.DB_USER || 'root',
    dbPassword: process.env.DB_PASSWORD || '',
    accountDbHost: process.env.ACCOUNTDB_HOST || process.env.DB_HOST || '127.0.0.1',
    accountDbPort: Number(process.env.ACCOUNTDB_PORT || process.env.DB_PORT || 3306),
    accountDbName: process.env.ACCOUNTDB_NAME || 'account_cmdl',
    accountDbUser: process.env.ACCOUNTDB_USER || process.env.DB_USER || 'root',
    accountDbPassword: process.env.ACCOUNTDB_PASSWORD || process.env.DB_PASSWORD || '',
    gameDbHost: process.env.GAMEDB_HOST || process.env.DB_HOST || '127.0.0.1',
    gameDbPort: Number(process.env.GAMEDB_PORT || process.env.DB_PORT || 3306),
    gameDbName: process.env.GAMEDB_NAME || 'gamedb_cmdl',
    gameDbUser: process.env.GAMEDB_USER || process.env.DB_USER || 'root',
    gameDbPassword: process.env.GAMEDB_PASSWORD || process.env.DB_PASSWORD || '',
    gameServerHost: process.env.GAMESERVER_HOST || '172.16.10.10',
    gameServerPort: Number(process.env.GAMESERVER_PORT || 29024),
    serverListDir: process.env.SERVER_LIST_DIR || 'data/server_list',
    gameAdminApiUrl: process.env.ADMIN_API_URL || 'http://127.0.0.1:8082',
    gameAdminApiToken: process.env.ADMIN_API_TOKEN || '',
    adminJwtSecret: process.env.ADMIN_JWT_SECRET || '',
    adminDefaultUsername: process.env.ADMIN_DEFAULT_USERNAME || '',
    adminDefaultPassword: process.env.ADMIN_DEFAULT_PASSWORD || '',
    clientUpdateDir: process.env.CLIENT_UPDATE_DIR || '.data/client-updates',
  },
  typescript: {
    strict: true,
  },
})
