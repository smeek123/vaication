module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
    "/generated/**/*", // Ignore generated files.
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": 0,
    "indent": ["error", 2],
    "max-len": ["warn", {code: 120}], // Increased from 80
    "object-curly-spacing": ["error", "never"],
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": ["warn", {argsIgnorePattern: "^_"}],
    "@typescript-eslint/no-explicit-any": "warn",
    "require-jsdoc": "off", // Disable JSDoc requirement
    "valid-jsdoc": "off", // Disable JSDoc validation
    "comma-dangle": ["error", "always-multiline"],
    "arrow-parens": ["error", "always"],
    "no-trailing-spaces": "error",
  },
};
