# Security Model

This document provides comprehensive documentation of Zeyra's security architecture, including threat model, security guarantees, limitations, and implementation details.

---

## Overview

Zeyra is an offline-first pregnancy tracking app that handles sensitive medical data. Security is designed around these principles:

1. **Privacy-first**: All sensitive data stays on-device by default
2. **Per-user isolation**: Each user's data is cryptographically separated
3. **Defense in depth**: Multiple layers of protection (SQLCipher encryption, session management, platform security)
4. **Offline security**: Security properties are maintained without network connectivity
5. **Compliance-driven**: Designed for GDPR, HIPAA, and NHS Digital Standards

---

## Threat Model

### What We Protect Against

| Threat | Risk Level | Mitigation |
|--------|------------|------------|
| **Malicious next user** on shared device | High | Per-user SQLCipher database + per-user encryption key + session lock on logout |
| **Device theft** while app is in foreground | Medium | Inactivity timeout auto-locks after configurable period (default 5 min) |
| **Device theft** while app is backgrounded | Low | Background timeout locks after 1 minute |
| **Device theft** while app is locked | Low | Full database encrypted with SQLCipher AES-256, key in hardware-backed secure storage |
| **Shoulder surfing** during biometric unlock | Low | Use sticky auth, lock screen obscures sensitive data |
| **Brute force** biometric attacks | Low | Lock out after 3 failures, require Supabase password |
| **Session hijacking** | Low | Supabase handles token security with auto-refresh |
| **Data exfiltration** via backup | Medium | Entire database is encrypted; backup contains ciphertext only |
| **Network eavesdropping** | Low | HTTPS for all network communication; sensitive data not transmitted in v1 |
| **Memory scraping** | Low | SQLCipher `cipher_memory_security = ON` clears sensitive memory |

### What We Do NOT Protect Against

| Threat | Risk Level | Reason |
|--------|------------|--------|
| **Rooted/jailbroken devices** | High | Hardware-backed secure storage can be bypassed; OS integrity compromised |
| **Malware with root access** | High | Can intercept decrypted data in memory while app is unlocked |
| **Screen capture malware** | Medium | Displayed data can be captured; outside app's control |
| **Accessibility service abuse** | Medium | Malicious accessibility services can read screen content |
| **Physical device access** with expertise | Medium | Given enough time/resources, device security can be bypassed |
| **Social engineering** | Variable | User may be tricked into revealing credentials |

---

## Security Guarantees

### 1. Data Isolation Between Users

**Guarantee**: User A's data is cryptographically inaccessible to User B on the same device.

**Implementation**:
- Each user has a dedicated SQLCipher database file: `zeyra_<authId>.db`
- Each user has a unique 256-bit encryption key: `zeyra_db_key_<authId>`
- Keys are stored in platform secure storage (Android Keystore / iOS Keychain)
- Database connections are closed on logout; keys are cleared from memory

**Verification**: Even if User B gains access to User A's database file, the entire file is encrypted and unreadable without the SQLCipher key.

### 2. Full Database Encryption (SQLCipher)

**Guarantee**: The entire database file is encrypted at rest using AES-256.

**Implementation**:
- SQLCipher with AES-256 in CBC mode with HMAC-SHA512 for integrity
- 256-bit encryption key derived using PBKDF2-HMAC-SHA512
- 256,000 key derivation iterations (HIPAA/FIPS compliant)
- Per-page HMAC authentication prevents tampering

**SQLCipher Security Settings**:
```sql
PRAGMA key = "x'<hex_key>'";
PRAGMA cipher_page_size = 4096;
PRAGMA kdf_iter = 256000;
PRAGMA cipher_hmac_algorithm = HMAC_SHA512;
PRAGMA cipher_kdf_algorithm = PBKDF2_HMAC_SHA512;
PRAGMA cipher_memory_security = ON;
```

**What is protected**:
- ALL data in the database (tables, indexes, metadata)
- Biomarker values and medical readings
- Personal notes and comments
- Pregnancy data (kick counts, symptoms, etc.)
- AI chat history
- All foreign key relationships and timestamps

**Verification**: Run `PRAGMA cipher_version` to verify SQLCipher is active.

### 3. Key Protection

**Guarantee**: Encryption keys are stored in hardware-backed secure storage and protected by device authentication.

**Implementation**:
- **Android**: Keys stored in Android Keystore System
  - Hardware-backed on devices with TEE/Secure Element
  - Protected by device lock screen
- **iOS**: Keys stored in iOS Keychain
  - Protected by Secure Enclave on supported devices
  - Accessible only when device is unlocked

**Key Lifecycle**:
```
Generation → Secure Storage → Memory (when unlocked) → Cleared (on lock)
     ↓              ↓                    ↓                    ↓
  Random 256    Keystore/         Used for              Nullified;
   bits hex     Keychain         SQLCipher key          not deleted
```

