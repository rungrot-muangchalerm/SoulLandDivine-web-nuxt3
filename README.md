# Soul Land GM Admin

The active application is being migrated to Nuxt 3, with Nitro server routes, at
the repository root. Previous Express, Vue 2, and Vue 3/Vite projects are kept
under `legacy/` as references.

## Run

Requires Node.js 20.19 or newer and reachable MySQL/MariaDB databases. `DB_*`
connects to `dlbackstage` for operation logs and broadcasts. `ACCOUNTDB_*`
connects to `account_cmdl` for accounts, server lists, and welfare assignments.
`GAMEDB_*` connects to `gamedb_cmdl` for characters, game data, admin accounts,
and channels. The account and game database host, port, user, and password
settings fall back to `DB_*` when omitted.

```powershell
Copy-Item .env.example .env
# Set DB_*, ACCOUNTDB_*, and GAMEDB_* in .env for the three databases
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
`gamedb_cmdl.admin_user` table and copy existing admin accounts from
`dlbackstage.user`. Login, sessions, and admin-account management then use
`gamedb_cmdl.admin_user`. Apply
`database/migrations/20261103_channel_list_gamedb.sql` once to create
`gamedb_cmdl.channel_list` with the existing `dlbackstage.channel_list`
structure and copy its channel records. The migration leaves the old table in
place for rollback; the web app reads and updates channels in `gamedb_cmdl`
afterward. Operation logs and broadcasts continue to use `dlbackstage`.

To initialize a fresh, empty `admin_user` table, set
`ADMIN_DEFAULT_USERNAME` and `ADMIN_DEFAULT_PASSWORD` in the local environment.
On startup, the web app creates that account with admin access to all channels
only when the table has no accounts; existing accounts are never overwritten.
Leave both settings empty to disable automatic initialization. Change the
default password before exposing the admin site to an untrusted network.

The player information page lists accounts with characters in the selected
server, 50 accounts per page. Expanding an account shows its characters,
resources, and recharge totals. Player totals are aggregated from that
account's characters on the selected server. Online state is not stored in the
exported character tables, so it displays as unknown. Mute/unmute and
freeze/unfreeze actions remain targeted to an individual character and continue
to use the Game Server protocol.

The item deduction page loads the selected server's inventory automatically,
50 rows per page, including item stacks, equipment, soul rings/bones, and
supported collectible items. Currency balances and inventory categories without
a matching Game Server deduction type are shown read-only.

The email page separates the recipient type (individual players or a server)
from the message content (an Email template or custom title, sender, body, and
item rewards). Custom rewards can be selected from the catalog or entered by
item ID, type, and quantity, up to 255 items per request. Custom rewards are
sent in separate emails when their combined reward data would exceed 255
characters per email. Individual recipients use `serverId:UID`,
separated by `|` for multiple players (up to 50 per request). Custom server
mail can target the selected server or all RelationServers connected to the
selected channel's GlobalServer. Custom mail uses the existing Game Server
protocol and requires rebuilding and restarting GlobalServer and RelationServer
once after updating their code; the other game-server processes are unchanged.
Custom mail is placed in a sequential in-process queue, with progress retained
in NodeCache for seven days. The API returns a job ID immediately; the email
page polls that ID for progress and completion. Because this queue is in memory,
pending jobs and their status are lost if the Nuxt process restarts, and this
setup requires a single Nuxt process for queue and status requests.

Nuxt serves all 28 former admin screens and the Nitro API on the same origin.
Nitro handles login/session validation, channel and user administration,
operation logs, broadcast scheduling, announcement uploads/downloads, and
game-server protocol requests. Configure `GAMESERVER_HOST`/`GAMESERVER_PORT`
for game-server protocol requests. Announcement files are proxied to the
Game AdminAPI using `ADMIN_API_URL` and `ADMIN_API_TOKEN`; the token is kept
server-side and sent in the `token` HTTP header. Never put it in a Vue
component or commit it to source control. The old Express service is not used
as a proxy.

The `/activities` admin page manages verified schedule fields from the
allowlisted activity XML configs documented in `docs/API_DOCUMENTATION.md`.
After changing `Game_Server/AdminAPI`, rebuild and restart AdminAPI before the
new activity endpoints are available; the game server may also need to reload
its XML configuration.

The admin-only **อัปเดต Client** page publishes Windows and Android manifests.
Store the installer/APK in the persistent `CLIENT_UPDATE_DIR` and see
`docs/client-update.md` for local development and production release steps.

Routes that depend on the database, game server, or announcement service need
those services configured for end-to-end verification. Legacy files remain
under `legacy/` as reference, not as the running application.

## Migration references

- `legacy/express/` — former Express API, DB models, and game-server integration
- `legacy/vue2/` — former Vue 2 admin interface
- `legacy/vue3/` — former Vue 3/Vite prototype

Database configuration is supplied through environment variables; never commit
the local `.env` file.
