# 🔄 Data Flow in Zeyra

This document explains how data moves through the app — from the user interface to local storage and, in the future, to the cloud.

---

## 🧭 Overview

Zeyra uses a **unidirectional data flow** based on Clean Architecture principles:
UI → ViewModel / State → Use Case / Interactor → Repository → Data Source (Local/Remote) → Storage

When data changes, Drift streams *could* notify the view model, which updates UI. For MVP we **avoid** reactivity (see "Reactive policy" below).

---

## 🧩 Example Flow – Adding a Biomarker

1. **User Action**  
   User adds a biomarker via “My Health → Add Biomarker” screen.

2. **ViewModel / State Layer**  
   UI calls ViewModel which validates input and calls the `AddBiomarker` use case.

3. **Use Case (Interactor)**  
   Use case constructs a domain `Biomarker` entity and calls `BiomarkerRepository.addBiomarker()`.

4. **Repository**  
   Repository maps the domain entity to DB model, and calls the Drift DAO to persist locally (and marks `needsSync = true` if sync will be done later).

5. **DAO / Data Source**  
   Drift DAO executes the insert in a transaction and returns the created record.

6. **Return / UI Update**  
   ViewModel updates local UI state (e.g., success message, refresh list). No automatic reactivity required.

---

## 🔁 Read Operation – Viewing Biomarkers (Non-reactive default)

1. UI requests biomarker list via ViewModel.
2. ViewModel calls use case `GetBiomarkers`.
3. Use case calls repository `getBiomarkers()` which returns a `Future<List<Biomarker>>`.
4. UI displays list. If user adds new biomarker, the UI triggers an explicit refresh (e.g., call `refresh()` on success).

---

## ⚠️ Reactive Policy (MVP-first)

**Decision:** For MVP **do not use reactive database streams (watch())** anywhere in the app UI. Use `Future` reads and explicit refreshes instead.

**Rationale:**
- Simplifies lifecycle & memory management (no stream disposal bugs).
- Avoids complicated concurrency & sync issues while implementing core features rapidly.
- Reactive complexity can be introduced later, targeted to features that truly require it.

**How to implement this policy (practical rules):**
- DAOs must expose both forms, but repositories should only call `Future` methods for MVP:
  - `Future<List<T>> getAll()` — recommended for MVP
  - `Stream<List<T>> watchAll()` — allowed but **unused** until reactivity is enabled
- ViewModels should not subscribe to streams. They should:
  - call `await repo.getAll()` on init
  - expose explicit `refresh()` methods that re-run the Future call
- Use `autoDispose` providers for short-lived states, but avoid long-lived reactive providers.
- Logically group writes through repositories so background syncs and UI writes serialize.

**When to enable reactivity later:**
- If user feedback indicates certain screens feel stale or UX benefits from live updates (e.g., Dashboard, live tracking tools).
- After sync is implemented with robust conflict resolution.
- Start by enabling reactive streams for one feature at a time and add tests.

---

## 🔧 Sync & Conflict Notes (future)

When adding remote sync (Supabase):
- Use a **sync queue**: local changes flagged with `needsSync` are queued, retried, and acknowledged.
- Use `updatedAt` timestamps and a `syncVersion` or `changeId` for deterministic conflict resolution.
- Repository should be the single place that performs merge logic: "last-write-wins" by default, with overrides for fields requiring smarter merges.
- Wrap sync operations in DB transactions.

---

## Implementation Notes

- DAOs implement both getAll() and watchAll() but use only getAll() initially.
- Repositories expose Future-based APIs for all read operations.
- ViewModels call use cases and provide explicit refresh() methods.
- Writes are funneled through repository methods that set needsSync.
- Add logging for refresh/CRUD operations to monitor manual refresh frequency and evaluate reactivity needs.

## 🔗 Flow Diagram (Conceptual)

```mermaid
graph TD
  UI[Widgets] --> VM[ViewModel / Notifier]
  VM --> UC[Use Case]
  UC --> RepoIface[Repository Interface (Domain)]
  RepoIface --> RepoImpl[Repository Impl (Data)]
  RepoImpl --> Mapper[Mapper]
  Mapper --> DAO[Drift DAO]
  RepoImpl --> Remote[Remote API Client]
  RepoImpl --> Service[Encryption/File/OCR/AI Services]
  Service --> External[Supabase / OS / APIs]


---

## 🔐 Authentication & Session Flow

### New User Login Flow
```
User opens app
    │
    ▼
AuthGate checks Supabase session → No session found
    │
    ▼
Show Supabase Login Screen (Google / Apple / Email)
    │
    ▼
User authenticates successfully
    │
    ▼
