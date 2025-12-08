# Logging Strategy

## Overview

Zeyra implements a comprehensive logging system using **Talker** for local debugging and **Sentry** for remote error monitoring. The system follows clean architecture principles with strict PII scrubbing for medical data compliance.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      App Code                               │
│   (Repositories, Use Cases, Providers, UI)                  │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              LoggingService (core/monitoring/)              │
│   - Unified API for all logging                             │
│   - PII scrubbing before remote logging                     │
│   - Environment-aware routing                               │
└─────────┬───────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                    PiiScrubber                              │
│   - Removes medical data, user IDs, tokens                  │
│   - Applied before ANY remote transmission                  │
└─────────┬───────────────────────────────────┬───────────────┘
          │                                   │
          ▼                                   ▼
┌─────────────────────┐           ┌───────────────────────────┐
│      Talker         │           │         Sentry            │
│  (Local Debug UI)   │           │   (Remote Error Reports)  │
│  - Console output   │           │   - Crashes               │
│  - In-app viewer    │           │   - Fatal/Error logs      │
│  - HTTP inspector   │           │   - Breadcrumbs           │
└─────────────────────┘           └───────────────────────────┘
```

## Log Levels

| Level | When to Use | Sent to Sentry? | Example |
|-------|-------------|-----------------|---------|
| **verbose** | Detailed trace info | No | "Calculating average: values=[...]" |
| **debug** | Development debugging | No | "Session created with ID: xxx" |
| **info** | Significant app events | No (breadcrumb only) | "Kick session completed" |
| **warning** | Recoverable issues | Yes (breadcrumb) | "Encryption key regenerated" |
| **error** | Caught exceptions | Yes (with context) | "Failed to save session: DB error" |
| **critical** | Crashes, fatal errors | Yes (immediate) | Uncaught exceptions |

## What Gets Logged

### Services Layer
- **Encryption Service**: Initialization, key generation failures, re-initialization warnings
- **Auth Listener**: Auth state changes (signed in/out), navigation failures

### Data Layer (Repositories)
- CRUD operations (debug level)
- Session lifecycle events (info level)
- Database failures (error level)
- Encryption failures (error level)

### Domain Layer (Use Cases)
- Validation checks (debug level)
- Business decisions (info level)
- Validation failures (error level)

### State Layer (Providers)
- State transitions (debug level)
- Load completion with counts (info level)
- Operation failures (error level)

### Automatic Logging (via Observers)
- **TalkerRouteObserver**: Screen navigation (push/pop/replace)
- **RiverpodLogger**: Provider init/dispose, state changes
- **TalkerDioLogger**: HTTP requests/responses (Supabase)

## PII Scrubbing Rules

The following data is scrubbed before any remote transmission:

| Data Type | Scrubbing Action |
|-----------|------------------|
| User IDs | Replace with `[USER_ID]` |
| Session IDs | Replace with `[SESSION_ID]` |
| Medical values (biomarkers, kick data) | Remove entirely |
| Kick counts/times | Replace with `[MEDICAL_DATA]` |
| Notes/comments | Remove entirely |
| Email addresses | Replace with `[EMAIL]` |
| Names | Replace with `[NAME]` |
| Auth tokens | Remove entirely |
| Encryption keys | Remove entirely |
| File paths | Replace with `[FILE_PATH]` |

## GDPR Consent Analysis

### Summary

| Data Category | Legal Basis | Consent Required? | Justification |
|---------------|-------------|-------------------|---------------|
| Crash reports | Legitimate Interest | **No** | App stability is essential for user safety |
| Error logs (scrubbed) | Legitimate Interest | **No** | Debugging critical issues |
| HTTP errors (scrubbed) | Legitimate Interest | **No** | Service reliability |
| Navigation breadcrumbs | Legitimate Interest | **No** | Contextual debugging only |
| Performance metrics | Consent | **Yes** | Not essential for functionality |
| Usage analytics | Consent | **Yes** | Not essential for functionality |
| Feature usage stats | Consent | **Yes** | Not essential for functionality |

### Detailed Analysis

#### UI Layer - LOCAL ONLY
**Consent Required**: No

- Screen navigation (TalkerRouteObserver) - Local only, debug builds
- User actions (button taps) - Local only, never sent remotely
- Widget lifecycle events - Local debugging only

#### State Layer - LOCAL ONLY
**Consent Required**: No

- State transitions - Local debugging only
- Provider initialization/disposal - Local debugging only
- Async operation start/complete - Local debugging only

#### Use Cases - LOCAL ONLY
**Consent Required**: No

- Business rule validations - Local debugging only
- Flow decisions - Local debugging only
- Orchestration logic - Local debugging only

#### Data Layer - MIXED
**Legitimate Interest (No Consent Required)**:
- Database operation failures (scrubbed) - Critical for data integrity
- Encryption failures (no values logged) - Security monitoring
- Data corruption detection - Data protection

**Local Only (No Consent Required)**:
- Successful CRUD operations
- Cache hit/miss statistics
- Query performance metrics

#### HTTP/Network - MIXED
**Legitimate Interest (No Consent Required)**:
- Failed requests: URL path only (no query params), status code, error type
- Auth failures: Anonymized failure reason only
- Timeout/connection errors

**Local Only (No Consent Required)**:
- Full request/response bodies (debug builds only)
- Headers including auth (debug builds only)
- Network timing details

#### Critical Errors - LEGITIMATE INTEREST
**Consent Required**: No

- Uncaught exceptions - Always sent (app stability)
- Fatal errors - Always sent (app stability)
- Security-related failures - Always sent (user protection)

### Consent Implementation

The app implements a two-tier consent model:

```dart
enum AnalyticsConsent {
  crashReportsOnly,  // Default - legitimate interest only
  fullAnalytics,     // User opted in to usage analytics
}
```

**Default Behavior (No Consent Required)**:
- Crash reports
- Error logs (scrubbed)
- Security failures
- Critical operation failures

**Opt-In Only (Consent Required)**:
- Performance metrics
- Feature usage statistics
- User behavior analytics
- A/B testing data

## Environment-Specific Behavior

| Feature | Debug Build | Release Build |
|---------|-------------|---------------|
| Console output | Yes (verbose) | No |
| Talker in-app viewer | Yes | No |
| Developer menu | Yes | Hidden |
| HTTP body logging | Yes | No |
| Debug/verbose logs | Yes | No |
| Sentry errors | Yes (test DSN) | Yes (prod DSN) |
| PII scrubbing | Optional locally | Always enabled |

## Developer Menu

The developer menu is accessible from the "More" tab in debug builds only (`kDebugMode` check).

**Features**:
- Open Talker log viewer
- Clear logs
- Export logs to file
- View HTTP request history
- Test crash reporting (trigger test error)

## Usage Examples

### Basic Logging

```dart
import 'package:zeyra/core/monitoring/logging_service.dart';

