import * as admin from "firebase-admin";

/**
 * Get user preferences from Firestore
 */
export async function getUserPreferences(userId: string): Promise<any> {
  try {
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      return null;
    }

    const userData = userDoc.data();
    return {
      preferences: userData?.preferences || {},
      savedTrips: userData?.savedTrips || [],
    };
  } catch (error) {
    console.error("Error fetching user preferences:", error);
    return null;
  }
}

/**
 * Get user's saved trips for context
 */
export async function getSavedTrips(userId: string): Promise<any[]> {
  try {
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      return [];
    }

    const userData = userDoc.data();
    return userData?.savedTrips || [];
  } catch (error) {
    console.error("Error fetching saved trips:", error);
    return [];
  }
}