SessionManager.onSupabaseAuth(user) called
    │
    ├─► Get authId from Supabase user
    │
    ├─► Check if database exists for this authId
    │       │
    │       └─► NO: First-time user
    │               │
    │               ├─► Create database file: zeyra_<authId>.db
    │               ├─► Generate encryption key: zeyra_key_<authId>
    │               ├─► Store key in secure storage
    │               └─► Initialize UserProfile, UserSettings, SessionState
    │
    ├─► DatabaseEncryptionService.getKeyForUser(authId)
    │       └─► Load or generate SQLCipher key
    │
    ├─► DatabaseLockService.unlock(authId)
    │       └─► Open database connection
    │
    ├─► SessionState = ACTIVE
    │
    └─► InactivityService.start()
            └─► Begin monitoring user activity
```

### Returning User Flow (with Biometrics)
```
User opens app
    │
    ▼
AuthGate checks Supabase session → Valid session found
    │
    ▼
SessionManager.initialize()
    │
    ├─► Get authId from session
    │
    ├─► Check if local database exists → YES
    │
    ├─► Check if device supports biometrics → YES
    │
    └─► SessionState = REQUIRES_LOCAL_AUTH
            │
            ▼
    Show Lock Screen with biometric prompt
            │
            ▼
    LocalAuthService.authenticate()
            │
    ┌───────┴───────┐
    │               │
SUCCESS          FAILED
    │               │
    ▼               ▼
SessionManager   Increment failedAuthAttempts
.onLocalAuth()        │
    │           ┌─────┴─────┐
    │           │           │
    │        < 3 times   >= 3 times
    │           │           │
    │           ▼           ▼
    │      Show retry   SessionState = REQUIRES_LOGIN
    │      prompt       (require Supabase password)
    │
    ├─► DatabaseEncryptionService.getKeyForUser(authId)
    │
    ├─► DatabaseLockService.unlock(authId)
    │
    ├─► SessionState = ACTIVE
    │
    └─► InactivityService.start()
```

### Inactivity Lock Flow
```
User is active (SessionState = ACTIVE)
    │
    ▼
InactivityService monitors:
  • Touch events (via root Listener widget)
  • App lifecycle (via WidgetsBindingObserver)
    │
    ├─► On any user activity: Reset inactivity timer
    │
    └─► Timer expires (5 min default) OR app backgrounded (1 min)
            │
            ▼
    InactivityService.onTimeout()
            │
            ▼
    SessionManager.lockSession()
            │
            ├─► InactivityService.stop()
            │
            ├─► DatabaseLockService.lock()
            │       │
            │       ├─► database.close()
            │       └─► Clear database reference
            │
            ├─► DatabaseEncryptionService.clearCache()
            │       └─► Clear key from memory
            │
            ├─► SessionState = REQUIRES_LOCAL_AUTH
            │
            └─► Navigate to Lock Screen
```

### Logout Flow
```
User taps "Logout" in Settings
    │
    ▼
SessionManager.logout()
    │
    ├─► SessionManager.lockSession()
    │       │
    │       ├─► Database connection closed
    │       └─► Encryption key cleared from memory
    │
    ├─► Supabase.auth.signOut()
    │       └─► Clear Supabase session token
    │
    ├─► SessionState = REQUIRES_LOGIN
    │
    └─► Navigate to Login Screen

NOTE: Database file and encryption key are NOT deleted.
      User's data persists for offline access when they return.
```

---

## 💾 Database Lifecycle

### Database Creation (First Login)
```
SessionManager.onSupabaseAuth(user)
    │
    ├─► authId = user.id
    │
    ├─► databasePath = "zeyra_<authId>.db"
    │
    ├─► DatabaseEncryptionService.getKeyForUser(authId)
    │       │
    │       ├─► Check secure storage for zeyra_db_key_<authId>
    │       │       └─► Not found (new user)
    │       │
    │       ├─► Generate 256-bit hex key (64 chars)
    │       │
    │       ├─► Store key in secure storage
    │       │
    │       └─► Cache key in memory
    │
    └─► DatabaseLockService.unlock(authId)
            │
            ├─► AppDatabase.forUser(authId)
            │       └─► LazyDatabase creates file on first query
            │
            └─► Run initial schema creation (onCreate)
```

### Database Opening (Session Unlock)
```
SessionManager.onLocalAuth() OR onSupabaseAuth()
    │
    ├─► DatabaseEncryptionService.getKeyForUser(authId)
    │       │
    │       ├─► Read key from secure storage
    │       │
    │       └─► Cache key in memory
    │
    └─► DatabaseLockService.unlock(authId)
            │
            ├─► AppDatabase.forUser(authId)
            │
            └─► Verify connection: SELECT 1
```

### Database Closing (Session Lock)
```
SessionManager.lockSession()
    │
    ├─► DatabaseLockService.lock()
    │       │
    │       ├─► database.close()
    │       │       └─► Flush pending writes, release file handle
    │       │
    │       └─► _database = null
    │
    └─► DatabaseEncryptionService.clearCache()
            │
            ├─► _cachedKey = null
            │
            └─► _currentUserId = null
