# Module Auth - Defect Reports

The following table documents any bugs, errors, or defects detected during Sprint 1 QA validation. 

| Defect ID | Summary | Steps to Reproduce | Expected Result | Actual Result | Environment | Severity | Priority | Status |
| --------- | ------- | ------------------ | --------------- | ------------- | ----------- | -------- | -------- | ------ |
| **DF-AUTH-001** | CORS & Helmet security policies block local Flutter Web requests (`XMLHttpRequest onError` callback). | 1. Start backend server with `npm run dev`. <br>2. Run Flutter Web client locally (e.g., `http://localhost:52431`). <br>3. Attempt login or registration from the client UI. | Request succeeds and backend processes the login/registration payload. | Request fails at network layer with `XMLHttpRequest onError` due to CORS port mismatch and Helmet policy headers. | Local Development (macOS, Flutter Web, Node.js Express) | High | High | **CLOSED** |

---

## QA Audit Notes

- **CORS & Helmet Resolution**: Resolves the network block (DF-AUTH-001) by dynamically allowing request origins in development/test modes, and relaxing Helmet's cross-origin resource/embedder/opener policies for local web development. In `production` mode, strict origin validation and Helmet restrictions remain fully active.
- **API Latency SLA**: Measured responses on `/auth/register`, `/auth/login`, and `/auth/me` are all consistently under **100 ms** (below the SLA threshold of **500 ms**).
- **Security Audit**: All user passwords are encrypted using Bcrypt with a work factor of 12 prior to database write. Stateless JWT access tokens are validated correctly, and CORS origins are locked to the configured front-end server.
- **Release Readiness**: The Auth module meets all Sprint 1 Definition of Done criteria and is considered **RELEASE-READY**.
