# Greffe_Mobile

This project is consumed by the backend deployment in:
`../Greffe Renale`.

## Production APK Workflow

The production server serves `prebuilt/app-release.apk` via
`Dockerfile.prebuilt` (no server-side Flutter build).

Update flow:

```bash
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk prebuilt/app-release.apk
git add prebuilt/app-release.apk
git commit -m "Update prebuilt APK"
git push
```
