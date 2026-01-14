# CI/CD Pipeline Guide

This document explains the CI/CD pipeline setup for the ViaSwiss Flutter app.

## Overview

The ViaSwiss project uses GitHub Actions for continuous integration and deployment. The pipeline consists of three main workflows:

1. **CI (Continuous Integration)** - Validates code quality and builds
2. **Security Scan** - Checks for vulnerabilities and security issues
3. **Deploy Beta** - Automated deployment to app stores (template)

## Workflows

### 1. CI Workflow (`ci.yml`)

**Triggers**: Push to `main`/`develop` branches, Pull Requests

**Jobs**:

#### Code Analysis
- Verifies Dart code formatting
- Runs Flutter analyzer with strict mode (fatal warnings and infos)
- Checks for outdated dependencies

#### Unit & Widget Tests
- Runs complete test suite with coverage
- Uploads coverage to Codecov
- Generates coverage summary report
- Requires >0% coverage to pass

#### Build Android APK
- Builds debug APK to verify Android compatibility
- Uses Java 17 and Flutter 3.24.0
- Uploads APK artifact (7-day retention)

#### Build iOS App
- Builds iOS app for simulator (no codesigning required)
- Tests on iPhone 15 simulator
- Validates iOS compatibility

#### Code Generation Check
- Runs `build_runner` to regenerate code
- Fails if generated files are out of sync
- Ensures Freezed and JSON serialization are up-to-date

**Status**: All jobs must pass for PR merge

---

### 2. Security Scan Workflow (`security.yml`)

**Triggers**:
- Push to `main`/`develop` branches
- Pull Requests
- Weekly schedule (Monday 00:00 UTC)
- Manual dispatch

**Jobs**:

#### Dependency Vulnerability Scan
- Uses `dart pub audit` to check for known vulnerabilities
- Analyzes dependency tree
- Reports vulnerable packages

#### License Compliance Check
- Generates dependency tree
- Lists all package licenses
- Helps identify license compatibility issues

#### Code Security Analysis
- Runs security-focused static analysis
- Scans for hardcoded secrets (API keys, passwords)
- Checks for unsafe code patterns
- Detects potential security vulnerabilities

