# Client updates

The Nuxt app publishes update manifests and serves the Windows installer and Android APK.
Android updates are downloaded as APKs and must be confirmed in Android's installer. Windows
updates are downloaded as an installer; the game exits after the player accepts the update.

## Local development

The default storage directory is `.data/client-updates` in the Nuxt working directory. It is
git-ignored. Start Nuxt on port 8081 and build client config with one of these manifest URLs:

- Windows on the same PC: `http://127.0.0.1:8081/api/client-update/manifest`
- Android emulator: `http://10.0.2.2:8081/api/client-update/manifest`
- Android device on the same LAN: `http://<development-PC-LAN-IP>:8081/api/client-update/manifest`

The Android emulator/device must be able to reach the development PC. Plain HTTP is only for
local testing; use HTTPS through a public hostname/tunnel for releases.

Put release files under the Nuxt data directory with these exact names:

```text
.data/client-updates/
  windows/SoulLandDivine-Setup.exe
  android/SoulLandDivine.apk
```

Sign in to Nuxt as an administrator, open **อัปเดต Client**, select a platform, and publish
its version and minimum supported version. The endpoint calculates SHA-256 and size when
publishing. Android also records `versionCode`; it must increase with every new APK.
Re-publish after replacing an artifact.

## Production

Set `CLIENT_UPDATE_DIR` to a persistent directory on the Nuxt host and preserve its files
between deployments. Transfer the artifacts to that directory, then publish their metadata
from the admin page. Put Nuxt behind HTTPS before releasing clients.

Set the client `updateManifestUrl` in the build's `StreamingAssets/client-config.json` to
`https://<public-host>/api/client-update/manifest`. Keep the same host for subsequent builds
so previously installed clients continue checking the same endpoint.

Every APK update must use the same Android application ID and signing key as the installed
APK, and its `versionCode` must increase. Keep the signing key private and back it up.
Do not publish an APK signed with a development/debug key to existing players.

## Update behavior

`version` controls whether a client is offered an update. A client older than
`minimumVersion` receives a mandatory prompt; newer clients below `version` receive an
optional prompt. The download API uses a fixed filename per platform, streams the file, and
requires no admin login. Manifest publishing and status are restricted to administrators.
