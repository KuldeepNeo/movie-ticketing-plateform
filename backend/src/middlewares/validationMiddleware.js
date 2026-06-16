/**
 * Express middleware to validate request payload bodies against Zod schemas.
 * @param {import("zod").ZodSchema} schema - Zod validator schema
 */
function validationMiddleware(schema) {
  return (req, res, next) => {
    try {
      // Parse request body and replace with validated, cleaned output
      req.body = schema.parse(req.body);
      next();
    } catch (err) {
      // Forward Zod validation errors to global handler
      next(err);
    }
  };
}

module.exports = validationMiddleware;
