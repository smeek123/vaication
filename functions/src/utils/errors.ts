/**
 * Custom error class for API errors
 */
export class APIError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message);
    this.name = "APIError";
    Object.setPrototypeOf(this, APIError.prototype);
  }
}

/**
 * Error handler for Express
 */
export function handleError(error: Error, req: any, res: any, _next: any) {
  if (error instanceof APIError) {
    res.status(error.statusCode).json({
      error: error.message,
      code: error.code,
    });
  } else {
    console.error("Unhandled error:", error);
    res.status(500).json({
      error: "Internal server error",
      code: "INTERNAL_ERROR",
    });
  }
}

