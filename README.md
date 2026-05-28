# Greffe_Mobile

This project is consumed by the backend deployment in:
`../Greffe Renale`.

## Guide Utilisateur (APK Android)

Reference utilisateur pour l'application mobile.

- Page de telechargement: https://std27.beaupeyrat.com/mobile/
- Lien direct APK: https://std27.beaupeyrat.com/mobile/greffe-renale.apk
- Serveur API par defaut dans l'app: https://std27.beaupeyrat.com

Installation:

1. Ouvrir la page de telechargement
2. Appuyer sur "Telecharger l'APK"
3. Ouvrir le fichier telecharge
4. Autoriser l'installation depuis cette source si necessaire

## Documentation Developpeur

### Production APK Workflow

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
