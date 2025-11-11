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


## Payment Flow (Needs to be checked often, do not rely on locally stored payment info)
User → opens app
     → signs in via Supabase OAuth
     → taps “Upgrade to Premium”
         ↓
In-app Purchase flow (Play Store / App Store)
         ↓
Store returns receipt / purchase token
         ↓
App validates it locally (via `in_app_purchase`)
         ↓
(optional) Send token to backend (Supabase function) for server-side validation
         ↓
Backend verifies with Google/Apple APIs and updates `Subscription` table
         ↓
UserProfile.subscriptionStatus = 'active'


