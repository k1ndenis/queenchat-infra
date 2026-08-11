# Android APK release

The public APK is deployment-only and is not part of the frontend build or Docker image.
It is served at `https://queenchat.ru/downloads/queenchat.apk` from
`/opt/projects/queen-chat/releases/queenchat.apk` through Caddy's read-only volume.

From the build machine, upload a newly built APK:

```bash
scp -i ~/.ssh/deploy android/app/build/outputs/apk/debug/app-debug.apk deploy@192.124.189.26:/tmp/queenchat.apk
```

On the VPS, atomically publish it and verify it:

```bash
install -m 0644 -o deploy -g deploy /tmp/queenchat.apk /opt/projects/queen-chat/releases/queenchat.apk.new && mv /opt/projects/queen-chat/releases/queenchat.apk.new /opt/projects/queen-chat/releases/queenchat.apk
sha256sum /opt/projects/queen-chat/releases/queenchat.apk
curl -fsSI https://queenchat.ru/downloads/queenchat.apk
```
