# Controller Tests

This directory contains unit tests for all backend controllers.

## Structure

```
tests/unit/controllers/
├── driver/
│   └── userController.test.js       # Tests for driver user management
├── rider/
│   └── rideController.test.js       # Tests for ride management
└── shared/
    ├── authController.test.js       # Tests for authentication and profile
    ├── chatController.test.js       # Tests for chat and messaging
    ├── emergencyController.test.js  # Tests for emergency incidents
    ├── notificationController.test.js # Tests for notifications
    ├── settingsController.test.js   # Tests for application settings
    ├── reportsController.test.js    # Tests for reporting and analytics
    └── monitoringController.test.js # Tests for real-time monitoring
```

## Running Tests

### Run all controller tests
```bash
npm test -- tests/unit/controllers
```

### Run all shared controller tests
```bash
npm test -- tests/unit/controllers/shared
```

### Run tests for specific controllers

#### Shared Controllers
```bash
# Auth controller tests (14 tests)
npm test -- tests/unit/controllers/shared/authController.test.js

# Chat controller tests (26 tests)
npm test -- tests/unit/controllers/shared/chatController.test.js

# Emergency controller tests (22 tests)
npm test -- tests/unit/controllers/shared/emergencyController.test.js

# Notification controller tests (30 tests)
npm test -- tests/unit/controllers/shared/notificationController.test.js

# Settings controller tests (28 tests)
npm test -- tests/unit/controllers/shared/settingsController.test.js

# Reports controller tests (28 tests)
npm test -- tests/unit/controllers/shared/reportsController.test.js

# Monitoring controller tests (30 tests)
npm test -- tests/unit/controllers/shared/monitoringController.test.js
```

#### Driver Controllers
```bash
# Driver user controller tests (17 tests)
npm test -- tests/unit/controllers/driver/userController.test.js
```

#### Rider Controllers
```bash
# Rider ride controller tests (17 tests)
npm test -- tests/unit/controllers/rider/rideController.test.js
```

### Run tests in watch mode
```bash
npm run test:watch -- tests/unit/controllers
```

### Run tests with coverage
```bash
npm run test:coverage -- tests/unit/controllers
```

## Test Coverage

Current controller tests cover:

### Shared Controllers (178 tests)

#### Auth Controller (14 tests)
- ✅ Function exports and signatures
- ✅ Required field validation
- ✅ User role validation
- ✅ 2FA support verification

#### Chat Controller (26 tests)
- ✅ Function exports and signatures
- ✅ Conversation management (listing, creation)
- ✅ Message management (retrieval, sending)
- ✅ Message status (read/unread)
- ✅ Query parameter handling

#### Emergency Controller (22 tests)
- ✅ Function exports and signatures
- ✅ Incident retrieval and filtering
- ✅ Incident creation and updates
- ✅ Status and priority validation
- ✅ Incident type validation

#### Notification Controller (30 tests)
- ✅ Function exports and signatures
- ✅ Notification retrieval and filtering
- ✅ Notification creation
- ✅ Broadcasting functionality
- ✅ Status management
- ✅ Notification statistics
- ✅ Type and priority validation

#### Settings Controller (28 tests)
- ✅ Function exports and signatures
- ✅ Settings retrieval (all, by key)
- ✅ Setting creation and updates
- ✅ Bulk operations
- ✅ Setting categories and data types
- ✅ Key naming conventions

#### Reports Controller (28 tests)
- ✅ Function exports and signatures
- ✅ Report retrieval (recent, scheduled)
- ✅ Report generation
- ✅ Report statistics
- ✅ Scheduled report management
- ✅ Report type and format validation
- ✅ Schedule frequency validation

#### Monitoring Controller (30 tests)
- ✅ Function exports and signatures
- ✅ Live ride monitoring
- ✅ Safety monitoring
- ✅ System monitoring
- ✅ GPS logs
- ✅ Alert types and severity levels
- ✅ Location data handling

### Driver Controllers (17 tests)

#### Driver User Controller
- ✅ Function exports and signatures
- ✅ Query parameter handling
- ✅ User filtering (role, status, search)
- ✅ CRUD operations structure
- ✅ User statistics

### Rider Controllers (17 tests)

#### Rider Ride Controller
- ✅ Function exports and signatures
- ✅ Query parameter handling
- ✅ Ride filtering (status, type, dates)
- ✅ CRUD operations structure
- ✅ Ride status and type validation
- ✅ Ride statistics

**Total: 212 tests passing**

## Adding New Tests

When adding new controller tests:

1. Create a new test file in the appropriate directory:
   - `driver/` for driver-specific controllers
   - `rider/` for rider-specific controllers
   - `shared/` for shared controllers

2. Follow the existing test structure:
```javascript
import { functionName } from '../../../../src/controllers/path/to/controller.js';

describe('Controller Name', () => {
  describe('Function exports', () => {
    test('functionName should be defined', () => {
      expect(functionName).toBeDefined();
      expect(typeof functionName).toBe('function');
    });
  });

  describe('Specific functionality', () => {
    test('should test specific behavior', () => {
      // Test code here
    });
  });
});
```

3. Run the tests to ensure they pass:
```bash
npm test -- path/to/your/test.js
```

## Test Philosophy

These tests focus on:
- **Structure validation**: Ensuring functions are properly exported
- **Interface validation**: Verifying function signatures match Express patterns
- **Data structure validation**: Testing query parameters, request bodies, and response formats
- **Business logic validation**: Checking valid values for statuses, roles, types, etc.

For full integration testing with database mocking, see the integration tests directory.

## Notes

- Tests use ES modules (`import/export`)
- Tests are compatible with Jest's experimental VM modules support
- Database connections are not mocked in these structural tests
- For full end-to-end testing, use the integration test suite
