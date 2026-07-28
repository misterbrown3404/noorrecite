# QariVerse — Engineering Blueprint
### A Serverless-First, Offline-First Quran Audio & Reading Platform
**Version 1.0 — Pre-Implementation Architecture Document**

---

## 0. How to Read This Document

This blueprint is the single source of truth before a single line of application code is written. It is organized into 13 sections matching the requested deliverables. Each section is written to be handed directly to an engineering team, a security reviewer, or an investor without additional translation.

Two architectural stances shape every decision in this document, and it's worth stating them up front because they create real tension:

- **Offline-first** means the local Isar database is the source of truth for the UI at all times; Supabase is a sync target, not a live dependency.
- **Serverless-first** means we lean on Postgres (RLS, triggers, views) and Edge Functions instead of a custom backend — but "serverless" is not "logic-free." Some logic (e.g., download-token issuance, abuse throttling) *must* live server-side, and Edge Functions are where it goes.

Where these two principles conflict — e.g., a bookmark made offline vs. one made on another device — Section 8 (Sync Engine) resolves it explicitly.

---

## 1. Product Requirements Document

### 1.1 Vision
QariVerse is the Quran companion that respects both the sanctity of the text and the reality of modern phone usage: unreliable networks, limited storage, and users who listen more than they read. The product should feel like a mus'haf that happens to be able to speak, not a media app that happens to contain Quran text.

### 1.2 Mission
Deliver accurate, offline-capable Quran reading and recitation to any Muslim, on any device, in any connectivity condition, without compromising the integrity of the text or the privacy of the user's worship habits.

### 1.3 User Personas

| Persona | Profile | Core Need | Key Risk If Ignored |
|---|---|---|---|
| **Al-Musafir (The Traveler)** | Commuter/frequent flyer, patchy connectivity | Reliable offline playback, resume-from-last-position | App unusable exactly when needed most |
| **Al-Mu'allim (The Learner)** | Beginner/intermediate reciter proficiency | Translations, tafsir, word-by-word, slow playback speed | Feature overload, poor onboarding |
| **Al-Muta'abbid (The Devotee)** | Daily listener, favorite reciters, long sessions | High audio quality, background playback, minimal battery drain | Playback interruptions, poor battery life |
| **Al-Waled/Waldah (The Parent)** | Wants children to memorize / listen | Kid-safe UI, simple controls, Hifz-friendly repeat modes | Complexity, ads, inappropriate content adjacency |
| **Al-Hafiz (The Memorizer)** | Serious memorization student | Ayah-by-ayah repeat, precise bookmarking, verse ranges | Imprecise audio timestamp sync per verse |

### 1.4 MVP Scope (Phase 1–3 in the roadmap)

**In scope:**
- Full Quran text (Uthmani script) with at least one translation
- Streaming + download playback for 3–5 reciters
- Background playback, lock-screen controls
- Bookmarks, last-read/last-listened position, basic search
- Supabase Auth (email + Google + Apple)
- Offline-first local storage with background sync

**Explicitly out of MVP:**
- Tafsir (Phase 5+)
- Cross-device realtime sync (Phase 2 delivers eventual sync; realtime presence is a premium/Phase 7 feature)
- Daily ayah push notifications (Phase 6)
- Word-by-word grammar/morphology (post-MVP)
- Social features (sharing, following reciters/other users) — deliberately excluded from the entire roadmap unless demand is proven; Quran apps have a poor track record turning worship into social content.

### 1.5 Future Roadmap (Summary — detailed in Section 13)
Search & tafsir → analytics-informed personalization → premium tier → global scale hardening.

