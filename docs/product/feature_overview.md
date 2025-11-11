# Zeyra Feature Overview

This document defines all product features, their purpose, scope, and relationships across the app.

---

## 🧩 Core Features (MVP v1.0)

| Feature | Description | Key Screens | Connected To |
|----------|--------------|--------------|---------------|-----------|
| **Onboarding & Account** | OAuth login via Supabase. Collects minimal info and initializes local DB. | Onboarding Flow | User Profile |
| **Home Dashboard (Today Tab)** | Displays key health stats, pregnancy week, articles, appointments and actionable shortcuts. | Today Tab | Pregnancy, Biomarker, Logs | 
| **My Health** | Logs symptoms, uploads documents, views biomarkers, and tracks prenatal tests. | My Health Tab | Biomarker, File, TestTracker | 
| **Baby Timeline** | Week-by-week development with simple 3D model, info cards, tests/scans and important biomarkers for baby health. | Baby Tab | Pregnancy | 
| **Plan & Tools** | Central hub with interactive tools. | Tools Tab | Kick Counter, Contraction Timer, Hospital Chooser, AI Chat, Shopping List, Bump Photo, Birth Plan Builder, Appointment Hub | 
| **Hospital Chooser** | Map/list to explore NHS hospitals, shortlist favorites, view hospital profiles with their rating, facilities and contact info. | Map/List/Workspace | Hospital, User Profile |
| **Birth Plan Builder** | Interactive questionnaire that guides you through birth options and builds a birth plan at the end as a PDF/Word | Sample Question, Help Screen, Summary, Final Birth Plan | Pregnancy, Hospital, File |
| **Appointment Hub** | Add, delete and manage upcoming appointments. Suggests what questions to ask, possible upcoming appointments, notetaking | Calendar, List, Manage Appointment | Pregnancy, Hospital |
| **Shopping List** | Create, manage and track progress of multiple shopping checklists by category, each list with individual items. Shopping guides and articles for popular items that have many options | Checklist, Item, Guide | Pregnancy, User Profile |
| **AI Chat** | Contextual assistant that answers pregnancy questions using local data and NHS guidance. | AI Chat Tab | Biomarker, Logs, Pregnancy |
| **Sharing Tools** | Export data as PDF, QR, or Nearby Share. | Share Menu | User Profile, Pregnancy, Biomarkers and Symptoms |

---

## 🧱 Supporting Systems

| System | Description |
|--------|--------------|
| **Local Database (Drift)** | Stores all user, pregnancy, health, and file data locally and encrypted. |
| **Supabase Auth** | OAuth-based authentication (Apple, Google, Email) — returns `authId`. |
| **Supabase Database** | Stores minimal remote data (sync metadata, subscription, backup pointer). |
| **App Settings** | Stores preferences (theme, notifications, sync options, feature layouts). |
| **OCR Model** | Scans files and extracts their text |
| **AI Engine** | Local hybrid model that accesses only user-consented data. |

---

## 🌈 Future Additions

| Feature | Description |
|----------|--------------|
| **Partner Mode** | Linked partner account for shared viewing. |
| **Postnatal Features** | Breastfeeding, recovery, and newborn health modules. |
| **Cloud Sync (Premium)** | Secure encrypted cloud backup and multi-device access. |
| **NHS Record Integration** | Automatic syncing of blood tests, appointments, and scans. |
| **Clinician Dashboard** | View patient data shared via consent tokens. |
| **Wearable Integration** | Apple Health / Google Fit data import. |

---

## 🔗 Feature Relationship Map

```mermaid
graph TD
    A[User Profile] --> B[Pregnancy]
    B --> C[Biomarker]
    B --> D[Symptom Log]
    B --> E[Appointments]
    A --> F[Notification Settings]
    F -->|Reminders| E
    D -->|Insights| H[AI Chat]
    C -->|Data| H
    B -->|Timeline| I[Baby Tab]
    A -->|Preferences| J[App Settings]
    K[Hospital Chooser] --> L[Hospital Workspace]
