# Live updates for rate-up pools

The GM page changes the running server's draw configuration, not client XML.

## Applying this code change

Deploy the updated DLGM, AdminAPI, GlobalServerLib, ManagerServerLib,
ServerShared and ZoneServerLib once, together with the server-authoritative
client changes. This change has not been built or deployed by Codex, as requested.
The new `updategacha` command requires the updated Global/Manager/Zone code.
After that installation, pool and weight edits require no game-server restart.

Do not overwrite the running configuration with the old RuntimeData templates:
GM writes to the root configured by AdminAPI's RuntimeSettings:RootPath, normally
`Game_Server/artifacts/Debug/Data/XML/Draw`. The checked-in
`Game_Server/RuntimeData/Data/XML/Draw` files are deployment templates.

## Update flow

1. A GM switch writes an explicit Bangkok start/end interval. All legacy
   OpenServer/Week constraints are cleared for that pool. Closing a previously
   unused pool writes a complete interval in the past, not an empty start date.
2. Schedule and character-weight saves both ask AdminAPI to reload live draw data.
3. AdminAPI writes a complete XML file with atomic replacement and requests
   `updategacha 0` through the authenticated GlobalServer GM endpoint.
4. Global forwards the existing XML message with Type=2 to Managers; Managers
   forward it to Zones without reinitializing unrelated systems.
5. Zone reloads only the five draw config files on its game loop, preserves player
   state/pity counters, and pushes new pool/payment snapshots to connected clients.
   Invalid draw-library reloads restore the previous draw caches and log an error.
6. Zone checks opening/closing/discount boundaries every second and pushes changes
   even if the player stays on the main screen. The summon panel also requests
   snapshots while open. GM refreshes its schedule every 10 seconds without
   replacing unsaved drafts.

The GM success message confirms the save and dispatch of the reload request;
it is not an acknowledgement from each Zone. If the game does not change,
inspect Zone's `DRAW XML update END` or `DRAW XML update failed` log and confirm
all running binaries support Type=2. Do not fall back to a full `updatexml` for
routine gacha edits.

Character rates are weights within the selected rarity, not overall percentages.
Pity rules and rarity-tier probabilities are separate server settings. The editor
rejects removing the last positive weight in the selected rarity.

## Verification without a build

Run `npm run test:gacha` from DLGM. These tests use mocked network/Nitro handlers
and in-memory TypeScript execution; they do not contact the live game, change
pool schedules, or send mail. Do not use the general test command as a substitute:
the repository's separate sendmail tests can perform live operations.

Live verification after deploying the binaries: keep a player logged in, open a
pool from GM, change a character weight, close the pool, then test a short end
time. The pool should disappear at the server deadline without disconnecting
players or restarting a service. Confirm stale ticket/free quotes spend nothing.

## Independent custom UP pool (ID / Type 10000)

Pool 10000 now uses Type 10000, not Tang San's Type 3. Its quality/pricing row,
Ratio10000/Quality10000 hero columns and saved draw/pity counters are separate.
Existing Type 3 records are not copied, reset or modified; the custom counter
starts at zero. The default custom pool uses the former prices (300/2000 diamonds),
seven draws, ticket IDs 4007/4008, and an SSR pity threshold of 99. It has no fixed
Tang San pity hero, introductory forced heroes, multi-draw rarity cap or hidden
minimum-rarity rule. Its normal rarity probabilities follow its own weights.

The custom card has a settings panel for prices, ticket IDs, SSR pity and rarity
weights; the existing hero-weight editor now edits Ratio10000 independently.
Ticket IDs can be disabled with 0 or selected from existing draw-ticket IDs.
Using the same ID as another pool intentionally shares that inventory item;
separate configuration does not create a new item/asset.

The new `/api/gacha/quality` API requires the updated AdminAPI binary. No protocol
change is required for Type 10000. Do not assume the currently running server has
loaded the new XML simply because the files have changed. Deploy the updated
AdminAPI and the scoped live reload implementation documented above, then save
through GM. Codex did not build, restart or trigger a full reload.

The data migration was applied to both RuntimeData templates and the current
artifacts/Debug runtime XML, preserving the runtime pool's existing opening and
closing times. The previous XML files were backed up in temporary directories.
For another runtime root, use:
`python scripts/initialize_custom_gacha.py --draw-dir <runtime-root>/Data/XML/Draw`
from Game_Server. The migration is idempotent and preserves existing custom edits.
Server-side no-build migration tests: `python scripts/test_custom_gacha.py`.