### 1.6 Premium Features (Monetization Surface)
- Unlimited concurrent offline downloads / larger download cache
- Additional reciters (rare/regional Qira'at)
- Advanced tafsir library (multiple scholars)
- Ad-free (if a free ad tier is ever introduced — see caution below)
- Cross-device realtime sync with conflict history
- Custom recitation playlists / Hifz repeat-scheduling (spaced repetition)

### 1.7 Monetization Strategy
A **subscription model** (monthly/annual via App Store/Play Store IAP, reconciled through Supabase via RevenueCat or native receipt validation in an Edge Function) is strongly preferred over ads for a Quran app:
- Ads adjacent to Quran content are reputationally risky and often explicitly against app-store religious-content guidelines review expectations.
- A one-time "supporter" purchase plus an optional subscription for power features (extra reciters, unlimited offline storage tiers) balances accessibility (core Quran experience always free) with revenue.
- Recommendation: **never paywall the core Quran text, at least one translation, or at least one reciter.** Paywall convenience and depth, not access to scripture. This is as much a trust/retention strategy as an ethical one.

---

## 2. System Architecture

### 2.1 High-Level Architecture

```
                        ┌───────────────────────────────────────────┐
                        │              Flutter Mobile App            │
                        │  (iOS / Android — single codebase)          │
                        │                                             │
                        │  UI Layer (GetX Views/Controllers)          │
                        │  Domain Layer (Use Cases, Entities)         │
                        │  Data Layer (Repositories)                  │
                        │        │                        │           │
                        │   ┌────▼────┐             ┌─────▼─────┐    │
                        │   │  Isar   │             │  Remote    │    │
                        │   │ (local  │◄───sync────►│  Data      │    │
                        │   │  source │             │  Sources   │    │
                        │   │  of     │             │            │    │
                        │   │  truth) │             └─────┬──────┘    │
                        │   └─────────┘                    │          │
                        └───────────────────────────────────┼──────────┘
                                                              │
                          HTTPS (TLS1.3) / Supabase Realtime  │
                                                              │
                 ┌────────────────────────────────────────────▼───────────────────┐
                 │                          Supabase                                │
                 │  ┌───────────┐ ┌───────────────┐ ┌──────────────────────────┐   │
                 │  │   Auth    │ │   Postgres     │ │   Edge Functions         │   │
                 │  │ (GoTrue)  │ │  + RLS + RPC   │ │  (signed URL issuance,   │   │
                 │  │           │ │  + Realtime    │ │   abuse throttling,      │   │
                 │  │           │ │    (CDC)       │ │   receipt validation)    │   │
                 │  └───────────┘ └───────────────┘ └──────────────────────────┘   │
                 │  ┌────────────────────────────────────────────────────────┐    │
                 │  │  Supabase Storage (small/warm assets: translations,      │    │
                 │  │  tafsir text, thumbnails)                                │    │
                 │  └────────────────────────────────────────────────────────┘    │
                 └──────────────────────────┬─────────────────────────────────────┘
                                             │  Signed URL (short TTL)
                                             ▼
                 ┌────────────────────────────────────────────────────────────────┐
                 │        Cloudflare R2 (bulk audio, cold + hot storage)          │
                 │        + Cloudflare CDN (cache at edge, near-zero egress $)    │
                 └────────────────────────────────────────────────────────────────┘

                 ┌────────────────────────────────────────────────────────────────┐
                 │  Firebase Cloud Messaging — push notifications only            │
                 │  (daily ayah, download-complete, re-engagement)                │
                 └────────────────────────────────────────────────────────────────┘
```

**Why audio lives in R2, not Supabase Storage:** Supabase Storage bills egress at a rate that becomes the single largest cost driver once you have audio-heavy traffic at scale (Section 12 does the math). R2 has zero egress fees and sits behind Cloudflare's CDN natively. Supabase Storage is reserved for small assets (translation JSON, tafsir text, reciter avatars) where its tighter RLS integration is worth the marginally higher cost.

### 2.2 Component Responsibilities

| Layer | Responsibility | Owns Source of Truth For |
|---|---|---|
| Isar (local) | UI reads, offline writes, queue of pending mutations | User's *current* app state |
| Postgres | Canonical user data, RLS enforcement, cross-device state | User's *durable* state |
| Edge Functions | Anything requiring a secret (signing keys, IAP receipt validation, rate limiting) | Nothing persistent — pure compute |
| R2 + CDN | Audio bytes | Audio files themselves |
| Supabase Storage | Static Quran/translation/tafsir JSON + small images | Content, not user data |
| FCM | Push delivery only | Nothing — stateless transport |

### 2.3 Data Flow: "User bookmarks an ayah while offline"
1. GetX controller calls `BookmarkRepository.add()`.
2. Repository writes to Isar immediately (optimistic, instant UI update) and enqueues a `PendingMutation` record (op=INSERT, entity=bookmark, payload, client_timestamp, uuid).
3. UI never waits on network.
4. `SyncEngine` (a background isolate/worker, see Section 8) watches connectivity; when online, drains the mutation queue against Supabase via RPC calls that are idempotent on the client-generated UUID.
5. Supabase Realtime pushes the change back down (in case of multi-device), which the SyncEngine reconciles against Isar using last-write-wins + vector-clock tiebreak (Section 8.3).

### 2.4 Architecture Diagrams to Formalize in Tooling
This document specifies the diagrams conceptually (ASCII above). Before implementation, redraw the above in a proper diagramming tool (C4 model recommended: Context → Container → Component) and store as versioned `.drawio`/Mermaid files in `/docs/architecture/`.

---

## 3. Flutter Architecture

### 3.1 Architectural Style
**Clean Architecture + Feature-First modularization.** Each feature is a vertical slice containing its own presentation/domain/data layers. Shared code lives in `core/`. This is chosen over a single global layered structure because it lets teams (or future contributors) own a feature end-to-end and lets us delete/disable a feature without hunting across the codebase.

### 3.2 Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                     # MaterialApp/GetMaterialApp root
│   ├── routes/                      # GetX route names + pages
│   └── bindings/                    # Root/global GetX bindings
├── core/
│   ├── constants/                   # Colors, strings, durations, asset paths
│   ├── config/                      # Env config (flavors: dev/staging/prod)
│   ├── error/                       # Failure/Exception types, Either<Failure,T> helpers
│   ├── network/
│   │   ├── network_info.dart        # Connectivity abstraction
│   │   ├── supabase_client.dart     # Singleton wrapper around Supabase SDK
│   │   └── interceptors/            # Logging, retry, auth-refresh
│   ├── storage/
│   │   ├── isar_service.dart        # Isar instance lifecycle
│   │   └── secure_storage_service.dart # flutter_secure_storage wrapper
│   ├── sync/
│   │   ├── sync_engine.dart
│   │   ├── mutation_queue.dart
│   │   └── conflict_resolver.dart
│   ├── di/
│   │   └── injector.dart            # get_it or GetX-based service locator
│   ├── theme/
│   └── widgets/                     # Shared dumb widgets (buttons, loaders)
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/         # remote (supabase) + local (isar/secure storage)
│   │   │   ├── models/              # DTOs
│   │   │   └── repositories/        # Impl of domain repository interfaces
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/        # Abstract interfaces
│   │   │   └── usecases/            # SignIn, SignOut, RefreshSession...
│   │   └── presentation/
│   │       ├── controllers/         # GetX controllers
│   │       ├── bindings/
│   │       └── pages/
│   ├── quran_reader/
│   ├── audio_player/
│   ├── downloads/
│   ├── bookmarks/
│   ├── search/
│   ├── reciters/
│   ├── tafsir/
│   ├── daily_ayah/
│   └── settings/
├── l10n/
└── generated/
```

### 3.3 GetX Architecture Conventions
- **Controllers** hold only presentation state and call use cases. They never touch Supabase or Isar directly.
- **Bindings** are `lazyPut` by default; `permanent: true` reserved for app-lifetime singletons (auth controller, connectivity controller, audio-service handle).
- **GetX reactive state** (`.obs`) used for UI-bound state; plain fields for one-shot data. Avoid overusing `Obx` at large widget-tree granularity — wrap the smallest widget possible to limit rebuild scope.
- **Navigation** exclusively through named routes (`Get.toNamed`) with typed arguments via a small `RouteArgs` class per page — avoids stringly-typed `Get.arguments` bugs.
- **GetX is not used as a dependency-inversion replacement for the domain layer.** Use cases remain plain Dart classes unaware of GetX, so they're unit-testable without the Flutter/GetX test harness.

### 3.4 Repository Pattern
Every feature defines an abstract repository in `domain/repositories/`. Implementations in `data/repositories/` compose a **local data source** and a **remote data source**, and the repository itself decides offline-first policy, e.g.:

```
class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkLocalDataSource local;
  final BookmarkRemoteDataSource remote;
  final MutationQueue queue;

  // Reads: always local (Isar), synchronous, no loading spinner.
  // Writes: local first, then enqueue for sync. Never block UI on remote.
}
```

This makes "offline-first" a structural guarantee rather than a discipline every developer must remember.

### 3.5 Service Layer
Distinct from repositories, **services** are stateless/singleton wrappers around a device or SDK capability that multiple repositories share: `AudioService` (just_audio + audio_service orchestration), `ConnectivityService`, `NotificationService` (FCM), `AnalyticsService`. Repositories depend on services; services never depend on repositories (prevents cycles).

### 3.6 Local Storage Layer
Isar is the only persistence a repository reads from for UI purposes. See Section 8.1 for schema.

### 3.7 Network Layer
A single `SupabaseClientWrapper` centralizes: base client init, auth-token refresh hook, structured error mapping (Postgrest error codes → domain `Failure` types), and request/response logging gated by build flavor.

### 3.8 Error Handling
- Domain layer returns `Either<Failure, T>` (via `fpdart` or `dartz`) from use cases — no exceptions crossing into presentation.
- `Failure` is a sealed class: `NetworkFailure`, `AuthFailure`, `CacheFailure`, `SyncConflictFailure`, `StorageQuotaFailure`, `UnknownFailure`.
- Controllers translate `Failure` → localized user-facing message via a single `FailureMessageMapper`, so copy changes happen in one file.
- All uncaught exceptions funnel through `FlutterError.onError` / `PlatformDispatcher.instance.onError` into the analytics/crash service (Sentry or Firebase Crashlytics — decide before Phase 1 sign-off; Crashlytics is the lower-friction pick given FCM is already in the stack).

### 3.9 Dependency Injection
`get_it` (not GetX's own locator) is recommended for the DI container itself, with GetX bindings calling into `get_it` for shared singletons and using GetX's `lazyPut` only for controller lifecycles tied to page navigation. Rationale: keeps DI testable/swappable independent of the UI framework's navigation lifecycle, which matters once you start writing widget/integration tests that need to override services with fakes.

---

## 4. Supabase Architecture

### 4.1 Auth Flows
- **Providers:** Email/password (with mandatory email verification), Google Sign-In, Apple Sign-In (mandatory on iOS per App Store guideline 4.8 if any other social login is offered).
- **Flow:** Native SDKs (`google_sign_in`, `sign_in_with_apple`) obtain an ID token client-side → passed to `supabase.auth.signInWithIdToken()` → Supabase (GoTrue) verifies against the provider and issues its own JWT (access + refresh token pair).
- **Anonymous-first option:** Allow browsing/reading/listening without an account (guest mode backed by a Supabase **anonymous auth** session), and prompt account linking only when the user takes an action that needs durability (bookmark, cross-device sync). This meaningfully lowers onboarding friction for a Quran app where many users just want to open and read immediately.
- **Session storage:** Refresh token stored in `flutter_secure_storage` (Keychain/Keystore-backed), never in Isar or SharedPreferences.
- **Token refresh:** Handled by the Supabase Flutter SDK's built-in auto-refresh; app additionally listens to `onAuthStateChange` to react to forced sign-outs (e.g., admin-revoked session, password change elsewhere).

### 4.2 Database Schema (see full detail in Section 5)
Core tables: `profiles`, `bookmarks`, `favorites`, `downloads`, `listening_history`, `recent_plays`, `reciters`, `translations`, `tafsir`, `daily_ayah`, `user_preferences`.

### 4.3 Storage Buckets
| Bucket | Contents | Access |
|---|---|---|
| `avatars` | User profile images (optional) | RLS: owner read/write |
| `reciter-assets` | Reciter photos/logos | Public read, service-role write |
| `translations` | Translation text JSON bundles | Public read |
| `tafsir` | Tafsir text bundles | Public read (free tafsir) / signed URL (premium tafsir) |

Bulk audio is **not** in Supabase Storage — it's in R2 (Section 2, Section 7).

### 4.4 Row Level Security — Design Principles
- RLS is **on for every table, no exceptions**, including reference tables (reciters, translations) which get a permissive public-read policy rather than RLS disabled — this avoids an entire class of "someone disabled RLS during a migration" incidents.
- All user-owned tables use `auth.uid() = user_id` as the baseline predicate.
- Write policies are narrower than read policies where relevant (e.g., users can read their own `downloads` row but only an Edge Function using the service role can mark it `status = 'completed'` after verifying the R2 object actually exists).

### 4.5 Realtime Sync
Supabase Realtime (Postgres logical replication / CDC) is enabled on `bookmarks`, `favorites`, `listening_history`, and `user_preferences` so a second device gets pushed changes without polling. Realtime is **not** enabled on `downloads` (device-local by nature — see Section 5) or on reference tables (no need, they're rarely-changing and cached locally with a version/ETag check instead).

### 4.6 Edge Functions — What They're For
Edge Functions exist for exactly the things RLS/Postgres can't safely do alone:
1. **`issue-audio-url`** — validates the requesting user's entitlement (free reciter vs. premium) and mints a short-TTL signed R2 URL (Section 6.6). This is the *only* path to audio bytes.
2. **`validate-iap-receipt`** — verifies Apple/Google purchase receipts server-side and flips the user's `subscription_tier` in Postgres. Never trust a client-reported "I paid" flag.
3. **`rate-limit-guard`** — a thin abuse-throttling checkpoint (download count, search query rate) backed by a Postgres table + Redis-like counter (Supabase doesn't ship Redis; use a `rate_limits` Postgres table with a rolling-window count, acceptable at this traffic profile — revisit with Upstash Redis if Phase 8 volume demands it).
4. **`daily-ayah-selector`** — scheduled (pg_cron or external scheduler) function selecting/publishing the daily ayah and enqueuing an FCM broadcast.

Edge Functions are deliberately kept few and single-purpose. Resist the urge to grow a full API here — that reintroduces the "traditional backend" this architecture is explicitly avoiding.

---

## 5. Database Design

Conventions used throughout: every table has `id uuid default gen_random_uuid() primary key`, `created_at timestamptz default now()`, `updated_at timestamptz default now()` (maintained by a shared `set_updated_at()` trigger), and a `user_id uuid references auth.users(id) on delete cascade` where user-owned.

### 5.1 `profiles`
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | = `auth.users.id` (1:1) |
| display_name | text | nullable |
| avatar_url | text | nullable, points to Storage `avatars` bucket |
| subscription_tier | text | `free` \| `premium`, default `free` |
| subscription_expires_at | timestamptz | nullable |
| locale | text | default `en` |
| created_at / updated_at | timestamptz | |

- **RLS:** `select`/`update` where `id = auth.uid()`. No `insert` policy — row created by a trigger on `auth.users` insert (`handle_new_user()`), no `delete` policy (cascade from auth.users deletion only).
- **Index:** PK only; table is small (1 row/user).

### 5.2 `reciters`
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | |
| name | text | |
| name_arabic | text | |
| style | text | e.g. `Murattal`, `Mujawwad` |
| bitrate_options | jsonb | `{ "high": "...", "low": "..." }` — R2 object key templates, not full URLs |
| is_premium | bool | default false |
| sort_order | int | |

- **RLS:** public `select` (no auth required — reference data). No client `insert`/`update`/`delete` (service-role only, managed via a lightweight internal script/CLI, not an admin panel per constraints — see Section 5.11 note).
- **Index:** `sort_order`, `is_premium`.

### 5.3 `translations` (reference: metadata only; text bundles live in Storage/R2 as JSON per-surah for fast partial loads)
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | |
| language_code | text | e.g. `en`, `ur`, `id` |
| author | text | |
| title | text | |
| storage_path | text | points to Supabase Storage `translations` bucket |
| is_premium | bool | default false |

- **RLS:** public `select`.

### 5.4 `tafsir` (metadata; content in Storage/R2)
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | |
| language_code | text | |
| author | text | |
| title | text | |
| storage_path | text | |
| is_premium | bool | |

- **RLS:** public `select`.

### 5.5 `bookmarks`
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | client-generated (so offline creation is idempotent on sync) |
| user_id | uuid, FK → auth.users | |
| surah_number | smallint | 1–114 |
| ayah_number | smallint | |
| note | text | nullable |
| client_updated_at | timestamptz | used for conflict resolution (Section 8.3), distinct from server `updated_at` |
| created_at / updated_at | timestamptz | |

- **RLS:** `select`/`insert`/`update`/`delete` where `user_id = auth.uid()`.
- **Indexes:** `(user_id, surah_number, ayah_number)` composite unique — one bookmark per ayah per user (edit-in-place semantics rather than duplicate bookmarks); `(user_id, updated_at)` for incremental sync pulls.
- **Realtime:** enabled.

### 5.6 `favorites` (favorite reciters)
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | client-generated |
| user_id | uuid, FK | |
| reciter_id | uuid, FK → reciters | |
| created_at | timestamptz | |

- **RLS:** owner-only CRUD.
- **Index:** unique `(user_id, reciter_id)`.
- **Realtime:** enabled.

### 5.7 `downloads`
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | |
| user_id | uuid, FK | |
| reciter_id | uuid, FK | |
| surah_number | smallint | |
| device_id | text | see note below |
| status | text | `pending` \| `downloading` \| `completed` \| `failed` |
| bytes_total | bigint | nullable |
| r2_object_key | text | |
| created_at / updated_at | timestamptz | |

- **Important design decision:** downloads are **device-local by nature** — a file downloaded on Phone A doesn't exist on Phone B. This table is used only for **entitlement/audit tracking** (e.g., "how many downloads has this free user consumed this month," rate limiting) and *optionally* as a "download list" hint for UX ("you downloaded this on another device — download here too?"). It is **not** synced/replayed as a mutation queue item the way bookmarks are; the actual downloaded bytes never leave the device that fetched them.
- **RLS:** owner `select`; `insert`/`update` restricted to service role (Edge Function) after validating quota, to prevent a client from writing arbitrary `status=completed` rows to fake entitlement.
- **Index:** `(user_id, created_at)` for quota-window queries.

### 5.8 `listening_history`
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | client-generated |
| user_id | uuid, FK | |
| surah_number | smallint | |
| ayah_number | smallint | last position within surah |
| reciter_id | uuid, FK | |
| position_ms | int | playback position for resume |
| session_duration_ms | int | for analytics, not resume |
| client_updated_at | timestamptz | |

- **RLS:** owner-only CRUD.
- **Index:** unique `(user_id, surah_number, reciter_id)` — one "current position" row per surah+reciter combo, upserted rather than appended indefinitely (keeps table small; a *separate*, optional `listening_events` append-only table can be added later purely for analytics if product wants detailed history, decoupled from the resume-position concern — do not conflate the two).
- **Realtime:** enabled (drives cross-device resume).

### 5.9 `recent_plays`
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | |
| user_id | uuid, FK | |
| surah_number | smallint | |
| reciter_id | uuid, FK | |
| played_at | timestamptz | |

- **RLS:** owner-only CRUD.
- **Index:** `(user_id, played_at desc)`.
- Capped client-side and via a nightly cleanup Edge Function/cron to the most recent ~50 entries per user to keep this table small at scale — this is a UX convenience list, not an analytics store.

### 5.10 `daily_ayah`
| Field | Type | Notes |
|---|---|---|
| id | uuid, PK | |
| date | date, unique | |
| surah_number | smallint | |
| ayah_number | smallint | |
| note | text | optional short reflection |

- **RLS:** public `select`. Writes only via `daily-ayah-selector` Edge Function (service role).

### 5.11 `user_preferences`
| Field | Type | Notes |
|---|---|---|
| user_id | uuid, PK, FK | 1:1 with profiles |
| preferred_translation_id | uuid, FK → translations, nullable | |
| preferred_reciter_id | uuid, FK → reciters, nullable | |
| playback_speed | numeric | default 1.0 |
| theme | text | `light` \| `dark` \| `system` |
| font_scale | numeric | Quran text size |
| notification_daily_ayah | bool | default true |

- **RLS:** owner-only CRUD.
- **Realtime:** enabled.

> **Note on "no admin panel":** Reference data (`reciters`, `translations`, `tafsir`, `daily_ayah` seeding) is managed via a version-controlled seed/migration script (SQL files run through Supabase CLI migrations) plus a small internal CLI tool (not a UI) using the service-role key, run by engineers only. This satisfies "no admin panel" while keeping content management auditable and reproducible — resist the temptation to quietly build a Retool/admin UI later without revisiting this constraint deliberately.

---

## 6. Security Architecture

### 6.1 Authentication Security
- Enforce Supabase's built-in password policy minimums (length, breach-list check via HaveIBeenPwned integration if enabled in project settings) and email verification before any write access beyond guest-tier.
- **Rate-limit auth endpoints** at the Supabase project level (built-in) plus an app-level exponential backoff on repeated failed sign-in attempts to slow credential stuffing.
- MFA (TOTP) offered as an optional account hardening step for Phase 7+ — not MVP, but schema (`profiles`) should not preclude it (Supabase Auth supports MFA natively; no schema change needed).

### 6.2 Google Sign-In Flow
1. Flutter `google_sign_in` package triggers native Google auth sheet.
2. App receives Google ID token + access token.
3. App calls `supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: ..., accessToken: ...)`.
4. GoTrue verifies token signature/audience against Google's public keys server-side, issues Supabase session.
5. **Never** perform this verification client-side or trust a "success" flag without the resulting Supabase JWT being present.

### 6.3 Apple Sign-In Flow
1. `sign_in_with_apple` package triggers native Apple ID flow, requests `email` + `fullName` scopes on first use only (Apple only returns these once — persist `display_name`/email into `profiles` on that very first callback).
2. Identity token passed to `supabase.auth.signInWithIdToken(provider: OAuthProvider.apple, ...)`.
3. Handle Apple's **private relay email** case: store whatever email Apple provides (may be a relay address) — do not assume it's a reachable long-term address for anything beyond transactional auth-related mail.

### 6.4 Secure Session Management & Token Handling
- Access token: short-lived (default Supabase 1hr), held in memory + persisted encrypted by the SDK.
- Refresh token: long-lived, **must** be in `flutter_secure_storage` (iOS Keychain / Android Keystore), never Isar (Isar is not encrypted by default — see 6.7), never `SharedPreferences`.
- On logout: call `supabase.auth.signOut()`, clear secure storage, **and** wipe/rekey the local Isar instance for that user (Section 8) so a subsequent different user on a shared device never sees stale cached data.
- On app reinstall/token invalidation: SDK's `onAuthStateChange` with event `tokenRefreshFailed`/`signedOut` triggers a clean re-auth flow rather than a crash loop.

### 6.5 Device Security
- Root/jailbreak detection (e.g., `flutter_jailbreak_detection`) used for **soft warnings**, not hard blocks (a hard block is poor UX for a Quran app and easily bypassed anyway; the real protection is server-side entitlement checks, not client attestation).
- Certificate pinning considered but **not recommended for MVP**: Supabase/Cloudflare endpoints rotate certs via standard CA infra, and pinning adds an ops burden (pin rotation) disproportionate to the threat model of a Quran app (no financial transactions beyond IAP, which is platform-secured already). Revisit if regulatory/enterprise customers require it later.
- Play Integrity API (Android) / App Attest (iOS) recommended **specifically to protect the download-issuance Edge Function** from scripted abuse (Section 6.6) once usage data shows it's needed — not required for MVP launch.

### 6.6 Download Protection (this is the crux of "content protection" for this app)
Audio must not be trivially scrapeable in bulk, while still being genuinely usable offline.

**Design:**
1. Client requests a download via `issue-audio-url` Edge Function, authenticated with the user's Supabase JWT.
2. Edge Function checks: (a) is this reciter/quality free or does the user's `subscription_tier` cover it, (b) has the user exceeded their download rate/quota (via `rate-limit-guard` logic against `downloads` + a rolling counter), (c) is the request device-fingerprint-consistent with recent requests (basic anomaly signal, not a hard gate).
3. If passed, the function mints a **short-TTL (e.g., 5–10 minute) signed R2 URL** scoped to that exact object.
4. Client downloads the file over that URL directly from R2/CDN (Edge Function is never in the byte-serving path — keeps it cheap and fast).
5. Client encrypts the downloaded file at rest using a per-device key (Section 6.7) so that pulling the raw file off a rooted/unencrypted-backup device doesn't yield a directly shareable, DRM-free copy — this raises the bar without pretending true DRM is achievable or appropriate for this content type (Quran recitation audio is widely and legitimately available for free elsewhere; the goal is reasonable protection against bulk scraping/hotlinking of *this app's* infrastructure and bandwidth, not maximal DRM).
6. Streaming (non-download) playback uses the same signed-URL mechanism but with an even shorter TTL and no persistence to disk beyond the just_audio/ExoPlayer/AVPlayer transient cache.

### 6.7 Storage Protection
- Downloaded audio files stored in app-sandboxed storage (`getApplicationDocumentsDirectory()`), **encrypted at rest** using AES via a key held in secure storage (per-install key, not per-file) — a pragmatic middle ground between "no protection" and full DRM.
- Isar database itself: Isar supports AES-256 encryption at the database level — **enable it**, keyed from a value in `flutter_secure_storage`, so that a lost/stolen device (without OS-level full-disk encryption bypass) doesn't expose bookmarks/listening history/preferences in plaintext.
- Backups: explicitly **exclude** the Isar file and downloaded-audio directory from iCloud/Android auto-backup (`NSURLIsExcludedFromBackupKey` / Android `android:allowBackup` + `fullBackupContent` exclusion rules) — prevents an encrypted-with-a-device-bound-key file from ending up in an unusable state after a backup restore to a new device, and reduces the sensitive-data-in-backups surface generally.

### 6.8 RLS Policies — Summary Table
| Table | Select | Insert | Update | Delete |
|---|---|---|---|---|
| profiles | owner | trigger-only | owner | never (cascade) |
| reciters/translations/tafsir | public | service-role only | service-role only | service-role only |
| bookmarks/favorites/user_preferences | owner | owner | owner | owner |
| listening_history/recent_plays | owner | owner | owner | owner |
| downloads | owner | service-role only | service-role only | owner (local cleanup record) |
| daily_ayah | public | service-role only | service-role only | never |

### 6.9 OWASP Mobile Top 10 Mapping
| OWASP Risk | Mitigation |
|---|---|
| M1: Improper Credential Usage | Tokens in secure storage only; no hardcoded keys (service-role key never ships in the app) |
| M2: Inadequate Supply Chain Security | Pin exact package versions; `flutter pub outdated` + dependency audit in CI |
| M3: Insecure Auth/Authz | RLS on every table; Edge Functions re-validate entitlement server-side, never trust client flags |
| M4: Insufficient Input/Output Validation | Postgres constraints + check constraints (e.g., `surah_number between 1 and 114`); Edge Function input schema validation |
| M5: Insecure Communication | TLS everywhere (enforced by Supabase/Cloudflare/FCM by default); no cleartext traffic permitted in Android network security config |
| M6: Inadequate Privacy Controls | Minimal PII collection (no phone numbers, no unnecessary profile fields); listening data never sold/shared (state this explicitly in privacy policy) |
| M7: Insufficient Binary Protections | Standard Flutter release obfuscation (`--obfuscate --split-debug-info`) |
| M8: Security Misconfiguration | RLS-on-by-default policy for every new table enforced via migration review checklist |
| M9: Insecure Data Storage | Isar encryption + secure storage for tokens (6.7) |
| M10: Insufficient Cryptography | Rely on platform-provided crypto primitives (Keychain/Keystore, TLS), avoid hand-rolled crypto anywhere |

### 6.10 Anti-Abuse Protection
- Per-user, per-IP (where available at the Edge Function layer) rate limiting on: sign-in attempts, download issuance, search queries.
- Anomaly signal (not hard-block): sudden spike in download-URL requests from one account → flag for delayed/step-up verification rather than instant ban, to avoid false-positive lockouts of legitimate heavy users (e.g., someone downloading the whole Quran once before a flight).
- CAPTCHA-equivalent (e.g., a lightweight challenge in the Edge Function) reserved for sign-up abuse only if bot signups are actually observed post-launch — avoid adding user friction speculatively.

---

## 7. Audio Architecture

### 7.1 Streaming Architecture
- `just_audio` `AudioSource` backed by a signed R2/CDN URL obtained just-in-time from `issue-audio-url`.
- Adaptive quality: `reciters.bitrate_options` exposes at least `high`/`low` object keys; client picks based on a `ConnectivityService` signal (Wi-Fi vs. cellular) and a user setting override.
- CDN cache-control headers on R2 objects set for long `max-age` + `immutable` (audio files are content-addressed/never mutated in place — a changed recitation gets a new object key) so repeat streams across all users hit Cloudflare's edge cache, not origin.

### 7.2 Audio Caching
- `just_audio`'s own transient network cache handles short-term re-listens within a session.
- A dedicated **LRU disk cache** (separate from "downloads," which are user-intentional/permanent) holds the last N streamed-but-not-explicitly-downloaded ayahs/surahs, sized as a user-configurable setting (default ~500MB), to make "I streamed this yesterday, let me hear it again" instant and cheap on repeat bandwidth.

### 7.3 Download Architecture
- Downloads run through `flutter_downloader` or a custom `Dio`+`WorkManager`/`BackgroundFetch`-based queue so downloads survive app backgrounding.
- Each download: request signed URL → stream to a temp file → verify checksum (R2 object's stored hash, returned via the Edge Function response) → encrypt at rest (6.7) → move to final location → write an Isar `DownloadedAudio` record → update the `downloads` audit row's status via a second Edge Function call (`confirm-download`) so server-side quota tracking reflects reality even though the bytes themselves never touch the server.

### 7.4 Offline Playback
- `just_audio`'s `AudioSource.uri` points at the local decrypted-on-read file (decrypt-on-the-fly via a custom `StreamAudioSource` rather than decrypting the whole file to a plaintext temp copy, to avoid a window where a full plaintext copy sits on disk).

### 7.5 Background Playback
- `audio_service` provides the platform media-session integration (lock screen controls, notification, CarPlay/Android Auto surface) and hosts the `just_audio` player in a background-capable isolate/service so playback survives app termination-from-memory on Android and backgrounding on iOS (within OS background-audio entitlement rules — declare the `audio` background mode in `Info.plist`).

### 7.6 Resume Playback
- Every position update (throttled, e.g., every 5s or on pause) upserts the single `listening_history` row for that `(user, surah, reciter)` — both locally (Isar, instant) and queued for sync. On app relaunch, the "Continue Listening" surface reads the most recently updated local row first (zero-latency), then reconciles against Supabase once online (handles the case of resuming a session started on another device).

### 7.7 Playback Synchronization (text-to-audio)
- Each surah's audio is paired with a **verse-timing map** (ayah → start_ms/end_ms), delivered as part of the translation/reference JSON bundle rather than as a separate live query, so highlighting the currently-recited ayah in the reader works fully offline once that surah's bundle is cached.

---

## 8. Offline-First Architecture

### 8.1 Isar Schema (local mirrors + local-only concerns)

```dart
// Illustrative field lists only — no code generation here, per instructions.

