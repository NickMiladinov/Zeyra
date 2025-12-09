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

### 3. Subscription
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| userId | String | |
| plan | String | Free / Premium |
| status | Enum | Active / Canceled / Trial / Expired |
| platform | Enum | Google / Apple |
| purchaseToken | String | |
| renewalDate | DateTime | |
| lastVerified | DateTime | |
| createdAt | DateTime | |

**Use Cases:**
- Fetch subscription status  
- Manage renewal and cancellation  

**Relationships:**
- Belongs to `UserProfile`

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

### 12. KickCounterEntry
| Field | Type | Description |
|--------|------|-------------|
| id | String | |
| pregnancyId | String | |
| count | int | |
| startTime | DateTime | |
| endTime | DateTime | |
| durationMinutes | int | |
| createdAt | DateTime | |

**Use Cases:**
- Log baby kick sessions  
- Display kick pattern analytics  

**Relationships:**
- Belongs to `Pregnancy`

---

### 13. ContractionTimerEntry
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

### 14. BirthPlan
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

### 15. ShoppingListItem
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

### 16. BumpPhoto
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

### 17. AskMyMidwifeNote
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

### 18. AIChatMessage
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

### 19. Notification
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
UserProfile ─── Subscription
UserProfile ───< Notification
UserProfile ─── Database file (`zeyra_<authId>.db`)
UserProfile ─── Encryption key (`zeyra_key_<authId>`)
Pregnancy ───< Hospital
UserProfile ───< Hospital
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
