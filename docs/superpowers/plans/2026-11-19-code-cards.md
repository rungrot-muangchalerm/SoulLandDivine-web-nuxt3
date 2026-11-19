# Character code cards — approved design and implementation plan

Goal: Add /code-cards to the existing local Nuxt admin, with configurable templates and codes redeemable once through the game's existing code entry.
Architecture: Templates and immutable generated-card snapshots in gamedb_cmdl. Cryptographically random SLC-prefixed codes, SHA-256 hashes for lookup. Existing game protocol routes reserved SLC codes to a DB-backed redemption transaction; reward delivery must be durable and once-only. Existing legacy codes remain unchanged.
Tech stack: Nuxt 3 / Vue / mysql2 / C# game server / MySQL.
Spec: User-approved chat layout, 2026-11-19.

## Constraints
- Work in the selected D: repository, preserving existing user changes. User selected this live checkout; no worktree relocation.
- Card: real character art left; 5 equipment slots (secret weapon + 4 equipment) top right; exactly one talent (strength/body/agility/skill), value; configurable bone affix lines; code center; 10 real creature-centered ring icons bottom. No card identity heading and no hundred-thousand-year affix section.
- First editable draft: Dai Mubai x1; requested ten creatures; user configures item variants, ages, weapons, and bone affixes.
- Card build notes are display metadata; reward item IDs/counts/ages are explicitly configured and validated. Do not change existing player hero stats on redemption.
- Each issued batch retains its template snapshot; edits cannot change sold codes.
- Admin-only endpoints, same-origin mutation checks, bound amounts, no full code logging.
- Build web and restart/save PM2; server changes use start-servers.ps1 normal Stop/Build/Run. User controls Unity Play.

## Review focus
Concurrent redemption, retry after crash, template edits after generation, invalid/missing assets and reward IDs, unauthorized code access.

## Tasks
- [ ] 1. Tests + schema, immutable snapshots and random code validation. Files: utils/code-card.ts, server/utils/code-cards.ts, database/code-cards.sql, tests/code-cards.test.js.
- [ ] 2. Real game asset catalog + admin APIs for templates/batches/cards. Files: scripts/build-code-card-catalog.*, data/code-card-catalog.json, public/code-cards/, server/api/code-cards/*.
- [ ] 3. Vue editor and printable/exportable canvas preview, history/code selection. Files: pages/code-cards.vue, components/CodeCardPreview.vue, components/AdminSidebarMenu.vue.
- [ ] 4. Server reserved-code route + durable atomic redemption and test evidence. Files selected within Common DB queries and Relation/Zone gift handlers; game schema shared with task 1.
- [ ] 5. Targeted tests, production build, deploy, auth/runtime/browser verification and fresh code review.

Validation: node --test tests/code-cards.test.js; DB-backed concurrent redemption tests with isolated test rows and cleanup; npm run build; server build/start; PM2 restart/save; browser inspect real page and rendered asset slots, responsive layout, safe test generation.