@collection
class BookmarkLocal {
  Id id;                    // Isar internal auto-id
  late String uuid;         // = server bookmarks.id (client-generated on create)
  late int surahNumber;
  late int ayahNumber;
  String? note;
  late DateTime clientUpdatedAt;
  late SyncState syncState; // synced | pendingCreate | pendingUpdate | pendingDelete
}

@collection
class ListeningHistoryLocal {
  Id id;
  late String uuid;
  late int surahNumber;
  late String reciterUuid;
  late int positionMs;
  late DateTime clientUpdatedAt;
  late SyncState syncState;
}

@collection
class DownloadedAudioLocal {
  Id id;
  late String reciterUuid;
  late int surahNumber;
  late String localEncryptedFilePath;
  late int bytesTotal;
  late DateTime downloadedAt;
  // No syncState — this collection is never synced to the server, by design (5.7).
}

@collection
class ReferenceCacheMeta {
  // Tracks ETag/version per reference bundle (quran text, a given translation,
  // a given tafsir) so the app only re-downloads reference JSON when it changes.
  Id id;
  late String bundleKey;
  late String etag;
  late DateTime lastFetchedAt;
}

@collection
class PendingMutation {
  Id id;
  late String entityType;   // 'bookmark' | 'favorite' | 'listening_history' | 'user_preferences'
  late String entityUuid;
  late String operation;    // insert | update | delete
  late String payloadJson;
  late DateTime createdAt;
  late int retryCount;
}
```

### 8.2 Sync Engine
- Runs as a coordinator triggered by (a) app foreground, (b) connectivity-restored event, (c) periodic background task (e.g., every 15 min via `workmanager`), and (d) an explicit "pull to sync" affordance in Settings.
- **Push phase:** drains `PendingMutation` FIFO per entity type, calling idempotent Postgres RPC functions (`upsert_bookmark(uuid, ...)` rather than raw REST inserts) so retries after a partial failure never double-apply.
- **Pull phase:** for each syncable table, query `where updated_at > last_synced_at` (a per-table watermark stored in Isar), merge results using the conflict resolver (8.3), then advance the watermark.
- **Realtime phase:** for tables with Realtime enabled, a live subscription applies incremental changes as they arrive, independent of the polling pull phase (which remains as a reconciliation safety net for missed events, e.g., after being offline for days).

### 8.3 Conflict Resolution
- **Primary rule: Last-Write-Wins on `client_updated_at`**, chosen deliberately over full CRDT/vector-clock machinery because the data model here (bookmarks, preferences, playback position) has low real-world concurrent-edit likelihood — a user is rarely editing the same bookmark on two devices within the same second — and LWW keeps the sync engine simple and debuggable.
- **Exception — `listening_history` position:** a pure LWW on position could regress a further-along resume point if an old device's watermark update lands late. Mitigation: when reconciling `listening_history`, prefer the row with the **greater `position_ms` within the same surah/reciter if `client_updated_at` values are within a short window (e.g., 2 minutes)** — approximates "resume from wherever I got furthest," which matches user intent better than strict timestamp ordering for this one table.
- **Deletes:** tombstoned (soft-delete flag + short retention) rather than hard-deleted server-side for a grace period, so a delete that raced with an update on another device doesn't resurrect data unexpectedly on the deleting device — the sync engine treats a tombstone as authoritative once seen, but a very-recent update to the same uuid from another device takes precedence within the LWW window.

### 8.4 Local-First Workflow (summary)
Read: Isar only, always. Write: Isar + enqueue, never block on network. Sync: background, best-effort, resilient to being offline for arbitrarily long. This is the same pattern described in Section 3.4 at the repository level — Section 8 is the engine underneath it.

### 8.5 Background Synchronization
- Android: `WorkManager` periodic + expedited work requests.
- iOS: `BGAppRefreshTask` (opportunistic, OS-scheduled — cannot be guaranteed to run on a fixed cadence, so the foreground/connectivity-restored triggers remain the primary sync paths on iOS, with background refresh as a bonus-effort supplement).

---

## 9. Design System

### 9.1 Color Palette
An Islamic-inspired but modern palette, avoiding the cliché "green and gold only" trap while still reading unmistakably as a Quran app:

| Token | Hex (indicative) | Use |
|---|---|---|
| `primary` (Deep Emerald) | `#0F5C4A` | Primary actions, active states |
| `primary.light` | `#3E8E76` | Secondary accents, progress |
| `secondary` (Warm Gold) | `#C9A24B` | Bookmark highlights, premium badges — used sparingly, as an accent, not a background |
| `surface.light` | `#FAF7F0` (warm off-white, evokes parchment) | Reading background |
| `surface.dark` | `#12181B` | Dark mode reading background (true black avoided for OLED comfort during long reading sessions) |
| `ink` (text) | `#1B2421` | Primary text on light |
| `error` | `#B3402A` | Muted terracotta rather than harsh red — fits the palette |

