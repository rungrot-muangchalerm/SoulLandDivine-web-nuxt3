# Live client connection configuration

New clients fetch `https://soul-land-advent-of-the-gods.aoatheallrandom.com/api/client-config`
before initializing the SDK, Lua and server connections. Both Windows and Android use this
flow. It updates connection settings, not game code or assets.

Edit `connection-config.json` in the configured `CLIENT_UPDATE_DIR` (the default is
`.data/client-updates/connection-config.json`). The endpoint reads this file on every request;
no client build or Nuxt restart is needed. Save the complete JSON, preferably by writing a
temporary file and renaming it over the old one. Defaults come from
`server/config/client-connection.json` when no override exists.

```json
{
  "serverId": 1001,
  "loginHost": "203.154.16.117",
  "loginPort": 8880,
  "announcementUrl": "http://203.154.16.117/Announcement.xml",
  "payNotifyUrl": "https://203.154.16.117:8889",
  "updateManifestUrl": "https://soul-land-advent-of-the-gods.aoatheallrandom.com/api/client-update/manifest"
}
```

Players receive new values when reopening the game. Active sessions are not reconnected.
The HTTPS request times out after 8 seconds. Invalid responses, unavailable servers and
redirects retain the last valid cached configuration; first launch uses bundled defaults.
The cache is separate for each bootstrap URL. Remote responses cannot replace that URL.
Never put database passwords, API tokens or other secrets in this public file.

Existing APKs/installers need one application update to gain this feature. Keep the bootstrap
hostname available after server migrations. Changing the game's login endpoint does not
change Gate/Zone addresses advertised by the game server; those must also be reachable.
