# Data & Domain Architecture

## Overview

This document defines the **core data schema**, **entities**, **relationships**, and **use cases** for the app.  
It represents **domain-level entities** (used across logic, repositories, and UI), while the **database (Drift)** layer will define equivalent **DB entities** optimized for local storage.

---

## 🧭 Domain vs. Database Entities

| Type | Description | Example |
|------|--------------|----------|
| **Domain Entity** | Pure Dart class used in business logic, UI, and repositories. Framework-agnostic. | `Biomarker`, `UserProfile` |
| **DB Entity** | Drift table or data transfer object (DTO). Handles local persistence, sync metadata, and encryption. | `BiomarkerTable`, `BiomarkerDto` |

**Repositories** act as the bridge between the two — converting from `DB Entity` ↔ `Domain Entity`.

For example:
```
BiomarkerRepositoryImpl → BiomarkerDao ↔ BiomarkerTable ↔ Biomarker (Domain)
```

---

## 📁 Structure Overview

- **Entities** = Core data models (domain layer)
- **Repositories** = Interface between domain and data (Drift, Supabase later)
- **Use Cases** = Logical actions performed on data (business logic)
- **Relationships** = Logical and/or database-level connections between entities

---

## 🧍 User Entities

### 1. UserProfile
| Field | Type | Description |
|--------|------|-------------|
| id | String (UUID) | Local record ID |
| authId | String | Supabase Auth user ID |
| email | String | User's email |
| firstName | String | User's first name |
| lastName | String | User's last name |
| dateOfBirth | DateTime | Date of birth |
| gender | Enum | Used for personalization |
| createdAt | DateTime | |
| updatedAt | DateTime | |
| isSynced | Boolean | Cloud sync status |
| databasePath | String | Path to user's database file (`zeyra_<authId>.db`) |
| encryptionKeyId | String | Secure storage key ID (`zeyra_key_<authId>`) |
| lastAccessedAt | DateTime | Last session timestamp |
| schemaVersion | int | Database schema version for migrations |

**Use Cases:**
- Get current user profile
- Update user information
- Sync with Supabase auth user
- Manage per-user database isolation
- Track database schema version for migrations

**Relationships:**
- One `UserProfile` → Many `Pregnancy`
- One `UserProfile` → One `UserSettings`
- One `UserProfile` → One `Subscription`
- One `UserProfile` → One `SessionState`
- One `UserProfile` → One Database file → One Encryption key

---

### 2. UserSettings
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| userId | String | FK to UserProfile |
| darkMode | Boolean | |
| notificationsEnabled | Boolean | |
| language | String | |
| createdAt | DateTime | |
| inactivityTimeoutMinutes | int | Minutes before auto-lock (1/5/15/30), default 5 |
| biometricsEnabled | Boolean | Whether biometrics are enabled for unlock (default: true if available) |
| backgroundLockEnabled | Boolean | Lock when app backgrounded (default: true) |

**Use Cases:**
- Toggle theme and preferences
- Manage notification and privacy settings
- Configure session security (auto-lock timeout, biometrics)

**Relationships:**
- Belongs to `UserProfile`

---

### 3. Subscription (Managed by RevenueCat)

**IMPORTANT**: Subscription status is NOT stored locally. RevenueCat SDK manages all subscription state.

Use `PaymentService.hasZeyraEntitlement()` to check subscription status. Do not create local Subscription entities.

**RevenueCat Configuration:**
- Entitlement ID: `Zeyra`
- Product IDs: `monthly`, `yearly`

**RevenueCat CustomerInfo provides:**
- Active entitlements (Zeyra access)
- Expiration dates
- Purchase history
- Platform (iOS/Android)

**Key Methods** (`PaymentService`):
- `hasZeyraEntitlement()` → Check if user has active Zeyra entitlement
- `purchase(Package)` → Initiate purchase flow
- `restore()` → Restore purchases for returning users
- `linkToAuthUser(authId)` → Link RevenueCat customer to Supabase user
- `presentPaywall()` → Present RevenueCat paywall UI
- `presentPaywallIfNeeded()` → Present paywall only if user lacks entitlement
- `presentCustomerCenter()` → Present subscription management UI

**Relationships:**
- Linked to `UserProfile` via RevenueCat's app user ID (set to Supabase authId)

---