### 9.2 Typography
- **Arabic Quran text:** a licensed, Uthmani-script-accurate font (e.g., KFGQPC Uthmanic Script or equivalent — **must verify licensing terms for commercial app distribution before shipping**, this is not a decision to default silently).
- **UI Arabic (labels, tafsir):** a clean, highly-legible Naskh-style font distinct from the Mus'haf font, to visually separate "this is scripture" from "this is app chrome."
- **Latin UI text:** a humanist sans-serif with strong Arabic-numeral pairing and good multi-language coverage (translations span many scripts — Urdu, Indonesian, French, etc.); confirm the chosen font's script coverage per supported locale before lock-in.
- Font scale is user-adjustable independently for Quran text vs. UI text (a `Al-Muallim` persona need vs. a `Al-Musafir` glance-and-go need are different).

### 9.3 Animations
- Minimal, purposeful motion only: page-turn-style transition between surahs (subtle, not literal skeuomorphism), a gentle pulse on the currently-playing ayah highlight, standard Material/Cupertino-adaptive transitions elsewhere.
- Explicitly avoid: gamified confetti/celebration animations for reading streaks — tonally mismatched with worship content. Progress can be shown quietly (a filled bar, a checkmark) without celebratory flourish.

### 9.4 Lottie Usage
- Reserved for: onboarding illustrations, empty states (e.g., "no downloads yet"), and a subtle loading indicator shaped like a crescent/geometric pattern rather than a generic spinner. Keep Lottie files small (<50KB) and lazy-loaded — they should enhance, not delay, perceived performance.