```

### Database Deletion (Account Removal)
```
User confirms "Remove Account from Device"
    │
    ▼
AccountManager.removeAccount(authId)
    │
    ├─► Confirm: "This will delete all local data for this account"
    │
    ├─► SessionManager.lockSession() (if this is current user)
    │
    ├─► DatabaseEncryptionService.deleteKeyForUser(authId)
    │       └─► secureStorage.delete(zeyra_db_key_<authId>)
    │
    ├─► Delete database file
    │       └─► File(zeyra_<authId>.db).delete()
    │
    └─► Remove from registry (if using multi-account registry)

WARNING: This is irreversible. All encrypted data becomes unrecoverable.
```

---

## 💳 Payment Flow (RevenueCat - Do NOT store subscription locally)

**Important**: Subscription status is managed entirely by RevenueCat SDK. Do not create local Subscription entities.

```
User → opens app
     → completes onboarding
         ↓
RevenueCat SDK presents paywall
         ↓
User selects plan and completes purchase (Play Store / App Store)
         ↓
RevenueCat validates receipt automatically
         ↓
App checks entitlements via Purchases.getCustomerInfo()
         ↓
CustomerInfo.entitlements.active.containsKey('premium') = true
```

**Key Methods** (`PaymentService`):
- `isPremium()` → Check if user has active premium entitlement
- `purchase(Package)` → Initiate purchase flow
- `restore()` → Restore purchases for returning users
- `linkToAuthUser(authId)` → Link RevenueCat customer to Supabase user

---

## 🚀 Onboarding Flow

The app uses a **data-first** onboarding approach: user completes all screens (info collection, paywall) before authentication. Data is stored temporarily until auth succeeds, then persisted to `UserProfile` and `Pregnancy` entities.

**Important**: This is a **paid-only app** - the paywall cannot be skipped.

### Screen Progression (11 Screens)

```
1. Welcome → 2. Name → 3. Due Date/LMP → 4. Congratulations
     ↓
5. Value Prop 1 → 6. Value Prop 2 → 7. Value Prop 3
     ↓
8. Birth Date → 9. Notifications → 10. Paywall → 11. OAuth
```

### Onboarding State Flow

```
User opens app (not authenticated)
    │
    ▼
Welcome Screen
    │
    ├─► "I already have an account" pressed
    │       │
    │       ▼
    │   OAuth Login
    │       │
    │       ├─► Account exists with onboarding_completed = true
    │       │       └─► Navigate to Main App (check premium first)
    │       │
    │       ├─► Account exists with onboarding_completed = false
    │       │       └─► Resume onboarding from saved step
    │       │
    │       └─► NEW account (no metadata)
    │               └─► Clear pending data, restart onboarding from Welcome
    │
    └─► "Continue" pressed
            │
            ▼
    Name → Due Date/LMP → Congratulations → Value Props (x3)
            │
            ▼
    Birth Date → Notifications → Paywall (mandatory) → OAuth
            │
            ▼
    OnboardingService.finalizeOnboarding()
        │
        ├─► Create UserProfile entity
        ├─► Create Pregnancy entity (with calculated startDate/dueDate)
        ├─► Link RevenueCat customer to Supabase authId
        ├─► Update Supabase user metadata: onboarding_completed = true
        └─► Clear SharedPreferences onboarding data
            │
            ▼
    Navigate to Main App
```

### Due Date / LMP Calculation

The app supports bidirectional calculation between Expected Due Date (EDD) and Last Menstrual Period (LMP):

- Standard pregnancy duration: **280 days (40 weeks)**
- `dueDate = startDate + 280 days`
- `startDate (LMP) = dueDate - 280 days`

User can enter either value on the Due Date screen; the other is calculated automatically. Both can be fine-tuned later in app settings.

### OnboardingData (Temporary Entity)

Stored in SharedPreferences until authentication completes.

| Field | Type | Description |
|-------|------|-------------|
| firstName | String? | User's first name |
| dueDate | DateTime? | Expected due date (calculated if LMP provided) |
| startDate | DateTime? | LMP date (calculated if dueDate provided) |
| dateOfBirth | DateTime? | User's birth date |
| notificationsEnabled | bool | Notification permission granted |
| purchaseCompleted | bool | RevenueCat purchase successful |
| currentStep | int | Current onboarding screen index (0-10) |

### Onboarding Completion Flag

Stored in Supabase user metadata after successful onboarding:

```dart
await Supabase.instance.client.auth.updateUser(
  UserAttributes(data: {'onboarding_completed': true}),
);
```

Checked on app launch via `AuthNotifier.hasCompletedOnboarding`.


