# 💸 Flutter Transactions App

A responsive mobile app built using **Flutter** to view and add financial transactions. Implements REST API integration, conditional styling, and clean UI structure similar to modern finance apps like **CRED** or **Jupiter**.

---

## 🔧 Tech Stack

- **Flutter** 3.22.x
- **Dart** 3.x
- **Provider** (State Management)
- **MockAPI.io** for REST API
- `intl` package for currency and date formatting

---

## 🚀 Features

- ✅ Fetch transactions from API (GET)
- ✅ Add new transaction (POST)
- ✅ Green for Credit, Red for Debit
- ✅ Currency & human-readable date formatting
- ✅ Modular folder and widget structure
- ✅ Retry on error with loading feedback
- ✅ Real-time UI update on transaction add

---

## 🧪 Setup Instructions

```bash
git clone https://github.com/anualienforce/transcation_api.git
cd flutter-transactions-task
flutter pub get
flutter run
```

---

## 🔗 API Endpoints (MockAPI.io)

- **GET:** `https://687b36a4b4bc7cfbda84fe9b.mockapi.io/transcation`
- **POST:** same endpoint (simulated DB)

---


## 🎥 Demo Walkthrough

Watch the full app walkthrough and explanation on Loom:  
📽️ [https://loom.com/share/your-loom-link](https://loom.com/share/your-loom-link)

---

## ✅ Known Issues

- Data doesn’t persist across sessions (Mock API limitation).
- Date filter UI not implemented yet.
- No pagination or infinite scroll.

---

## 📈 Future Improvements

- Add real backend (Firebase/Supabase).
- Add icons per transaction category.
- Implement date range filtering with calendar picker.
- Light/Dark theme toggle with animation.

---

## ⚠️ Challenges Faced

- MockAPI doesn’t persist POST data permanently.
- Needed to reformat UNIX timestamps to readable formats.
- State syncing between new POST item and existing list.

---

## 🏁 Final Notes

This app showcases:
- Clean UI inspired by fintech apps
- Smooth API integration
- Solid folder structure
- Commitment to production-grade quality

Made with ❤️ using Flutter.