### 9.5 Icon System
- A single consistent icon set (e.g., a customized subset of Lucide/Phosphor icons, or a small bespoke set for Quran-specific concepts like "tafsir," "qira'ah style," "hifz mode" that have no good generic-icon-library equivalent).
- Icons for reciter/qira'at style should be abstract/geometric (Islamic geometric-pattern-derived), not literal (avoid depicting people).

### 9.6 Component Library
Build a small internal Flutter widget library (`core/widgets/`) before feature work begins: `AyahCard`, `ReciterListTile`, `PlaybackControlBar`, `BookmarkChip`, `TranslationToggle`, `DownloadProgressIndicator`, `EmptyState`, `ErrorStateView`. Centralizing these early prevents each feature team from re-inventing slightly-inconsistent versions.

---

## 10. User Experience — Key Journeys

### 10.1 First Launch → Onboarding
1. Splash (brand only, <1s, no forced animation delay).
2. Language/locale selection (detect device locale, allow override).
3. Value-prop screens (3 max): "Read," "Listen offline," "Never lose your place."
4. **Immediate access** — drop straight into the Quran reader (Surah Al-Fatihah) as a **guest/anonymous session**, no forced sign-up. This directly serves the "respect the sanctity, reduce friction" principle from Section 1.

### 10.2 Sign-Up / Login
- Triggered contextually, not upfront: first bookmark attempt, first download attempt, or an explicit "Sync your progress" prompt in Settings.
- Sign-up sheet offers Google/Apple as primary (one-tap) with email as secondary, never the reverse — social auth should be visually primary given the friction reduction.
- On successful auth from a guest session, **merge guest-session local data** (any bookmarks/preferences made before sign-up) into the newly authenticated account rather than discarding it — a guest who bookmarked 5 ayahs and *then* signed up should not lose them.

