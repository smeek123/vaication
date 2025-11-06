import {Request, Response, NextFunction} from "express";

/**
 * CORS middleware for Firebase Functions
 */
export function cors(req: Request, res: Response, next: NextFunction): void {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  next();
}

