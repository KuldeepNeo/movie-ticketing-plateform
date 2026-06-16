# Movie Ticketing Backend (BookMyShow Clone)

This is the backend API for the Movie Ticketing Platform. It is built using Node.js, Express, and SQLite with Knex.js.

## 🚀 Getting Started

### Prerequisites

- Node.js (LTS version recommended)
- npm

### Installation

1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure Environment Variables:
   Copy the example environment file and adjust if necessary:
   ```bash
   cp .env.example .env
   ```

3. Run Database Migrations & Seeds:
   ```bash
   npx knex migrate:latest
   npx knex seed:run
   ```

4. Start Development Server:
   ```bash
   npm run dev
   ```
   The server will start at `http://localhost:3000`.

---

## 🧪 Testing

The project uses Jest and Supertest for testing. To execute unit and integration test suites:

```bash
npm test
```

---

## 📂 Project Architecture

The codebase follows a Layered Architecture design:

- **Routes (`src/routes/`)**: Declares API v1 routes and attaches validators/auth middleware guards.
- **Controllers (`src/controllers/`)**: Parses request payload parameters, triggers service logic, and responds with standardized JSON models.
- **Services (`src/services/`)**: Orchestrates core business rules and domain logic (pure, decoupled from Express context).
- **Repositories (`src/repositories/`)**: Encapsulates Knex query logic to access the SQLite tables.
- **Validators (`src/validators/`)**: Enforces input structure and criteria constraints using Zod schemas.

---

## 🔑 API Endpoints (Auth Module)

| Method | Endpoint | Description | Auth Required | Request Body |
|---|---|---|---|---|
| `POST` | `/api/v1/auth/register` | Register a new user | No | `{ name, email, password, confirm_password }` |
| `POST` | `/api/v1/auth/login` | Authenticate & get JWTs | No | `{ email, password }` |
| `POST` | `/api/v1/auth/refresh` | Refresh expired access token | No | `{ refresh_token }` |
| `POST` | `/api/v1/auth/logout` | Invalidate current session | Yes (Bearer) | None |
| `GET` | `/api/v1/auth/me` | Fetch active user profile | Yes (Bearer) | None |