**Status**: Informational (doesn't block PRs by default)

---

### 3. Deploy Beta Workflow (`deploy-beta.yml`)

**Triggers**:
- Push to `main` branch
- Manual dispatch with version bump selection

**Jobs**:

#### Version Management
- Auto-calculates version from git tags
- Generates build number from commit count
- Supports manual version bumping (major/minor/patch)

#### Deploy Android Beta
- Builds release AAB (Android App Bundle)
- Uploads artifact (30-day retention)
- **Ready for**: Play Console Internal Testing deployment
- **Requires**: Signing keys configuration (see setup below)

#### Deploy iOS Beta
- Builds release IPA
- Uploads artifact (30-day retention)
- **Ready for**: TestFlight deployment
- **Requires**: Signing certificates configuration (see setup below)

#### Deployment Notification
- Creates deployment summary
- Reports status of all jobs

**Status**: Currently builds artifacts only (actual store deployment disabled until configured)

---

## Setup Instructions

### Prerequisites

- GitHub repository with Actions enabled
- Flutter project structure in place
- Admin access to repository settings

### Basic Setup (Already Done ✅)

The following is already configured and working:

- ✅ GitHub Actions workflows created
- ✅ CI pipeline for code quality and tests
- ✅ Security scanning enabled
- ✅ Build validation for Android and iOS
- ✅ Workflow status badges in README

### Advanced Setup (Optional)

To enable actual app store deployments:

#### Android Deployment Setup

1. **Generate Release Keystore**:
   ```bash
   keytool -genkey -v -keystore release.keystore -alias viaswiss -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **Encode Keystore to Base64**:
   ```bash
   base64 release.keystore > keystore.b64
   ```

3. **Add GitHub Secrets**:
   - `ANDROID_KEYSTORE_BASE64`: Content of keystore.b64
   - `ANDROID_KEYSTORE_PASSWORD`: Keystore password
   - `ANDROID_KEY_ALIAS`: Key alias (e.g., "viaswiss")
   - `ANDROID_KEY_PASSWORD`: Key password
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Service account JSON for Play Console API

4. **Configure Play Console**:
   - Create app in Google Play Console
   - Set up internal testing track
   - Generate service account with API access
   - Download service account JSON

5. **Update Bundle ID**:
   - Ensure `applicationId` in `android/app/build.gradle` matches Play Console

6. **Uncomment Deployment Steps**:
   - Edit `.github/workflows/deploy-beta.yml`
   - Uncomment keystore configuration and Play Console upload sections

#### iOS Deployment Setup

1. **Generate Distribution Certificate**:
   - Use Xcode or Apple Developer portal
   - Export as .p12 file with password

2. **Create Provisioning Profile**:
   - Create App ID in Apple Developer portal
   - Generate provisioning profile for distribution
   - Download as .mobileprovision

3. **Encode to Base64**:
   ```bash
   base64 certificate.p12 > cert.b64
   base64 profile.mobileprovision > profile.b64
   ```

4. **Add GitHub Secrets**:
   - `IOS_CERTIFICATE_P12_BASE64`: Content of cert.b64
   - `IOS_CERTIFICATE_PASSWORD`: Certificate password
   - `IOS_PROVISIONING_PROFILE_BASE64`: Content of profile.b64
   - `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API Key ID
   - `APP_STORE_CONNECT_ISSUER_ID`: Issuer ID
   - `APP_STORE_CONNECT_API_KEY_BASE64`: Base64 encoded API key

5. **Configure App Store Connect**:
   - Create app in App Store Connect
   - Set up TestFlight
   - Generate API key with appropriate permissions

6. **Update Bundle ID**:
   - Ensure bundle identifier matches in Xcode and App Store Connect

7. **Uncomment Deployment Steps**:
   - Edit `.github/workflows/deploy-beta.yml`
   - Uncomment codesigning and TestFlight upload sections

#### Fastlane Setup (Recommended)

For more robust deployment automation:

1. **Install Fastlane**:
   ```bash
   sudo gem install fastlane
   ```

2. **Initialize Fastlane**:
   ```bash
   cd viaswiss_app/android
   fastlane init

   cd ../ios
   fastlane init
   ```

3. **Configure Lanes**:
   - Create lanes for beta deployment
   - Set up match for iOS code signing
   - Configure supply for Play Console upload

4. **Update Workflows**:
   - Replace manual deployment steps with Fastlane commands
   - Simplifies credential management

---

## Monitoring and Maintenance

### Viewing Workflow Runs

1. Go to repository → Actions tab
2. Select workflow (CI, Security Scan, Deploy Beta)
3. View run history and logs

### Status Badges

Status badges in README show current build status:
- Green: All checks passing
- Red: Build failed
- Yellow: In progress

### Managing Secrets

1. Repository Settings → Secrets and variables → Actions
2. Add/update secrets as needed
3. Never commit secrets to repository

### Workflow Permissions

The workflows require:
- Read access to repository
- Write access for artifacts
- Write access for deployments (if enabled)

Configure in: Settings → Actions → General → Workflow permissions

---

## Best Practices

### Code Quality

1. **Always run tests locally before pushing**:
   ```bash
   flutter test
   ```

2. **Format code before committing**:
   ```bash
   dart format lib test
   ```

3. **Run analyzer**:
   ```bash
   flutter analyze
   ```

4. **Keep generated code in sync**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Pull Requests

1. Wait for all CI checks to pass
2. Review code coverage report
3. Address any security warnings
4. Ensure builds succeed for both platforms

### Versioning

1. Use semantic versioning (MAJOR.MINOR.PATCH)
2. Tag releases in git:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. Version is auto-calculated from tags

### Security

1. Never hardcode API keys or secrets
2. Use environment variables or Dart defines
3. Review security scan results weekly
4. Update dependencies regularly

---

## Troubleshooting

### CI Failures

**Tests failing**:
- Run `flutter test` locally to reproduce
- Check test output in workflow logs
- Ensure dependencies are up-to-date

**Build failures**:
- Verify Flutter version matches workflow (3.24.0)
- Check for platform-specific issues
- Review build logs for specific errors

**Code generation out of sync**:
- Run `dart run build_runner build --delete-conflicting-outputs`
- Commit generated files
- Push changes

### Security Scan Warnings

**Vulnerable dependencies**:
- Run `flutter pub upgrade` to update
- Check package changelog for breaking changes
- Test thoroughly after updates

**Hardcoded secrets detected**:
- Move secrets to environment variables
- Use `--dart-define` or `.env` files
- Never commit credentials

### Deployment Issues

**Android signing fails**:
- Verify keystore password in secrets
- Check key alias matches
- Ensure keystore file is valid base64

**iOS codesigning fails**:
- Verify certificate and profile are valid
- Check expiration dates
- Ensure bundle ID matches provisioning profile

**Store upload fails**:
- Verify API credentials
- Check app version is newer than previous
- Ensure app meets store requirements

---

## Customization

### Modifying Workflows

To customize workflows:

1. Edit `.github/workflows/*.yml`
2. Test changes on a branch first
3. Common modifications:
   - Add new build flavors
   - Change Flutter version
   - Add integration tests
   - Configure different environments

### Adding New Jobs

To add new CI jobs:

1. Add job definition to `ci.yml`
2. Define dependencies with `needs:`
3. Use `defaults.run.working-directory` for Flutter projects
4. Upload artifacts if needed

### Environment Variables

Set environment variables in workflow:
```yaml
env:
  GRAPHQL_ENDPOINT: https://your-backend.com/graphql
  MAPTILER_API_KEY: ${{ secrets.MAPTILER_API_KEY }}
```

---

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Fastlane for Flutter](https://docs.fastlane.tools/)
- [Google Play Publishing](https://support.google.com/googleplay/android-developer/answer/9859152)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

---

## Support

For issues with the CI/CD pipeline:
1. Check workflow logs in Actions tab
2. Review this guide for configuration steps
3. Open an issue in the repository
4. Tag with `ci-cd` label

---

**Last Updated**: January 2026
**Pipeline Version**: 1.0.0