### 4. Memory Safety

**Guarantee**: Encryption keys and sensitive data are cleared from application memory when the session is locked.

**Implementation**:
- `DatabaseEncryptionService.clearCache()` nullifies cached key reference
- SQLCipher `cipher_memory_security = ON` actively clears cryptographic memory
- Database connection is closed, releasing all in-memory data
- Dart garbage collector will reclaim the memory

**Limitation**: Dart does not support explicit memory zeroing. However, SQLCipher's native layer does handle secure memory wiping for cryptographic operations.

### 5. Session Timeout

**Guarantee**: Sessions are automatically locked after a period of inactivity to protect against unauthorized access.

**Implementation**:
- **Inactivity timeout**: User-configurable (1/5/15/30 min), default 5 minutes
- **Background timeout**: 1 minute after app is moved to background
- Touch events and UI interactions reset the inactivity timer
- App lifecycle events (pause/resume) are monitored

**Configuration** (stored in UserSettings):
```dart
inactivityTimeoutMinutes: int  // 1, 5, 15, or 30
backgroundLockEnabled: bool    // default: true
```

### 6. Authentication Fallback

**Guarantee**: If biometric authentication fails repeatedly, the system falls back to password authentication to prevent lockout.

**Implementation**:
- Track `failedAuthAttempts` in SessionState
- After 3 consecutive biometric failures → require Supabase password login
- Counter resets on successful authentication
- If device biometrics are removed → auto-disable, fall back to Supabase login

### 7. Offline Security

**Guarantee**: All security properties are maintained even without network connectivity.

**Implementation**:
- SQLCipher encryption works entirely offline
- Encryption keys stored locally in secure storage
- Database locking works entirely offline
- Biometric authentication uses local device APIs
- Session state persisted locally

**Network-dependent features**:
- Initial Supabase authentication requires network
- Password fallback after biometric lockout requires network
- Token refresh requires network (but cached tokens work offline)

---

## Per-User Database Isolation

### Architecture

```
Device Storage
├── zeyra_<userId_A>.db      # User A's SQLCipher encrypted database
├── zeyra_<userId_B>.db      # User B's SQLCipher encrypted database
└── (no registry needed)     # Supabase manages account list

Secure Storage (Keystore/Keychain)
├── zeyra_db_key_<userId_A>  # User A's SQLCipher encryption key
└── zeyra_db_key_<userId_B>  # User B's SQLCipher encryption key
```

### Naming Convention

| Resource | Pattern | Example |
|----------|---------|---------|
| Database file | `zeyra_<authId>.db` | `zeyra_f47ac10b-58cc-4372-a567-0e02b2c3d479.db` |
| Encryption key | `zeyra_db_key_<authId>` | `zeyra_db_key_f47ac10b-58cc-4372-a567-0e02b2c3d479` |

**Why authId?**
- Globally unique (UUID from Supabase)
- Immutable (unlike email which can change)
- No filesystem-unsafe characters
- Enables multi-account on single device

### Database Locking Mechanism

**Locked State**:
- Database connection is closed (`database.close()`)
- Encryption key is cleared from memory (`clearCache()`)
- All repository calls fail (provider throws StateError)
- UI shows lock screen

**Unlocked State**:
- Encryption key loaded from secure storage
- SQLCipher database opened with key
- Normal repository operations available
- UI shows main app

```
┌─────────────────────────────────────────────────────────┐
│                    DATABASE STATES                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌───────────────┐          ┌───────────────┐          │
│  │   UNLOCKED    │          │    LOCKED     │          │
│  │               │  lock()  │               │          │
│  │ • DB open     │ ───────► │ • DB closed   │          │
│  │ • Key in mem  │          │ • Key cleared │          │
│  │ • Can r/w     │ ◄─────── │ • No access   │          │
│  │               │ unlock() │               │          │
│  └───────────────┘          └───────────────┘          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Session Security

### Session State Machine

```
┌──────────────────────────────────────────────────────────────────────┐
│                       SESSION STATE MACHINE                           │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│                           ┌────────────┐                             │
│                           │   LOCKED   │                             │
│                           │ (app start)│                             │
│                           └─────┬──────┘                             │
│                                 │ initialize()                       │
│                    ┌────────────┼────────────┐                       │
│                    │            │            │                       │
│              no session    session +    session +                    │
│                    │       local data   no local data                │
│                    │       + biometrics                              │
│                    ▼            │            │                       │
│           ┌──────────────┐      │            │                       │
│           │REQUIRES_LOGIN│      ▼            │                       │
│           └──────┬───────┘ ┌────────────┐    │                       │
│                  │         │REQUIRES_   │    │                       │
│                  │         │LOCAL_AUTH  │    │                       │
│                  │         └─────┬──────┘    │                       │
│                  │               │           │                       │
│    supabase      │  local auth   │           │ auto-unlock           │
│    success       │  success      │           │                       │
│                  │               │           │                       │
│                  └───────────────┼───────────┘                       │
│                                  ▼                                   │
│                          ┌─────────────┐                             │
│                          │   ACTIVE    │                             │
│                          │(db unlocked)│                             │
│                          └──────┬──────┘                             │
│                                 │                                    │
│                    ┌────────────┴────────────┐                       │
│              inactivity                 explicit                     │
│              timeout                    logout                       │
│                    │                         │                       │
│                    ▼                         ▼                       │
│           ┌──────────────┐          ┌──────────────┐                 │
│           │REQUIRES_     │          │REQUIRES_LOGIN│                 │
│           │LOCAL_AUTH    │          │ (logged out) │                 │
│           └──────────────┘          └──────────────┘                 │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Inactivity Detection

