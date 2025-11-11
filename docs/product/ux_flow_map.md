# UX Flow Map

## 🧭 Global Navigation
Bottom Tabs:
1. **Today**
2. **My Health**
3. **Baby**
4. **Tools**
5. **More**

Each tab maintains its own navigation state.  
Global FAB buttons and context-aware actions appear per screen.

---

## 🏁 Onboarding Flow
1. Splash Screen → “Let’s Get Started”
2. Choose Auth (Google, Apple, Email)
3. Collect optional data (due date, DOB, gender, postcode)
4. App walkthrough (main features and benefits)
5. User goals, personal questions (add symptoms), reminders/notifications
6. Premium subscription offer
7. Create empty local DB → Redirect to “Today” tab (tooltips)

---

## 🩺 My Health Flow
1. Home → My Health
2. Add Symptom → Choose Type → Choose Severity → Save to Drift DB
3. Upload file (PDF, scan) → Extract Biomarkers → Confirm Values → Store locally, encrypted
4. Biomarker list → View history/trends + reference ranges
5. Share → Choose what to share → Choose method → Export with selected data

---

## 🧒 Baby Flow
1. Home → Baby tab
2. Scroll through pregnancy weeks
3. View baby size, 3D model, and NHS article for each week
4. Key biomarkers for the baby, suggest prenatal tests, show baby related results

---

## 🏥 Hospital Finder Flow
1. First time → “Let’s Get Started” → Enter postcode → Workspace → Map View
2. Map View ↔ List View (FAB toggle) → Workspace (press back button)
3. Tap hospital → Bottom modal with rating + facilities → Full screen view with more hospital details
4. Add to shortlist → Workspace
5. From Workspace → “Explore More Hospitals” CTA → Back to Map

---

## 🧠 AI Chat Flow
1. Open “Ask My Midwife” (AI Chat)
2. Query example: “Is my hemoglobin level normal?”
3. Local AI reads user’s biomarker data and pregnancy week
4. Returns contextualized response  
5. (Future) Sync with cloud model for deeper explanations
