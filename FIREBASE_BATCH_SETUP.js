// Firebase Firestore Batch Setup Script
// Copy and run each section in Firebase Console → Firestore → Console

// ============================================
// SECTION 1: Premium Customer (Email/Password)
// ============================================
// Create in Firebase Console > Authentication > Add User
// Email: roniandave@gmail.com
// Password: SecurePass123!

// Then create Firestore document:
db.collection('users').doc('{USER_UID_FROM_ABOVE}').set({
  username: 'roniandave',
  displayName: 'Roni Dave',
  email: 'roniandave@gmail.com',
  role: 'customer',
  isPremium: true,
  photoUrl: '',
  phoneNumber: '',
  providerIds: ['password'],
  xp: 500,
  loyaltyRank: 'elite',
  profileComplete: true,
  hairProfile: {
    type: 'straight',
    density: 'medium',
    scalpSensitivity: 'medium'
  },
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
  lastLoginAt: firebase.firestore.FieldValue.serverTimestamp()
});

// Create username index
db.collection('username_index').doc('roniandave').set({
  uid: '{USER_UID_FROM_ABOVE}',
  email: 'roniandave@gmail.com'
});

// ============================================
// SECTION 2: Sample Test Customer
// ============================================
// Create in Firebase Console > Authentication > Add User
// Email: customer.test@gmail.com
// Password: TestPass123!

// Then create Firestore document:
db.collection('users').doc('{USER_UID_FROM_ABOVE}').set({
  username: 'customer_john',
  displayName: 'John Customer',
  email: 'customer.test@gmail.com',
  role: 'customer',
  isPremium: false,
  photoUrl: '',
  phoneNumber: '',
  providerIds: ['password'],
  xp: 100,
  loyaltyRank: 'rookie',
  profileComplete: true,
  hairProfile: {
    type: 'wavy',
    density: 'medium',
    scalpSensitivity: 'low'
  },
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
  lastLoginAt: firebase.firestore.FieldValue.serverTimestamp()
});

// Create username index
db.collection('username_index').doc('customer_john').set({
  uid: '{USER_UID_FROM_ABOVE}',
  email: 'customer.test@gmail.com'
});

// ============================================
// SECTION 3: Sample Test Barber
// ============================================
// Create in Firebase Console > Authentication > Add User
// Email: barber.test@gmail.com
// Password: TestPass123!

// Then create Firestore document:
db.collection('users').doc('{USER_UID_FROM_ABOVE}').set({
  username: 'barber_johnny',
  displayName: 'Johnny Barber',
  email: 'barber.test@gmail.com',
  role: 'barber',
  isPremium: false,
  photoUrl: '',
  phoneNumber: '+639111111111',
  providerIds: ['password'],
  xp: 300,
  loyaltyRank: 'regular',
  profileComplete: true,
  hairProfile: {
    type: 'straight',
    density: 'medium',
    scalpSensitivity: 'medium'
  },
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
  lastLoginAt: firebase.firestore.FieldValue.serverTimestamp()
});

// Create barber profile
db.collection('barbers').doc('{USER_UID_FROM_ABOVE}').set({
  username: 'barber_johnny',
  displayName: 'Johnny Barber',
  email: 'barber.test@gmail.com',
  phoneNumber: '+639111111111',
  isPremium: false,
  verificationStatus: 'pending',
  rating: 4.2,
  totalRatings: 45,
  yearsExperience: 3,
  specializations: ['fade', 'buzz'],
  location: {
    address: '456 Haircut Ave, Quezon City',
    city: 'Quezon City',
    province: 'NCR',
    coordinates: {
      latitude: 14.6349,
      longitude: 121.0388
    }
  },
  availability: {
    monday: { start: '10:00', end: '19:00' },
    tuesday: { start: '10:00', end: '19:00' },
    wednesday: { start: '10:00', end: '19:00' },
    thursday: { start: '10:00', end: '19:00' },
    friday: { start: '10:00', end: '21:00' },
    saturday: { start: '09:00', end: '17:00' },
    sunday: { start: 'closed', end: 'closed' }
  },
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  updatedAt: firebase.firestore.FieldValue.serverTimestamp()
});

// Create username index
db.collection('username_index').doc('barber_johnny').set({
  uid: '{USER_UID_FROM_ABOVE}',
  email: 'barber.test@gmail.com'
});

// ============================================
// SECTION 4: Premium Barber (Google Sign-In)
// ============================================
// FIRST: Login to app with Google using tolentino.roniandave@dnsc.edu.ph
// This auto-creates the Firebase Auth user and Firestore profile
// Get the UID from Firebase Console after first login

// THEN: Update the Firestore user document:
db.collection('users').doc('{GOOGLE_USER_UID}').set({
  username: 'barber_tolentino',
  displayName: 'Tolentino Barber',
  email: 'tolentino.roniandave@dnsc.edu.ph',
  role: 'barber',
  isPremium: true,
  photoUrl: '',
  phoneNumber: '+639123456789',
  providerIds: ['google.com'],
  xp: 1000,
  loyaltyRank: 'legend',
  profileComplete: true,
  hairProfile: {
    type: 'straight',
    density: 'medium',
    scalpSensitivity: 'medium'
  },
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
  lastLoginAt: firebase.firestore.FieldValue.serverTimestamp()
}, { merge: true }); // merge:true to preserve Google provider info

// Create barber profile
db.collection('barbers').doc('{GOOGLE_USER_UID}').set({
  username: 'barber_tolentino',
  displayName: 'Tolentino Barber',
  email: 'tolentino.roniandave@dnsc.edu.ph',
  phoneNumber: '+639123456789',
  isPremium: true,
  verificationStatus: 'approved',
  rating: 4.8,
  totalRatings: 250,
  yearsExperience: 8,
  specializations: ['fade', 'undercut', 'design'],
  location: {
    address: '123 Barbershop St, Metro Manila',
    city: 'Manila',
    province: 'NCR',
    coordinates: {
      latitude: 14.5995,
      longitude: 120.9842
    }
  },
  availability: {
    monday: { start: '09:00', end: '20:00' },
    tuesday: { start: '09:00', end: '20:00' },
    wednesday: { start: '09:00', end: '20:00' },
    thursday: { start: '09:00', end: '20:00' },
    friday: { start: '09:00', end: '20:00' },
    saturday: { start: '09:00', end: '18:00' },
    sunday: { start: '10:00', end: '18:00' }
  },
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  updatedAt: firebase.firestore.FieldValue.serverTimestamp()
});

// Update username index (will be auto-created when profile complete in app,
// but you can add manually after Google login)
db.collection('username_index').doc('barber_tolentino').set({
  uid: '{GOOGLE_USER_UID}',
  email: 'tolentino.roniandave@dnsc.edu.ph'
});
