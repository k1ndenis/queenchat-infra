# Android APK releases

Android releases are deployment artifacts, not frontend build inputs or Docker
images. Publish only non-debuggable, signed release APKs after verifying the
certificate chain documented in `client/ANDROID_BUILD.md`.

Every release is published under one stable URL:

```text
https://queenchat.ru/downloads/queenchat.apk
```

The filename never carries `versionName`; Android update ordering is based only
on the monotonically increasing `versionCode` in the signed APK and metadata.

From the build machine, upload the already verified release APK to a temporary
location on the VPS. Then publish it atomically:

```bash
./scripts/publish_android_release.sh /path/to/app-release.apk 2 1.1.0 1 false changelog.txt
```

The command performs basic APK archive validation, calculates SHA-256 and size,
atomically replaces `releases/queenchat.apk`, then atomically writes
`android_release.json`. It publishes the APK first, so metadata can never
advertise a new digest while the public URL still serves the prior APK.

Verify live delivery after publication:

```bash
curl -fsS https://queenchat.ru/api/app/android/version | jq .
curl -fsSI https://queenchat.ru/downloads/queenchat.apk
curl -fsS https://queenchat.ru/downloads/queenchat.apk | sha256sum
```
