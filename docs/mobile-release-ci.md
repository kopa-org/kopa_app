# Mobile release CI

The repository now contains two deliberately manual-only workflows:

- `.github/workflows/ios-testflight.yml` builds and uploads iOS to TestFlight.
- `.github/workflows/android-release.yml` builds a signed Android App Bundle
  and stores it as a GitHub Actions artifact. It does not publish to Google
  Play yet.

Neither workflow runs on pushes or pull requests. Both default to `disabled`
when started manually. The iOS workflow also uses the protected `testflight`
environment, and the Android workflow uses `play-store`.

## Kopa values

| Item | Value |
| --- | --- |
| iOS bundle ID | `dk.kopa.app` |
| Android application ID | `dk.kopa.app` |
| Minimum iOS version | `15.0` |
| Release env file | `.env.deploy` |
| Local/test env file | `.env.local` |

The two environment files are Flutter assets and are ignored by Git. Store
their complete contents in GitHub Environment secrets rather than committing
them.

## GitHub setup

Create these environments under **Repository Settings → Environments**:

### `testflight`

Recommended variables:

```text
APPSTORE_ISSUER_ID
APPSTORE_API_KEY_ID
```

Required secrets:

```text
APPSTORE_API_PRIVATE_KEY
APPSTORE_CERTIFICATES_FILE_BASE64
APPSTORE_CERTIFICATES_PASSWORD
KOPA_ENV_LOCAL
KOPA_ENV_DEPLOY
```

`APPSTORE_API_PRIVATE_KEY` is the complete contents of Apple's
`AuthKey_<key-id>.p8`. `APPSTORE_CERTIFICATES_FILE_BASE64` is a base64-encoded
Apple Distribution `.p12` containing the private key.

### `play-store`

Required secrets for the signed AAB build:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
KOPA_ENV_LOCAL
KOPA_ENV_DEPLOY
```

The keystore secret must be the upload keystore that Google Play already
accepts for this app. Do not create a replacement keystore casually; losing the
correct upload key can prevent future uploads.

For the future Google Play upload step, also create this secret:

```text
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
```

It should contain the complete JSON key for a Google Cloud service account
that has been invited in Play Console with only the permissions needed to
upload releases. The current Android workflow intentionally does not consume
this secret yet.

## Preparing the secret values

On macOS, copy the keystore as one line of base64:

```bash
base64 -i android/upload-keystore.jks | pbcopy
```

On Linux:

```bash
base64 -w 0 android/upload-keystore.jks
```

Paste the result into `ANDROID_KEYSTORE_BASE64`. Never commit the keystore,
`key.properties`, service-account JSON, `.p8`, `.p12`, or either `.env` file.

## Apple signing prerequisite

The Xcode project must use the Apple Developer Team that owns `dk.kopa.app`.
The current project contains more than one `DEVELOPMENT_TEAM` value, so this
must be reconciled before the iOS workflow is enabled. For deterministic CI,
the Runner Release configuration should use the matching Apple Distribution
certificate and App Store provisioning profile. The downloaded profile should
match the bundle ID and the Release signing settings.

## Future Google Play upload

After the signed artifact has been validated manually, add an upload step using
the `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret and target the `internal` track
first. Publishing to production should remain a separate, explicitly approved
operation.
