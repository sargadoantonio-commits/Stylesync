import admin from "firebase-admin";
import serviceAccount from "../google-services.json" with { type: "json" };

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
  projectId: serviceAccount.project_info.project_id,
});

const auth = admin.auth();
const firestore = admin.firestore();

interface TestUser {
  username: string;
  email: string;
  password: string;
  role: "customer" | "barber";
  isPremium: boolean;
}

const testUsers: TestUser[] = [
  {
    username: "testcustomer",
    email: "customer@test.stylesync.app",
    password: "TestPassword123!",
    role: "customer",
    isPremium: false,
  },
  {
    username: "testcustomerprem",
    email: "customerpremium@test.stylesync.app",
    password: "TestPassword123!",
    role: "customer",
    isPremium: true,
  },
  {
    username: "testbarber",
    email: "barber@test.stylesync.app",
    password: "TestPassword123!",
    role: "barber",
    isPremium: false,
  },
  {
    username: "testbarberprem",
    email: "barberpremium@test.stylesync.app",
    password: "TestPassword123!",
    role: "barber",
    isPremium: true,
  },
];

async function createTestUsers() {
  console.log("🔧 Creating test accounts...\n");

  for (const user of testUsers) {
    try {
      // Create Firebase Auth user
      const userRecord = await auth.createUser({
        email: user.email,
        password: user.password,
        displayName: user.username,
      });

      // Create username index
      const normalizedUsername = user.username.toLowerCase();
      await firestore.collection("username_index").doc(normalizedUsername).set({
        uid: userRecord.uid,
        email: user.email.toLowerCase(),
      });

      // Create user profile
      await firestore.collection("users").doc(userRecord.uid).set({
        uid: userRecord.uid,
        role: user.role,
        username: user.username,
        displayName: user.username,
        photoUrl: "",
        email: user.email.toLowerCase(),
        phoneNumber: "",
        providerIds: ["password"],
        xp: user.isPremium ? 1000 : 0,
        loyaltyRank: user.isPremium ? "elite" : "rookie",
        isPremium: user.isPremium,
        profileComplete: true,
        hairProfile: {
          type: "straight",
          density: "medium",
          scalpSensitivity: "medium",
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      const userType = user.isPremium ? "Premium" : "Regular";
      const role = user.role.toUpperCase();
      console.log(
        `✅ ${userType} ${role}: @${user.username} (${user.email})`
      );
      console.log(`   Password: ${user.password}\n`);
    } catch (error) {
      console.error(
        `❌ Failed to create ${user.username}:`,
        error instanceof Error ? error.message : error
      );
    }
  }

  console.log("✨ Test accounts created successfully!\n");
  console.log(
    "📱 You can now log in with these credentials on your phone app.\n"
  );
}

// Run the function
createTestUsers()
  .then(() => {
    console.log("🎉 Setup complete!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("Setup failed:", error);
    process.exit(1);
  });