class ExampleService {
  final LoggingService _logger;
  
  ExampleService(this._logger);
  
  Future<void> performOperation() async {
    _logger.debug('Starting operation');
    
    try {
      // Do work
      _logger.info('Operation completed successfully');
    } catch (e, stackTrace) {
      _logger.error('Operation failed', error: e, stackTrace: stackTrace);
    }
  }
}
```

### Repository Logging

```dart
@override
Future<KickSession> createSession() async {
  _logger.debug('Creating new kick session');
  
  try {
    final session = await _dao.createSession();
    _logger.info('Kick session created', data: {'sessionId': '[SESSION_ID]'});
    return session;
  } catch (e, stackTrace) {
    _logger.error('Failed to create session', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
```

### Provider Logging

```dart
@override
Future<void> loadHistory() async {
  _logger.debug('Loading kick counter history');
  state = state.copyWith(isLoading: true);
  
  try {
    final history = await _useCase.getSessionHistory();
    _logger.info('History loaded', data: {'count': history.length});
    state = state.copyWith(history: history, isLoading: false);
  } catch (e, stackTrace) {
    _logger.error('Failed to load history', error: e, stackTrace: stackTrace);
    state = state.copyWith(error: e.toString(), isLoading: false);
  }
}
```

## Best Practices

1. **Always scrub PII** before logging
2. **Use appropriate log levels** (don't log everything as error)
3. **Include context** in error logs (operation being performed)
4. **Never log sensitive data** (passwords, tokens, medical values)
5. **Log state transitions** in providers for debugging
6. **Log business decisions** in use cases
7. **Log failures at error level** with stack traces
8. **Use debug level** for development information
9. **Use info level** for significant app events
10. **Test your logging** - verify PII is scrubbed

## Monitoring & Alerts

### Sentry Configuration

- **Error Rate Alerts**: Notify when error rate exceeds threshold
- **Performance Monitoring**: Track slow operations
- **Release Tracking**: Tag errors by app version
- **Environment Tagging**: Separate dev/staging/prod errors
- **Custom Context**: Include pregnancy week, feature flags

### Key Metrics to Monitor

- Crash-free sessions percentage
- Most common error types
- Session duration analytics
- Feature adoption rates (with consent)
- Database operation performance
- Encryption operation timing

## Privacy & Security

### Data Retention

- **Local logs**: Cleared on app restart (debug builds only)
- **Sentry logs**: 90-day retention (configurable)
- **No PII retention**: All medical data scrubbed before transmission

### Compliance

- **GDPR**: Legitimate interest for crash reports, consent for analytics
- **HIPAA**: No PHI transmitted (strict PII scrubbing)
- **UK DPA**: Compliant with UK data protection laws

### Security Measures

- All remote logging uses TLS encryption
- PII scrubbing applied before network transmission
- No medical data in error messages
- Secure storage for encryption keys (not logged)
- Rate limiting on error reporting

## Maintenance

### Regular Tasks

- Review Sentry error reports weekly
- Update PII scrubbing rules as new data types added
- Test logging in new features
- Verify consent flow works correctly
- Check log file sizes in development

### When Adding New Features

1. Identify what needs logging
2. Determine appropriate log level
3. Check for PII in logged data
4. Add PII scrubbing rules if needed
5. Test logging in debug build
6. Verify nothing sensitive sent to Sentry

## References

- [Talker Documentation](https://pub.dev/packages/talker)
- [Sentry Flutter Documentation](https://docs.sentry.io/platforms/flutter/)
- [GDPR Legitimate Interest Guidelines](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/legitimate-interests/)