### 10.3 Reading the Quran
- Default view: continuous scroll by surah (mus'haf-page-accurate layout optional as a setting for users who memorize by page position).
- Tap ayah → inline action sheet: bookmark, play from here, copy, share text (not audio — see licensing note in Section 6), view translation/tafsir toggle.
- Reading position persisted continuously (same mechanism as listening position, Section 7.6) so closing the app mid-surah resumes exactly there next time, unprompted.

### 10.4 Listening Online (Streaming)
- Tap a surah/reciter → playback starts within a target <1.5s perceived latency (pre-warm the signed-URL request as soon as the surah page opens, before the user taps play, using the currently-selected default reciter — a reasonable pre-fetch given surah selection strongly predicts imminent playback intent).
- Mini-player persists across navigation; full player reachable via swipe-up, showing ayah-synced text (Section 7.7).

### 10.5 Downloading for Offline
- Explicit per-surah or per-reciter "Download All" affordance, with clear size estimate shown **before** confirming (respect users on limited data plans/storage).
- Downloads visibly queue with progress; app remains usable during download (non-blocking, background-capable per Section 7.3).
- A "Downloads" management screen shows total storage used, per-item delete, and a clear free-vs-premium quota indicator.

### 10.6 Managing Bookmarks
- Bookmarks list groups by surah, most-recent-first, with the optional note visible inline; swipe-to-delete; tap to jump directly into reader+player at that ayah.

### 10.7 Resuming Playback
- App launch (if there was an active/paused session) shows a persistent "Continue: Surah X, Ayah Y — Reciter Z" card on the home surface, one tap to resume exactly where left off — this single interaction is arguably the highest-leverage UX moment in the entire app for the `Al-Musafir` and `Al-Muta'abbid` personas and should get disproportionate design attention/testing.

---

## 11. Scalability Plan

| Stage | Primary Bottleneck | Mitigation |
|---|---|---|
| **1,000 users** | None — Supabase free/small-tier Postgres and R2 handle this trivially. Focus entirely on correctness, not scale. | N/A |
| **10,000 users** | Supabase connection limits under bursty concurrent app-opens (e.g., a viral moment, or simply Ramadan-season traffic patterns which this app category should explicitly plan for). | Enable **PgBouncer/Supavisor connection pooling** (Supabase-managed transaction-mode pooler); ensure Flutter app uses the pooled connection string for Postgrest calls. |
| **100,000 users** | (a) R2/CDN egress for popular reciters' audio; (b) Realtime connection count; (c) Edge Function cold-start latency under load for `issue-audio-url`. | (a) Cloudflare CDN edge caching already absorbs most of this — verify cache-hit ratio dashboards; (b) scope Realtime subscriptions tightly (only the 4 tables in 4.5, filtered `where user_id=eq.<uid>`, never an unfiltered broadcast); (c) keep Edge Functions minimal/no heavy cold dependencies, consider a lightweight in-function cache of reciter entitlement lookups. |
| **1,000,000 users** | (a) Postgres write throughput on `listening_history`/`recent_plays` if position updates are too chatty; (b) `daily_ayah` FCM broadcast fan-out; (c) database size/index bloat on high-cardinality tables. | (a) Throttle client-side position-update frequency harder (e.g., 10–15s intervals, plus on pause/backgrounding only — not a fixed timer regardless of state) and batch multiple pending mutations into fewer round trips; (b) use FCM **topic messaging** rather than per-token fan-out for daily ayah (already planned) plus staggered send windows across timezones; (c) partition/prune `recent_plays` aggressively (5.9 already caps at ~50/user; enforce via scheduled cleanup, not just client-side truncation) and monitor `pg_stat_user_tables` for bloat, running `VACUUM`/considering table partitioning by month for the append-heavy history table if it's retained at all beyond the resume-position row. |

**Cross-cutting scale principle:** almost every bottleneck above is either (a) an egress/bandwidth problem, solved by R2+CDN from day one rather than retrofitted, or (b) a "too much Realtime/polling chatter" problem, solved by disciplined, filtered subscriptions and client-side throttling decided *now* rather than under incident pressure later. Very little of this plan requires a "rip out Supabase and build custom infra" event even at 1M users, provided these disciplines are followed from Phase 1 — that's the actual payoff of the serverless-first bet.

---

## 12. Cost Optimization

These are **indicative, order-of-magnitude planning estimates**, not vendor quotes — validate against current Supabase/Cloudflare/Firebase pricing pages before budgeting, since pricing tiers change.

| Stage | Supabase | Cloudflare R2 | Firebase (FCM) | Rough Total/mo |
|---|---|---|---|---|
| **MVP (pre-launch/soft-launch, <1k users)** | Free tier likely sufficient (Postgres, Auth, small Storage/Edge Function usage all within free-tier limits) | Free tier (10GB storage, no egress fee ever) likely sufficient for a curated set of 3–5 reciters' compressed audio | Free (FCM has no cost at any scale) | **$0–25** |
| **10,000 users** | Pro tier (~$25 base) covers larger Postgres/connection needs; Edge Function invocations still cheap at this volume | A few hundred GB stored (more reciters/surahs cached); **$0 egress** is the key R2 advantage — cost is nearly pure storage, tens of dollars/mo | Free | **~$75–150** |
| **100,000 users** | Pro tier + compute add-ons for a larger Postgres instance as `listening_history`/Realtime connection count grows; Edge Function invocation volume becomes a real line item | Storage cost grows with reciter catalog breadth, not with listener count (thanks to CDN caching absorbing repeat reads) — still egress-free; likely low hundreds/mo | Free | **~$400–800** |
| **1,000,000 users** | Likely needs Supabase's Team/Enterprise tier or a dedicated larger Postgres instance, plus meaningful Edge Function invocation spend; connection pooling (11) is what keeps this from spiraling | Storage scales with content catalog (reciters × surahs × bitrates), which grows far slower than user count — this is the architecture's single biggest cost win at scale versus any egress-billed storage provider | Free | **~$2,000–5,000+** (wide range — depends heavily on DAU/session frequency, i.e., realtime connection concurrency and Edge Function call volume, not on raw user count) |

**The single highest-leverage cost decision in this entire document is R2-for-audio-with-CDN-in-front.** Audio is the overwhelmingly dominant byte volume in this app; any egress-billed storage (including Supabase Storage itself, or S3 without a CDN/Cloudflare-fronting arrangement) would make audio-heavy usage the dominant cost line by 100k users, likely by an order of magnitude versus the R2 path. Re-verify this assumption isn't accidentally violated (e.g., someone routing audio "temporarily" through Supabase Storage during a migration and forgetting to route it back) via a cost-monitoring alert on Supabase Storage egress specifically.

---

## 13. Engineering Roadmap

### Phase 1 — Foundation
- **Goals:** Auth, base Flutter architecture skeleton, Supabase project + RLS baseline, CI/CD pipeline, crash reporting wired up.
- **Deliverables:** Working sign-up/sign-in (email + Google + Apple + anonymous), empty-state app shell with navigation, `profiles`/`user_preferences` tables live with RLS, Isar encrypted DB initialized.
- **Risks:** Underestimating Apple Sign-In's mandatory-if-other-social-login-exists review requirement (plan it into Phase 1, not as an afterthought before submission).
- **Architecture decisions locked here:** folder structure (Section 3.2), DI approach (get_it + GetX bindings), Failure/error-handling pattern (3.8) — changing these later is expensive, get them right now.

### Phase 2 — Quran Reader
- **Goals:** Full Quran text rendering, at least one translation, reading-position persistence.
- **Deliverables:** `translations` table + Storage bundles, reader UI with ayah-tap actions, offline-first reading (works with zero network after first content sync).
- **Risks:** Font licensing (9.2) not resolved before this phase's UI work begins — blocks visual QA. Resolve font licensing as a Phase 1 exit criterion, not a Phase 2 task.
- **Architecture decisions:** reference-content caching strategy (`ReferenceCacheMeta`, ETag-based) established here and reused by every future content type (tafsir, additional translations).

### Phase 3 — Audio Streaming
- **Goals:** Streaming playback, background playback, resume.
- **Deliverables:** `reciters` table, R2 bucket + CDN configured, `issue-audio-url` Edge Function, `just_audio`+`audio_service` integration, `listening_history` sync.
- **Risks:** Background playback platform quirks (iOS background-audio entitlement edge cases, Android battery-optimization killing the service on some OEM skins) — budget explicit device-lab testing time, not just simulator testing.

### Phase 4 — Offline Downloads
- **Goals:** Full download/offline-playback pipeline with protection (Section 6.6/6.7).
- **Deliverables:** `downloads` table + `confirm-download`/quota Edge Functions, encrypted local storage, Downloads management UI.
- **Risks:** Storage-quota UX complexity (free vs. premium limits) — validate the quota model with real device storage constraints (older/cheaper Android devices) before finalizing default quota numbers.

### Phase 5 — Search
- **Goals:** Full-text search across Quran + translations, tafsir introduced.
- **Deliverables:** Postgres full-text search (`tsvector`/`pg_trgm`) over reference content (search is over largely-static reference data, not user data — a great fit for Postgres FTS without needing a separate search service like Algolia/Meilisearch at this stage); `tafsir` table + content live.
- **Risks:** Arabic-text search quality (diacritics/normalization) is a genuinely hard sub-problem — allocate dedicated research time, don't treat it as "just add a search bar."

### Phase 6 — Analytics
- **Goals:** Privacy-respecting product analytics, daily ayah feature.
- **Deliverables:** `daily_ayah` table + scheduled Edge Function + FCM topic broadcast; a minimal analytics event pipeline (aggregate, not per-user-identifiable beyond what's operationally necessary) — be deliberate here given the sensitivity of "worship habit" data (Section 6.9, M6).
- **Risks:** Scope creep toward invasive tracking — set an explicit data-minimization review gate before this phase ships.

### Phase 7 — Premium Features
- **Goals:** Monetization live.
- **Deliverables:** `validate-iap-receipt` Edge Function, `subscription_tier` gating across reciters/tafsir/quotas, realtime cross-device sync polish, MFA option.
- **Risks:** Receipt-validation edge cases (refunds, subscription lapses, family sharing on iOS) — this is where "serverless-first" still needs real engineering rigor; do not underscope this Edge Function.

### Phase 8 — Global Scale
- **Goals:** Harden for the 100k→1M path (Section 11/12).
- **Deliverables:** Connection pooling confirmed under load test, Realtime subscription audit, cost-monitoring alerts (Section 12) live, `recent_plays`/history pruning jobs running, localization expansion (additional translation languages) informed by Phase 6 analytics on actual locale demand.
- **Risks:** Load-testing a Supabase project realistically is nontrivial — budget for a dedicated staging project with synthetic load generation well before an actual traffic spike (e.g., before a Ramadan season) forces the issue reactively.

---

## Appendix A — Explicit Assumptions Challenged / Alternatives Considered

- **Isar vs. Drift/sqflite:** Isar chosen per constraint; worth noting Isar's long-term maintenance status should be periodically reassessed (it changed maintainership history) — not a blocker, but a watch-item for Phase 8 architecture review, not a Phase 1 concern.
- **GetX vs. Riverpod/Bloc:** Chosen per constraint. The repository-pattern-first, use-case-driven structure in this document is deliberately designed so that **swapping GetX for another state manager later would only touch the `presentation/` layer of each feature** — domain and data layers are framework-agnostic by construction. This is the practical hedge against GetX-specific criticisms (e.g., global state pitfalls) without abandoning the stated constraint.
- **Supabase Storage vs. R2 for *all* storage:** Deliberately split (Section 2.1) rather than defaulting to "one storage provider for simplicity" — the cost math (Section 12) makes this the single most consequential deviation-from-the-obvious-default in this document.
- **No admin panel, really?** The reference-data management approach (Section 5.11 note) is workable at the content scale this app needs (a few dozen reciters, a few dozen translations/tafsir sources) but should be revisited explicitly if content-team (non-engineer) content management becomes a real operational need — at that point, a minimal internal tool is a scope change worth proposing deliberately, not smuggling in.