# Soul Land GM Admin

The active application is being migrated to Nuxt 3, with Nitro server routes, at
the repository root. Previous Express, Vue 2, and Vue 3/Vite projects are kept
under `legacy/` as references.

## Run

Requires Node.js 20.19 or newer and reachable MySQL/MariaDB databases. `DB_*`
connects to `dlbackstage` for channels, operation logs, and broadcasts.
`GAMEDB_*` connects to `gamedb` for game data and admin accounts; if omitted,
its host, port, user, and password fall back to `DB_*`.

```powershell
Copy-Item .env.example .env
# Set DB_* and GAMEDB_* in .env for the two databases
npm install
npm run dev
```

The development and preview servers use `http://localhost:8081` by default
and listen on IPv4 so VS Code/browser port forwarding can connect. For the
production Nitro server, set `HOST=0.0.0.0` and `PORT=8081` (or
`NITRO_HOST=0.0.0.0` and `NITRO_PORT=8081`).

The checked-in `database/gamedb_export.sql` is a database dump containing
`DROP TABLE` and `CREATE TABLE` statements. Do not import it into a live
database without reviewing it and taking a backup first.

Apply `database/migrations/20261031_admin_users_gamedb.sql` once to create the
`gamedb.admin_user` table and copy existing admin accounts from
`dlbackstage.user`. Login, sessions, and admin-account management then use
`gamedb.admin_user`. Channels, operation logs, and broadcasts still use
`dlbackstage`, so the rest of the web-admin schema has not been consolidated.

The character information page reads character, resource, recharge, and server
data from `gamedb`. Character searches are scoped to the selected server. The
online state is not stored in the exported character tables, so the page
displays it as unknown. Mute/unmute and freeze/unfreeze actions continue to use
the Game Server protocol.

Nuxt serves all 28 former admin screens and the Nitro API on the same origin.
Nitro handles login/session validation, channel and user administration,
operation logs, broadcast scheduling, announcement uploads/downloads, and
game-server protocol requests. Configure `GAMESERVER_HOST`/`GAMESERVER_PORT`
and `ANNOUNCEMENT_SERVICE_URL`/`ANNOUNCEMENT_SERVICE_TOKEN` for those
integrations. The old Express service is not used as a proxy.

Routes that depend on the database, game server, or announcement service need
those services configured for end-to-end verification. Legacy files remain
under `legacy/` as reference, not as the running application.

## Migration references

- `legacy/express/` — former Express API, DB models, and game-server integration
- `legacy/vue2/` — former Vue 2 admin interface
- `legacy/vue3/` — former Vue 3/Vite prototype

Database configuration is supplied through environment variables; never commit
the local `.env` file.
