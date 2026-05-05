# StyleSync Firebase Cloud Functions

Server-side authentication and business logic for the StyleSync barber queue management app.

## Features

- **Secure Authentication**: Server-authoritative password handling with bcrypt hashing and secret pepper
- **Rate Limiting**: Protection against brute-force attacks and abuse
- **XP & Loyalty System**: Automatic customer progression based on service payments
- **Suki Relationships**: Tracking of customer-barber visit history

## Functions

### Authentication Functions

#### `registerWithUsernameSecure`
Creates a new user account with secure server-side password hashing.

**Parameters:**
- `username` (string): 3-50 characters, alphanumeric + underscore
- `email` (string): Valid email address
- `password` (string): 8-100 characters
- `role` (string): "barber", "customer", or "shopOwner"
- `isPremium` (boolean, optional): Premium account flag

**Returns:** `{ customToken: string }`

#### `signInWithUsernameSecure`
Authenticates a user with username and password.

**Parameters:**
- `username` (string): User's username
- `password` (string): User's password

**Returns:** `{ customToken: string }`

#### `syncServerPasswordCredential`
Updates a user's password credential to server-side bcrypt format.

**Parameters:**
- `password` (string): New password (8-100 characters)

**Returns:** `{ ok: true }`

### Business Logic Functions

#### `onPaymentConfirmed` (Firestore Trigger)
Automatically updates customer XP and loyalty rank when a barber confirms payment.

**Trigger:** `shops/{shopId}/services/{serviceId}` document update
**Condition:** `paymentConfirmedAt` changes from null to timestamp

**Updates:**
- Customer XP: +10 to +250 based on service amount
- Loyalty rank: "rookie" → "regular" → "elite" → "legend"
- Suki stats: Visit count and last visit date for customer-barber relationship

## Security Features

- **Server-Side Hashing**: Passwords are never hashed on client devices
- **Secret Pepper**: Additional secret salt stored in Google Secret Manager
- **Rate Limiting**: Prevents brute-force attacks (16 attempts per 15 minutes for login, 8 per hour for registration)
- **App Check**: Enforces Firebase App Check for all callable functions
- **Input Validation**: Comprehensive validation with descriptive error messages
- **Credential Migration**: Automatic upgrade from legacy client-side hashing

## Setup & Deployment

### Prerequisites
- Node.js 20
- Firebase CLI
- Firebase project with Firestore and Functions enabled

### Installation
```bash
cd functions
npm install
```

### Configuration
1. Set the server pepper secret:
```bash
firebase functions:secrets:set STYLESYNC_PEPPER
# Enter a long random string (at least 16 characters)
```

2. (Optional) Set Firebase Web API key for legacy credential recovery:
```bash
firebase functions:config:set functions.firebase_web_api_key="your-web-api-key"
```

### Development
```bash
# Build and serve with emulators
npm run serve

# Run tests
npm test

# Lint code
npm run lint
```

### Deployment
```bash
# Deploy functions only
npm run deploy

# Deploy with secrets access
firebase deploy --only functions
```

## Testing

Run the test suite:
```bash
npm test
```

Tests cover:
- Function input validation
- Authentication flows
- Error handling
- XP calculation logic
- Firestore transaction integrity

## Monitoring & Logging

All functions include comprehensive logging:
- Function calls with user IDs and parameters
- Error conditions with context
- Performance metrics for XP calculations
- Security events (rate limit hits, auth failures)

Monitor logs in the Firebase Console under Functions > Logs.

## Error Handling

Functions return user-friendly error messages while logging detailed information for debugging:

- `invalid-argument`: Input validation failures
- `already-exists`: Username/email conflicts
- `permission-denied`: Authentication failures
- `resource-exhausted`: Rate limit exceeded
- `internal`: Server errors

## Integration

The functions are fully integrated with the Flutter app through the `AuthRepository` class, which handles:
- Callable function invocations
- Custom token authentication
- Error mapping to user-friendly messages
- Automatic user document creation

## Performance

- **Cold Start Optimization**: Functions use appropriate memory allocation (256-512MB)
- **Timeout Management**: Configured timeouts prevent runaway executions
- **Efficient Queries**: Username index lookups and batched writes
- **Transaction Safety**: Atomic operations for XP and loyalty updates