### 3b. OnboardingData (Temporary - SharedPreferences)

Temporary entity stored in SharedPreferences during onboarding. After successful authentication, data is migrated to `UserProfile` and `Pregnancy` entities, then cleared.

| Field | Type | Description |
|--------|------|-------------|
| firstName | String? | User's first name |
| dueDate | DateTime? | Expected due date (calculated if LMP provided) |
| startDate | DateTime? | LMP date (calculated if dueDate provided) |
| dateOfBirth | DateTime? | User's birth date |
| notificationsEnabled | bool | Notification permission granted |
| purchaseCompleted | bool | RevenueCat purchase successful |
| currentStep | int | Current onboarding screen index (0-10) |

**Computed Properties:**
- `gestationalWeek`: Current week based on startDate
- `gestationalDaysInWeek`: Days within current week (0-6)
- `gestationalAgeFormatted`: Formatted string (e.g., "24w 3d")
- `isComplete`: Whether all required data is present

**Use Cases:**
- Track onboarding progress across app restarts
- Store user input before authentication
- Calculate due date from LMP (or vice versa) using 280-day rule

**Lifecycle:**
1. Created when user starts onboarding
2. Updated as user progresses through screens
3. Persisted to SharedPreferences for durability
4. Used to create `UserProfile` and `Pregnancy` after auth
5. Cleared after successful finalization

**Note:** Not a database entity - stored only in SharedPreferences.

---

### 4. SessionState
| Field | Type | Description |
|--------|------|-------------|
| id | String | Primary key |
| userId | String | FK to UserProfile |
| state | Enum | locked / requiresLogin / requiresLocalAuth / active |
| lastStateChange | DateTime | When state last changed |
| failedAuthAttempts | int | Counter for biometric failures (resets on success) |
| lockedAt | DateTime? | When session was locked (null if active) |

**State Definitions:**
- `locked` — Initial/undefined state, no active session
- `requiresLogin` — Need full Supabase authentication (no valid token)
- `requiresLocalAuth` — Need biometric/PIN authentication (valid token exists)
- `active` — Session active, database unlocked, user can access data

**Use Cases:**
- Track current session state for security enforcement
- Manage lock/unlock lifecycle
- Count failed biometric attempts for fallback to password
- Audit session activity timestamps

**Relationships:**
- Belongs to `UserProfile`

---

## 🤰 Pregnancy Entities

### 5. Pregnancy
| Field | Type | Description |
|--------|------|-------------|
| id | String | Primary key |
| userId | String | FK |
| startDate | DateTime | LMP/conception date |
| dueDate | DateTime | Expected due date |
| selectedHospitalId | String? | Selected hospital ID |
| createdAt | DateTime | |
| updatedAt | DateTime | |

**Use Cases:**
- Create and manage multiple pregnancies  
- Calculate gestational week and timeline  
- Fetch pregnancy-related data across features  

**Relationships:**
- One `Pregnancy` → Many (`SymptomLog`, `Biomarker`, `Appointment`, `FileAttachment`, `BirthPlan`, `KickCounterEntry`, etc.)
- Belongs to `UserProfile`

---

## 💉 Health & Tracking Entities

### 6. SymptomLog
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| symptomName | String | e.g. nausea, swelling |
| severity | int | 1–5 |
| notes | String? | User notes |
| date | DateTime | |
| createdAt | DateTime | |

**Use Cases:**
- Add/edit daily symptoms  
- Generate symptom trend insights  

**Relationships:**
- Belongs to `Pregnancy`

---

### 7. Biomarker
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| name | String | e.g. Hemoglobin |
| unit | String | |
| value | Double? | Measured value |
| referenceMin | Double? | Lower normal |
| referenceMax | Double? | Upper normal |
| category | Enum | e.g. Blood, Urine |
| source | Enum | e.g. Manual, Device |
| recordedAt | DateTime | |
| notes | String? | |
| isFlagged | Boolean | Derived field |
| isSynced | Boolean | |
| createdAt | DateTime | |
| updatedAt | DateTime | |

**Use Cases:**
- Track biomarkers (BP, glucose, etc.)  
- Flag out-of-range values  
- Visualize health trends  
- Sync lab results  

**Relationships:**
- Belongs to `Pregnancy`

---

