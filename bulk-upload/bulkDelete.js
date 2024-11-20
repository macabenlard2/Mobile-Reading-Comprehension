// Import necessary modules
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize the Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://eduassess-52e66-default-rtdb.firebaseio.com" // Replace with your database URL
});

const db = admin.firestore();

async function bulkDelete() {
  const batch = db.batch();

  // Delete default stories
  const storiesSnapshot = await db.collection("Stories")
    .where("isDefault", "==", true)
    .get();

  storiesSnapshot.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // Delete default quizzes
  const quizzesSnapshot = await db.collection("Quizzes")
    .where("isDefault", "==", true)
    .get();

  quizzesSnapshot.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // Commit the batch delete
  await batch.commit();
  console.log("Bulk delete of default stories and quizzes completed.");
}

// Call the function to perform the bulk delete
bulkDelete().catch(console.error);
