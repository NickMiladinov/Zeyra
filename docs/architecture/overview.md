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

## 🔐 Data Encryption & Security

### Overview
Zeyra prioritizes user privacy and compliance with **UK GDPR** by keeping all sensitive data **on-device** and encrypting it at rest and in transit.
Encryption is handled using **AES-256-GCM** via the `cryptography` and `cryptography_flutter` packages.

### Implementation

1. **Encryption at Rest**
   - All sensitive user data (e.g., personal info, biomarker data, medical files) stored locally via **Drift** is encrypted using **AES-256-GCM**.
   - **AES-GCM provides**:
     - **Confidentiality**: Data is encrypted and unreadable without the key
     - **Authentication**: Built-in authentication tag detects tampering
     - **Performance**: Hardware acceleration via platform-native APIs (Android Keystore / iOS CryptoKit)
   - Encryption keys are stored securely using **flutter_secure_storage**, which relies on:
     - **Android Keystore System**
     - **iOS Keychain**

2. **Encryption in Transit**
   - When data is shared externally (e.g., clinician data exports, QR/Nearby Share), files are encrypted before being transmitted.
   - The app ensures temporary decrypted copies are cleared from device memory immediately after use.

3. **Key Management**
   - 256-bit keys are generated per user device using cryptographically secure random generation
   - Keys never leave the device's secure storage
   - Cloud sync (when added in premium version) will never upload raw keys
   - Supabase auth only handles authentication; no raw health or biometric data is stored remotely in v1.0

4. **Encryption Service**
   - Implemented in `lib/core/services/encryption_service.dart`
   - Uses `AesGcm.with256bits()` algorithm from the `cryptography` package
   - Each encryption uses a random 12-byte nonce for security
   - Output format: `[12-byte nonce][ciphertext][16-byte auth tag]` (base64 encoded)
   - Tamper detection: Any modification to encrypted data will cause decryption to fail

5. **Future-proofing**
   - The encryption layer is abstracted through the `EncryptionService` class
   - Repositories use the service via dependency injection
   - In future updates (e.g., for FIPS 140-2 compliance), the crypto backend can be replaced without affecting repositories or entities

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
