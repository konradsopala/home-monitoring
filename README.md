# Home Monitoring

![](/Assets/HomeMonitoring.png)

Home Monitoring now ships with a JavaScript web app that exposes the same mock dashboard and API behavior that previously lived in Flask. The original SwiftUI iOS prototype is still preserved in this repository under `home-monitoring/`.

## JavaScript App

The JavaScript rewrite lives in `javascript_app/` and uses:

- Node.js 20+
- Express
- EJS templates
- Node's built-in test runner with Supertest

### Run Locally

```bash
cd javascript_app
npm install
npm start
```

The app listens on `http://localhost:3000` by default. Set `PORT` to override it.

### Available Routes

- `GET /` renders the dashboard with temperature and pressure readings
- `GET /api/sensor-data` returns the mock sensor readings as JSON
- `GET /api/connection-state` returns the mock connection state
- `POST /api/parse` remaps `temp` and `pres` payload keys into the app's JSON shape

### Test And Format

```bash
cd javascript_app
npm test
npm run format
```

## Legacy iOS Prototype

The original native app remains available for reference:

- Open `home-monitoring.xcodeproj` in Xcode 15+
- Set the beacon identifier in `home-monitoring/BeaconManager.swift`
- Set the Estimote Cloud credentials in `home-monitoring/AppDelegate.swift`

### Swift Stack

- Swift 6.0
- SwiftUI
- Estimote iOS SDK

### Screenshots

![](/Assets/AppScreens.png)

### Icons

Icons visible on the screen were made by **Smashicons** from www.flaticon.com.
