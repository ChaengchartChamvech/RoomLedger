# RoomLedger
<<<<<<< HEAD
Room Rental Mobile App Develop using Flutter
=======

Room rental starter app using Flutter (frontend) + Node.js/Express + MySQL (backend).

## Architecture

- Flutter app calls REST API (`/api/rooms`)
- Node API talks to MySQL
- MySQL stores room listings

## 1) Prepare MySQL

Run these scripts in your MySQL client:

- `backend/sql/schema.sql`
- `backend/sql/seed.sql`

## 2) Run Backend API

```bash
cd backend
cp .env.example .env
# edit .env with your database password and settings
npm install
npm run dev
```

API health check:

- `GET http://localhost:3000/health`

## 3) Run Flutter App

From project root:

```bash
flutter pub get
flutter run
```

Notes:

- App runs in mock mode by default (`USE_MOCK=true`).
- Android emulator uses `10.0.2.2` to reach host machine.
- iOS simulator can use `http://localhost:3000`.
- Physical device needs your computer LAN IP.

Run with backend instead of mock:

```bash
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Implemented endpoints

- `GET /api/rooms` list rooms
- `POST /api/rooms` create a room

POST body:

```json
{
  "title": "Studio near BTS",
  "location": "Bangkok - Ari",
  "monthly_price": 11000
}
```
>>>>>>> 847b0d9 (base files)
