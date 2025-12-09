# 🧱 Architecture Overview

## Purpose
This document describes the **overall architecture** of the Zeyra pregnancy app — including layers, dependencies, and principles. It serves as a guide for both developers and AI-assisted code generation.

---

## 🏗️ Architecture Style

Zeyra follows a **Clean Architecture** approach adapted for Flutter, designed for:
- **Scalability** – features evolve independently.
- **Testability** – pure logic separated from UI.
- **Maintainability** – clear boundaries between layers.
- **Offline-first design** – Drift as the local data source.

---

## ⚙️ Technology Stack

| Layer | Technology |
|-------|-------------|
| UI / State | Flutter + Riverpod |
| Routing | GoRouter |
| Local Database | Drift |
| Cloud Auth / Sync | Supabase |
| OCR | Google ML Kit |
| File Handling | Local storage + encryption |
| Dependency Injection | Riverpod providers |
| Testing | Flutter Test + Mockito/Mocktail |

---

## Data Encryption & Security

### Overview
Zeyra prioritizes user privacy and compliance with **GDPR**, **HIPAA**, and **NHS Digital Standards** by keeping all sensitive data **on-device** and encrypting the entire database at rest using **SQLCipher**.

### Implementation

1. **Full Database Encryption (SQLCipher)**
   - The entire database file is encrypted using **SQLCipher** with **AES-256**
   - **SQLCipher provides**:
     - **Confidentiality**: All data (tables, indexes, metadata) encrypted
     - **Integrity**: HMAC-SHA512 authentication prevents tampering
     - **Performance**: Native C implementation with hardware acceleration
     - **Compliance**: 256,000 PBKDF2 iterations (HIPAA/FIPS compliant)
   - Encryption keys are stored securely using **flutter_secure_storage**:
     - **Android Keystore System** (hardware-backed TEE/SE)
     - **iOS Keychain** (Secure Enclave protected)

2. **SQLCipher Security Settings**
   ```sql
   PRAGMA cipher_page_size = 4096;
   PRAGMA kdf_iter = 256000;
   PRAGMA cipher_hmac_algorithm = HMAC_SHA512;
   PRAGMA cipher_kdf_algorithm = PBKDF2_HMAC_SHA512;
   PRAGMA cipher_memory_security = ON;
   ```

3. **Key Management**
   - 256-bit keys generated **per user** using cryptographically secure random
   - Each user has a unique key stored as `zeyra_db_key_<authId>` in secure storage
   - Keys never leave the device's secure storage
   - Keys are cleared from memory when session is locked
   - `cipher_memory_security = ON` ensures native memory is also cleared
   - Cloud sync (when added) will never upload raw keys

4. **Database Encryption Service**
   - Implemented in `lib/core/services/database_encryption_service.dart`
   - Manages per-user SQLCipher keys
   - Keys generated on first login, retrieved on subsequent logins
   - `clearCache()` method for secure logout

5. **Per-User Database Isolation**
   - Each user has a dedicated SQLCipher database file: `zeyra_<authId>.db`
   - Each user has a unique encryption key: `zeyra_db_key_<authId>`
   - Databases are stored in the Application Documents Directory
   - User A's data is cryptographically inaccessible to User B
   - On logout, database connection is closed and encryption key is cleared from memory
   - Data persists locally (encrypted) for offline access when user returns

6. **Data Protection**
   - **PII Scrubbing**: All sensitive data removed from logs before remote transmission
   - **Data Minimization**: Pagination, history limits, and field exclusion per GDPR
   - **Secure Export**: External data exports use additional encryption

---

## 🔒 Session Architecture

### Overview
The app implements a secure session management system that protects user data through database locking, biometric authentication, and inactivity timeouts.

### Session States
```
LOCKED           → Initial/undefined state, no active session
REQUIRES_LOGIN   → Need full Supabase authentication (no valid token)
REQUIRES_LOCAL_AUTH → Need biometric/PIN authentication (valid token exists)
ACTIVE           → Session active, database unlocked, user can access data
```

### Session Manager
The `SessionManager` is the central coordinator for authentication and database access:
- Manages transitions between session states
- Coordinates database lock/unlock operations
- Integrates with `LocalAuthService` for biometrics
- Handles inactivity detection via `InactivityService`

### Database Locking
**Locking = Close Database Connection + Clear Encryption Key from Memory**

| Action | On Lock | On Unlock |
|--------|---------|-----------|
| Database | `close()` called | New connection opened |
| Encryption Key | Cleared from memory | Loaded from secure storage |
| Repository Access | Throws `DatabaseLockedException` | Normal operation |
| UI | Shows lock screen | Returns to main app |

### Auto-Lock Triggers
- **Inactivity timeout**: User-configurable (1/5/15/30 min), default 5 minutes
- **Background timeout**: 1 minute after app is backgrounded
- **Manual logout**: User-initiated from settings

### Local Authentication (Biometrics)
- Uses `local_auth` package for Face ID / Fingerprint / Device PIN
- **Enabled by default** (opt-out) if device supports biometrics
- Falls back to Supabase login after 3 failed attempts
- If user removes biometrics from device → auto-disable, fall back to Supabase login

### Multi-Account Support
- Multiple users can have accounts on a single device
- Each account has complete data isolation (separate DB + key)
- Last-used account is tried first on app launch
- "Switch Account" option available in Settings

### Authentication Decision Flow
```
App Launch
    │
    ▼
Has valid Supabase session?
    │
    ├─ NO → Show Supabase Login
    │
    └─ YES → Has local database for this user?
                  │
                  ├─ NO → First login: Create DB, generate key, auto-unlock
                  │
                  └─ YES → Device supports biometrics?
                               │
                               ├─ NO → Auto-unlock session
                               │
                               └─ YES → Show biometric prompt
                                            │
                                            ├─ SUCCESS → Unlock session
                                            │
                                            └─ FAILED (3x) → Require Supabase login
```

---

## 🚀 Scalability Guidelines

1. **One feature = one module** (self-contained).
2. Shared logic goes into `/core/` or `/shared/`.
3. Each entity and repository has its own folder.
4. Use cases and entities are pure Dart — never depend on Flutter packages.
5. Keep the database modular by feature (Drift tables defined per domain area).

---

## 🧠 Key Design Decisions

- **Offline-first architecture:** Every entity is stored locally before syncing.
- **Separation of concerns:** UI never interacts directly with data sources.
- **Future cloud compatibility:** Supabase sync and multi-device support are planned but isolated from MVP logic.
- **Composable UI:** Global shared widgets for consistent look and feel.
