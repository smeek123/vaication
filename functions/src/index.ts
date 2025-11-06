import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import express, {Request, Response} from "express";
import {cors} from "./utils/cors";
import {validateAuth} from "./utils/auth";
import {chatHandler} from "./api/chat";
import {handleError} from "./utils/errors";

// Initialize Firebase Admin
admin.initializeApp();

const app = express();

// Middleware
app.use(cors);
app.use(express.json());

// Health check endpoint
app.get("/health", (req: Request, res: Response) => {
  res.json({status: "ok", timestamp: new Date().toISOString()});
});

// Chat endpoint (requires authentication)
app.post("/chat", validateAuth, chatHandler);

// Error handling
app.use(handleError);

// Export Firebase Functions
export const api = functions.https.onRequest(app);