**Touch Event Monitoring**: Root Listener widget resets timer on any touch

**App Lifecycle Monitoring**: WidgetsBindingObserver triggers lock on background

---

## Multi-Account Architecture

### Design

- Multiple users can have accounts on a single device
- Each account has complete data isolation (separate SQLCipher DB + key)
- Last-used account is tried first on app launch
- "Switch Account" option available in Settings

### Account Switching Flow

```
User taps "Switch Account"
    │
    ▼
SessionManager.lockSession()  // Lock current account
    │
    ├─► Close current SQLCipher database
    └─► Clear current encryption key from memory
    │
    ▼
Show Account Selector OR Supabase Login
    │
    ▼
User authenticates as different account
    │
    ▼
SessionManager.onSupabaseAuth(newUser)
    │
    ├─► Load new user's encryption key
    └─► Open new user's SQLCipher database
```

### Security Constraints

1. **Strict Isolation**: Account A can NEVER access Account B's database or encryption key
2. **Session Independence**: Each account has its own Supabase session
3. **No Cross-Account Data**: Only authId + email stored in registry (for display)
4. **Delete Confirmation**: Removing an account requires explicit user confirmation

---

## Data Protection & Compliance

### PII Scrubbing

All sensitive data is scrubbed before remote logging:
- Email addresses → `[EMAIL]`
- UUIDs/Session IDs → `[SESSION_ID]`
- Database keys → `[DB_KEY]`
- SQLCipher PRAGMA statements → `[DB_PRAGMA]`
- Medical data → `[MEDICAL_DATA]`
- Pregnancy data → `[PREGNANCY_DATA]`

### Data Minimization (GDPR)

- Pagination: Default 20 records per query
- History limits: Max 365 days retention
- Sensitive field exclusion: Notes, symptoms excluded from exports
- Analytics sanitization: All PII removed before analytics

---

## Implementation Dependencies

### Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSFaceIDUsageDescription</key>
<string>Zeyra uses Face ID to protect your health data</string>
```

### Dependencies

```yaml
# Database encryption
sqlcipher_flutter_libs: ^0.6.0  # SQLCipher native libraries
drift: ^2.16.0                  # Type-safe SQL queries

# Key storage
flutter_secure_storage: ^9.0.0  # Platform secure storage
```

---

## Security Checklist for Developers

### Before Release

- [ ] Verify SQLCipher is active (`PRAGMA cipher_version`)
- [ ] Test database is unreadable without correct key
- [ ] Test database locking on logout
- [ ] Test inactivity timeout triggers lock
- [ ] Test biometric fallback after 3 failures
- [ ] Test multi-account isolation (if enabled)
- [ ] Verify keys are cleared from memory on lock
- [ ] Test on rooted device and verify appropriate warnings

### Code Review

- [ ] No sensitive data logged (check PII scrubber)
- [ ] No hardcoded keys or secrets
- [ ] Repository uses async database provider correctly
- [ ] Session state transitions are validated
- [ ] Data minimization applied to queries

### Security Testing

- [ ] Attempt to open database with wrong key → should fail
- [ ] Attempt to read .db file as plain SQLite → should fail
- [ ] Kill app during active session, reopen → should require auth
- [ ] Switch users → previous user's data inaccessible

---

## Future Considerations

### Planned Enhancements

1. **Biometric-bound keys** - Keys that require biometric on every access
2. **Remote wipe** - Ability to wipe device data from web portal
3. **Security audit logging** - Track authentication attempts and failures
4. **Certificate pinning** - For Supabase API communication
5. **Tokenization** - For highly sensitive fields requiring additional protection

### Known Limitations to Address

1. **Memory safety**: Dart doesn't support explicit memory zeroing (mitigated by SQLCipher's native memory security)
2. **Screenshot protection**: No built-in way to prevent screenshots on all platforms
3. **Clipboard security**: Copied sensitive data remains in clipboard
4. **Root detection**: Currently no warning for rooted/jailbroken devices
