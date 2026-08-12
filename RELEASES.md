# Android APK releases

Android releases are deployment artifacts, not frontend build inputs or Docker
images. Publish only non-debuggable, signed release APKs after verifying the
certificate chain documented in `client/ANDROID_BUILD.md`.

Each release is immutable and versioned:

```text
https://queenchat.ru/downloads/queenchat-<versionName>.apk
```

The legacy `https://queenchat.ru/downloads/queenchat.apk` remains available for
existing links but is not changed automatically by the updater workflow.

From the build machine, upload the already verified release APK to a temporary
location on the VPS. Then publish it atomically:

```bash
./scripts/publish_android_release.sh /path/to/app-release.apk 2 1.1.0 1 false changelog.txt
```

The command copies the APK once into `releases/`, computes its SHA-256 and
size, and atomically writes `android_release.json`. It refuses to replace an
existing versioned artifact.

When the identical versioned APK was uploaded in advance, use the strict
metadata-only mode instead:

```bash
./scripts/publish_android_release.sh --metadata-only \
  /opt/projects/queen-chat/releases/queenchat-1.1.0.apk \
  2 1.1.0 1 false changelog.txt
```

This mode requires the destination artifact to already exist and compares both
its SHA-256 and byte size with the supplied APK before atomically replacing
metadata. It never overwrites the APK.

Verify live delivery after publication:

```bash
curl -fsS https://queenchat.ru/api/app/android/version | jq .
curl -fsSI https://queenchat.ru/downloads/queenchat-1.1.0.apk
curl -fsS https://queenchat.ru/downloads/queenchat-1.1.0.apk | sha256sum
```
