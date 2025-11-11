---

# 🏛 System Design — Layers, Components & Diagrams

---

## ✅ Layer naming

From top (UI) to bottom (storage / infra):

1. **Presentation** (UI)
   - Widgets, Screens, Theming, Accessibility
2. **State** (ViewModel)
   - Riverpod Providers, Notifiers, Controllers
3. **Application** (Use Cases / Interactors / Coordinators)
   - Business logic, Flows, Superflow (app-level coordinator)
4. **Domain**
   - Entities (pure Dart), Repository Interfaces
5. **Data**
   - Repository Implementations, DAOs (Drift), Remote Data Sources (API clients)
6. **Services & Infrastructure**
   - Networking, OCR, AI Engine
   - EncryptionService, FileStorageService, NotificationService
   - SyncManager (queue, conflict resolution)
   - MigrationManager (schema migrations)
   - AuthService (Supabase auth/session management)
   - SubscriptionService (AppStore/PlayStore receipts)
   - BackgroundTaskManager (periodic sync, cleanup)
   - ErrorMonitoringService (crash + log reporting)
7. **Platform / External**
   - Supabase (auth, optional sync)
   - Apple/Google In-App Purchases
   - Google Maps / NHS hospital APIs / CQC
   - App/Play Store verification APIs
   - Device KeyStore / Secure Enclave
   - OS-level notification and background task APIs

---

## 🔎 Short descriptions / responsibilities

### Presentation (UI)
- Visual components and pages.
- Should only call State layer (providers/notifiers).
- No direct DB or network access.

### State (ViewModel)
- Holds UI state, validation, ephemeral form state.
- Calls Use Cases for actions and `refresh()` methods for data.
- Exposes `Future`-based APIs for the UI.

### Application (Use Cases / Interactors / Coordinators)
- Encapsulates business rules and orchestrates multiple repositories/services.
- Example: `AddBiomarkerUseCase`, `StartKickCounterUseCase`, `HospitalSelectionCoordinator`.
- The **Superflow** or **Coordinator** lives here (handles app-wide flows and navigation decisions between Today, My Health, Baby, Tools).

### Domain
- Pure domain entities (no frameworks).
- Repository interfaces (contracts) that define operations (e.g., `BiomarkerRepository` interface).

### Data
- Contains:
  - **DAO** (Drift) for table-level operations (CRUD).
  - **Repository implementations** that map domain entities to DB models and call services (e.g., `BiomarkerRepositoryImpl`).
  - **Remote sources**: API clients for Supabase, Maps, AI backends.
- Responsible for transactions, persistency, and mapping between domain and DB.

### Services & Infrastructure
- Cross-cutting and support systems shared across the app:
  - **Networking** – HTTP client, retry/interceptors.
  - **OCRService** – on-device text extraction.
  - **AIService** – local/remote model wrapper for chat and predictions.
  - **EncryptionService** – secure field encryption/decryption.
  - **FileStorageService** – secure file handling, encrypted local storage.
  - **NotificationService** – local notifications and scheduling.
  - **SyncManager** – handles queued data sync, conflict resolution, and timestamps.
  - **MigrationManager** – Drift schema migrations and version tracking.
  - **AuthService** – authentication, token management, session lifecycle.
  - **ReceiptVerificationService** – purchase validation with stores.
  - **BackgroundTaskManager** – periodic background jobs, receipts verification.
  - **ErrorMonitoringService** – logs, crash reporting, diagnostics.

### Platform / External
- Third-party and OS-level systems:
  - Supabase (auth, storage, optional sync)
  - App Store / Play Store (purchases, receipts)
  - Google Maps / NHS APIs / CQC data sources
  - Store verification endpoints (for receipts)
  - Device KeyStore / Secure Enclave
  - OS background task + notification APIs

---

## 🧭 How components interact (mermaid diagram)

### 1) High-level flow
```mermaid
graph LR
  subgraph UI Layer
    UI[UI Widgets]
  end

  subgraph State Layer
    VM[ViewModel / Riverpod Notifier]
  end

  subgraph App Layer
    UC[Use Cases / Coordinators]
    Super[Superflow / App Coordinator]
  end

  subgraph Domain
    RepoIface[Repository Interfaces]
    Entities[Entities]
  end

  subgraph Data
    RepoImpl[Repository Implementations]
    DAO[Drift DAO]
    RemoteAPI[Remote API Clients]
  end

  subgraph Services
    Net[Networking]
    OCR[OCR Service]
    ENC[EncryptionService]
    Files[FileStorageService]
    Notif[NotificationService]
    Sync[SyncManager]
    Mig[MigrationManager]
    Auth[AuthService]
    Receipt[ReceiptVerificationService]
    Err[ErrorMonitoringService]
  end

  subgraph External
    Supa[Supabase]
    Store[AppStore / PlayStore]
    MapAPI[Maps / NHS / CQC APIs]
    OS[OS APIs / Keystore]
  end

  UI --> VM --> UC --> RepoIface --> RepoImpl --> DAO --> DB[(Drift DB)]
  RepoImpl --> RemoteAPI --> Supa
  UC --> Services
  RepoImpl --> ENC
  RepoImpl --> Files
  RepoImpl --> Sync
  Sync --> RemoteAPI
  Auth --> Supa
  Receipt --> Store
  Mig --> DB
  Err --> RepoImpl
  Super --> UC
  Notif --> OS
