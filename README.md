# FitTracker

FitTracker is a Flutter health-tracking app prepared for Android and Flutter Web.

## Web and Firebase setup

This codebase is configured to use the existing Firebase project `fittracker-e3411`.

### Run locally on the web

```bash
flutter pub get
flutter run -d chrome
```

### Build a release web bundle

```bash
flutter build web --release
```

The release files are generated in `build/web`.

### Deploy to Firebase Hosting

Install the Firebase CLI, sign in, and deploy:

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only hosting
```

The project already includes `.firebaserc` and `firebase.json` for static hosting from `build/web`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
