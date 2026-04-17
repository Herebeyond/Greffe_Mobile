# ── Stage 1: Build Flutter APK ─────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency files first for better Docker layer caching
COPY pubspec.yaml pubspec.lock ./

# Fetch Flutter dependencies
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# API base URL injected at build time (default: PC hotspot IP)
ARG API_BASE_URL=https://192.168.137.1

# Build the release APK (with self-signed cert bypass for dev server)
RUN flutter build apk --release \
    --dart-define=API_BASE_URL=${API_BASE_URL} \
    --dart-define=ALLOW_SELF_SIGNED=true

# ── Stage 2: Serve APK download page via nginx ────────────────────
FROM nginx:alpine

COPY --from=build /app/build/app/outputs/flutter-apk/app-release.apk /usr/share/nginx/html/greffe-renale.apk
COPY download.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