### 8. TestResult
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| testType | String | e.g. Blood test, Ultrasound |
| labName | String? | |
| date | DateTime | |
| fileId | String? | |
| notes | String? | |
| isSynced | Boolean | |
| createdAt | DateTime | |
| updatedAt | DateTime | |

**Use Cases:**
- Store prenatal test results  
- OCR and parse uploaded reports  
- Link to biomarker data  

**Relationships:**
- Belongs to `Pregnancy`
- May reference a `FileAttachment`

---

### 9. FileAttachment
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| name | String | File name |
| filePath | String | Local path |
| type | String | |
| date | DateTime | |
| tags | List<String>? | |
| createdAt | DateTime | |

**Use Cases:**
- Attach ultrasound scans, lab PDFs, etc.  
- Secure local storage with optional encryption  

**Relationships:**
- Belongs to `Pregnancy`
- Referenced by `TestResult`

---

## 🏥 Hospital Entities

### 10. Hospital
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| name | String | |
| address | String | |
| cqcRating | String? | |
| website | String? | |
| contactNumber | String? | |
| shortlisted | Boolean | |
| createdAt | DateTime | |

**Use Cases:**
- Browse and search NHS hospitals  
- Link to CQC data  
- Display details in hospital chooser  
- Save favorite hospitals for later selection  

**Relationships:**
- Referenced by `Pregnancy`

---

## 📆 Planning & Tools Entities

### 11. Appointment
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| title | String | |
| date | DateTime | |
| location | String? | |
| notes | String? | |
| status | Enum | Upcoming / Completed / Canceled |
| createdAt | DateTime | |

**Use Cases:**
- Add/manage prenatal appointments  
- Generate reminders  

**Relationships:**
- Belongs to `Pregnancy`

---

### 12. KickSession (Kick Counter)
| Field | Type | Description |
|--------|------|-------------|
| id | String | UUID |
| startTime | DateTime | When session started |
| endTime | DateTime? | When session ended (null if active) |
| isActive | Boolean | Whether session is currently active |
| pausedAt | DateTime? | When session was paused (null if not paused) |
| totalPausedDuration | Duration | Accumulated pause time |
| pauseCount | int | Number of times session was paused |
| note | String? | Optional session note |
| createdAt | DateTime | Record creation timestamp |
| updatedAt | DateTime | Last update timestamp |

**Computed Properties:**
- `isPaused`: Whether session is currently paused
- `kickCount`: Number of kicks recorded
- `activeDuration`: Active monitoring time (excludes pauses)
- `averageTimeBetweenKicks`: Average interval between kicks
- `durationToTenthKick`: Time to reach 10 kicks (excluding pauses before 10th kick)

**Use Cases:**
- Start/stop kick counting sessions
- Pause/resume monitoring
- Track fetal movement patterns
- Calculate time to 10 kicks for medical assessment

**Relationships:**
- One `KickSession` → Many `Kick`
- One `KickSession` → Many `PauseEvent`
- **Future:** Will belong to `Pregnancy` (pregnancyId FK to be added)

---

### 13. Kick
| Field | Type | Description |
|--------|------|-------------|
| id | String | UUID |
| sessionId | String | FK to KickSession |
| timestamp | DateTime | When kick was recorded |
| sequenceNumber | int | Sequential number within session (1-indexed) |
| perceivedStrength | MovementStrength | Enum: weak, moderate, strong |

**Use Cases:**
- Record individual fetal movements
- Track movement strength patterns
- Support "undo last kick" functionality

**Relationships:**
- Belongs to `KickSession`

---

### 14. PauseEvent
| Field | Type | Description |
|--------|------|-------------|
| id | String | UUID |
| sessionId | String | FK to KickSession |
| pausedAt | DateTime | When pause started |
| resumedAt | DateTime? | When pause ended (null if still paused) |
| kickCountAtPause | int | Number of kicks recorded before this pause |
| createdAt | DateTime | Record creation timestamp |
| updatedAt | DateTime | Last update timestamp |

**Computed Properties:**
- `duration`: Length of this pause
- `isBeforeTenthKick`: Whether pause occurred before 10th kick

**Use Cases:**
- Track session interruptions
- Calculate accurate active monitoring time
- Exclude pre-10th-kick pauses from time-to-10 calculation

**Relationships:**
- Belongs to `KickSession`

---

