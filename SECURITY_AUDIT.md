# Security & Vulnerability Audit Guide

## Overview
This document provides instructions for performing security audits on the Flutter Android project using industry-standard tools.

## OWASP Dependency-Check Integration

### Manual Scan (Recommended for 2026)
Since the OWASP plugin has compatibility issues with Flutter's Gradle setup, perform manual scans:

```bash
# Download OWASP Dependency-Check CLI (v12.x+)
# https://github.com/jeremylong/DependencyCheck/releases

# Run scan on Android dependencies
dependency-check.bat --project "StudentLifeManager" \
  --scan ./android \
  --format ALL \
  --failOnCVSS 7 \
  --enableExperimental

# Output: dependency-check-report.html
```

### Snyk Alternative
```bash
# Install Snyk CLI
npm install -g snyk

# Authenticate
snyk auth

# Scan Gradle project
cd android
snyk test --severity-threshold=high

# Monitor for continuous scanning
snyk monitor
```

## Gradle Wrapper Security

### Current Configuration
- **Version**: Gradle 8.7
- **SHA-256 Checksum**: Enabled (`distributionSha256Sum`)
- **Distribution**: `gradle-8.7-all.zip`

### Verification
The checksum ensures the downloaded Gradle distribution hasn't been tampered with. This is automatically verified on wrapper execution.

## Dependency Versions (2026 Standards)

### Current Status
| Dependency | Version | Status |
|------------|---------|--------|
| Android Gradle Plugin | 8.5.1 | ✅ Latest Stable |
| Kotlin | 2.1.0 | ✅ Latest |
| Google Services | 4.4.2 | ✅ Latest |
| AndroidX Browser | 1.8.0 | ✅ Latest |
| AndroidX Activity | 1.10.0 | ✅ Latest |
| AndroidX Core KTX | 1.15.0 | ✅ Latest |
| Desugar JDK Libs | 2.1.4 | ✅ Latest |

### Update Check
```bash
cd android
.\gradlew.bat dependencyUpdates
```

## Known Vulnerability Checks

### 1. Check for Log4Shell-like Issues
```bash
# Search for vulnerable logging libraries
cd android
.\gradlew.bat dependencies | Select-String "log4j"
```

### 2. Check Transitive Dependencies
```bash
# View full dependency tree
.\gradlew.bat :app:dependencies --configuration debugRuntimeClasspath
```

### 3. Check for Deprecated APIs
```bash
# Run lint to identify deprecated usage
flutter analyze
```

## Recommended Security Practices

### 1. ProGuard/R8 Configuration
- ✅ **Enabled** in release builds
- ✅ **Resource shrinking** active
- ✅ **ProGuard rules** configured for Flutter/Firebase

### 2. Minimum SDK Version
- **Current**: minSdk 24 (Android 7.0)
- **Reason**: Balances security updates with device compatibility
- **Recommendation**: Review annually and increase as needed

### 3. Target SDK Version
- **Current**: targetSdk 35 (Android 15)
- ✅ Latest for 2026

### 4. Build Configuration
- ✅ **Parallel builds** enabled
- ✅ **Build caching** enabled
- ⚠️ **Configuration cache** disabled (Flutter plugin incompatibility)

## Security Checklist

- [ ] Review `google-services.json` - never commit with production credentials
- [ ] Verify SSL certificate pinning (if applicable)
- [ ] Check for hardcoded secrets in source code
- [ ] Review permissions in `AndroidManifest.xml`
- [ ] Enable Google Play App Signing
- [ ] Run OWASP scan monthly
- [ ] Update dependencies quarterly
- [ ] Review ProGuard rules before each release

## Continuous Monitoring

### GitHub Actions (Recommended)
```yaml
name: Security Scan
on: [push, pull_request]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Snyk
        uses: snyk/actions/gradle@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## Contact
For security concerns, follow responsible disclosure practices.

---
**Last Updated**: 2026-02-02  
**Audit Standard**: OWASP MASVS v2.1
