import {Request, Response, NextFunction} from "express";
import * as admin from "firebase-admin";

export interface AuthenticatedRequest extends Request {
  user?: admin.auth.DecodedIdToken;
}

/**
 * Middleware to validate Firebase Auth token
 */
export async function validateAuth(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      res.status(401).json({error: "Unauthorized: Missing or invalid authorization header"});
      return;
    }

    const token = authHeader.split("Bearer ")[1];

    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      req.user = decodedToken;
      next();
    } catch (error) {
      res.status(401).json({error: "Unauthorized: Invalid token"});
      return;
    }
  } catch (error) {
    res.status(500).json({error: "Internal server error during authentication"});
    return;
  }
}

/**
 * Get user ID from authenticated request
 */
export function getUserId(req: AuthenticatedRequest): string {
  if (!req.user || !req.user.uid) {
    throw new Error("User not authenticated");
  }
  return req.user.uid;
}