### 15. MovementStrength (Enum)
- `weak`: Barely noticeable, subtle movements
- `moderate`: Clearly felt but not strong
- `strong`: Strong, vigorous movements

---

### 16. ContractionTimerEntry
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| startTime | DateTime | |
| endTime | DateTime | |
| durationSeconds | int | |
| intervalSeconds | int | |
| createdAt | DateTime | |

**Use Cases:**
- Time contractions  
- Calculate frequency and duration trends  

**Relationships:**
- Belongs to `Pregnancy`

---

### 17. BirthPlan
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| preferences | Map<String, dynamic> | e.g. pain relief, delivery position |
| notes | String? | |
| updatedAt | DateTime | |

**Use Cases:**
- Store birth preferences  
- Export to PDF or share with clinicians  

**Relationships:**
- Belongs to `Pregnancy`

---

### 18. ShoppingListItem
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| name | String | |
| category | String | e.g. Baby clothes |
| isChecked | Boolean | |
| createdAt | DateTime | |

**Use Cases:**
- Manage customizable shopping lists per pregnancy  

**Relationships:**
- Belongs to `Pregnancy`

---

### 19. BumpPhoto
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| filePath | String | |
| weekNumber | int | |
| date | DateTime | |
| notes | String? | |
| createdAt | DateTime | |

**Use Cases:**
- Track bump progress  
- Display in timeline/gallery view  

**Relationships:**
- Belongs to `Pregnancy`

---

## 🤖 AI & Assistant Entities

### 20. AskMyMidwifeNote
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| content | String | Free text note |
| createdAt | DateTime | |

**Use Cases:**
- Capture user notes and convert to AI questions  

**Relationships:**
- Belongs to `Pregnancy`

---

### 21. AIChatMessage
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| userId | String | |
| message | String | Chat text |
| sender | Enum | User / AI |
| timestamp | DateTime | |

**Use Cases:**
- Store chat history with AI assistant  
- Enable context-based responses  

**Relationships:**
- Belongs to `UserProfile`

---

## 🔔 Notifications

### 22. Notification
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| userId | String | |
| type | Enum | daily_update / appointment_reminder / test_result / system_alert |
| title | String | |
| body | String | |
| scheduledTime | DateTime? | |
| isRead | Boolean | |
| createdAt | DateTime | |

**Use Cases:**
- Manage in-app and push notifications  
- Categorize reminders (daily updates, appointments, test results, etc.)  

**Relationships:**
- Belongs to `UserProfile`

---

## 🔗 Relationships Map (simplified)
```
UserProfile ───< Pregnancy ───< (SymptomLog, Biomarker, Appointment, FileAttachment, BirthPlan, etc.)
UserProfile ─── SessionState
UserProfile ─── UserSettings
UserProfile ─── RevenueCat CustomerInfo (via authId, not stored locally)
UserProfile ───< Notification
UserProfile ─── Database file (`zeyra_<authId>.db`)
UserProfile ─── Encryption key (`zeyra_key_<authId>`)
Pregnancy ───< Hospital
UserProfile ───< Hospital
KickSession ───< Kick
KickSession ───< PauseEvent
(Future: Pregnancy ───< KickSession)

Onboarding Flow (temporary, pre-auth):
OnboardingData (SharedPreferences) → UserProfile + Pregnancy (after auth)
```


---

## 🧠 Notes for Future Expansion

**Planned Features (v2+):**
- Partner Mode → New entity `PartnerProfile`
- Postnatal → `BabyProfile`, `FeedingLog`, `RecoveryRecord`
- Cloud Sync → Add `isSynced`, `remoteId`, `syncTimestamp` to all entities
- Wearable Integration → `DeviceReading` entity linked to Biomarker/TestResult
- NHS Integration → `NHSRecordLink`, `NHSAppointment`

---

## ⚙️ Data Design Guidelines

- All **domain entities** are framework-agnostic
- Repositories implement conversion logic
- Encryption, sync metadata, and internal IDs belong only in DB layer
- Avoid direct Drift or API imports outside `/data/`
- Define foreign keys, indices, and relationships at DB level
- Use UTC timestamps for consistency
- Follow naming conventions:  
  - Domain: `Biomarker`, `UserProfile`  
  - DB: `BiomarkerTable`, `UserProfileTable`

---
