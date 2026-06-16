# Movie Ticketing Platform (BookMyShow Clone)

# KPI Validation Document

## Module 1: Authentication

| KPI Number   | KPI                                       | Validation Method                                                                                                                                                                              |
| ------------ | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| KPI-AUTH-001 | User can register using valid information | Validate registration with mandatory fields (name, email, password). Verify frontend validation, API response (201/200), encrypted password storage, and user record creation in the database. |
| KPI-AUTH-002 | Duplicate email registration is prevented | Attempt registration using an existing email. Verify API returns appropriate error (409/400) and no duplicate database record is created.                                                      |
| KPI-AUTH-003 | User can log in successfully              | Validate login using valid credentials. Verify JWT/session creation, authentication token generation, and successful dashboard redirection.                                                    |
| KPI-AUTH-004 | Invalid login credentials are rejected    | Submit incorrect credentials and verify HTTP 401 response with no authenticated session created.                                                                                               |
| KPI-AUTH-005 | User can logout successfully              | Validate logout endpoint invalidates session/token and prevents access to authenticated APIs.                                                                                                  |
| KPI-AUTH-006 | Session management functions correctly    | Verify authenticated requests succeed with valid token and fail after logout or session expiry.                                                                                                |

---

# Module 2: Movie Discovery

| KPI Number  | KPI                             | Validation Method                                                                                                   |
| ----------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| KPI-MOV-001 | Movies are listed successfully  | Validate GET /movies returns all active movies within selected city.                                                |
| KPI-MOV-002 | Search returns relevant movies  | Search by movie title and verify matching records are returned within acceptable response time.                     |
| KPI-MOV-003 | Filters work correctly          | Apply language, genre, rating, and format filters. Verify filtered dataset accuracy.                                |
| KPI-MOV-004 | Movie details display correctly | Validate GET /movies/{id} returns synopsis, duration, rating, language, genre, cast, poster, and show availability. |
| KPI-MOV-005 | Invalid movie ID returns error  | Request nonexistent movie ID and verify HTTP 404 response.                                                          |

---

# Module 3: City Management

| KPI Number   | KPI                    | Validation Method                                                                                     |
| ------------ | ---------------------- | ----------------------------------------------------------------------------------------------------- |
| KPI-CITY-001 | User can select a city | Verify city selection updates application context and available movies.                               |
| KPI-CITY-002 | User can change city   | Validate changing city refreshes movie listings, theaters, and shows without requiring login refresh. |

---

# Module 4: Theater & Show Management

| KPI Number      | KPI                             | Validation Method                                                      |
| --------------- | ------------------------------- | ---------------------------------------------------------------------- |
| KPI-THEATER-001 | Theater list displays correctly | Verify theaters for selected movie and city are returned accurately.   |
| KPI-THEATER-002 | Show timings display correctly  | Validate available showtimes correspond to selected theater and movie. |
| KPI-THEATER-003 | Invalid show is rejected        | Access invalid show ID and verify HTTP 404 response.                   |

---

# Module 5: Seat Booking

| KPI Number   | KPI                                      | Validation Method                                                                                         |
| ------------ | ---------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| KPI-SEAT-001 | Live seat availability is accurate       | Validate available seats match database state before booking.                                             |
| KPI-SEAT-002 | User can select seats                    | Verify selected seats appear in booking summary and remain highlighted.                                   |
| KPI-SEAT-003 | Seat locking prevents concurrent booking | Simulate two users selecting the same seat simultaneously. Verify only one booking proceeds successfully. |
| KPI-SEAT-004 | Seat lock expires after timeout          | Lock seats without payment. Verify automatic release after configured timeout period.                     |
| KPI-SEAT-005 | Maximum booking limit enforced           | Attempt booking exceeding maximum seat limit. Verify validation error returned.                           |
| KPI-SEAT-006 | Already booked seats cannot be selected  | Attempt selecting booked seat. Verify frontend disables seat and backend rejects booking request.         |

---

# Module 6: Checkout

| KPI Number  | KPI                                  | Validation Method                                                                           |
| ----------- | ------------------------------------ | ------------------------------------------------------------------------------------------- |
| KPI-CHK-001 | Booking summary is accurate          | Verify selected seats, movie, theater, showtime, pricing, and fees are correctly displayed. |
| KPI-CHK-002 | Convenience fee calculated correctly | Validate fee calculation based on business rules.                                           |
| KPI-CHK-003 | Total payable amount is accurate     | Verify subtotal + convenience fee (+ future taxes) equals displayed total.                  |

---

# Module 7: Payment

| KPI Number  | KPI                                      | Validation Method                                                                              |
| ----------- | ---------------------------------------- | ---------------------------------------------------------------------------------------------- |
| KPI-PAY-001 | Successful payment confirms booking      | Simulate successful payment and verify booking status changes to Confirmed.                    |
| KPI-PAY-002 | Failed payment releases locked seats     | Simulate payment failure and verify locked seats become available after timeout.               |
| KPI-PAY-003 | Duplicate payment attempts are prevented | Submit multiple payment requests for same booking and verify only one payment is processed.    |
| KPI-PAY-004 | Payment timeout handled gracefully       | Simulate payment timeout and verify booking remains incomplete with seats eventually released. |

---

# Module 8: Ticket Generation

| KPI Number     | KPI                                    | Validation Method                                                            |
| -------------- | -------------------------------------- | ---------------------------------------------------------------------------- |
| KPI-TICKET-001 | Digital ticket generated after payment | Verify ticket generation immediately after successful payment.               |
| KPI-TICKET-002 | Unique booking ID generated            | Validate booking ID uniqueness across multiple bookings.                     |
| KPI-TICKET-003 | QR code generated successfully         | Verify QR code exists, is unique, and encodes booking information correctly. |
| KPI-TICKET-004 | Ticket linked to booking               | Validate ticket record references correct booking and user.                  |

---

# Module 9: Booking History

| KPI Number   | KPI                                   | Validation Method                                                         |
| ------------ | ------------------------------------- | ------------------------------------------------------------------------- |
| KPI-HIST-001 | User can view booking history         | Verify authenticated user retrieves only their bookings.                  |
| KPI-HIST-002 | User can open previous ticket         | Validate ticket retrieval using booking history.                          |
| KPI-HIST-003 | Unauthorized booking access prevented | Attempt accessing another user's booking ID and verify HTTP 403 response. |

---

# Module 10: Admin Portal

## Movies

| KPI Number  | KPI                 | Validation Method                                                                          |
| ----------- | ------------------- | ------------------------------------------------------------------------------------------ |
| KPI-ADM-001 | Admin creates movie | Validate movie creation updates database and becomes available for discovery.              |
| KPI-ADM-002 | Admin edits movie   | Verify updated information propagates across all relevant APIs.                            |
| KPI-ADM-003 | Admin deletes movie | Validate deleted movie no longer appears in listings while preserving historical bookings. |

---

## Theaters

| KPI Number  | KPI                    | Validation Method                                                       |
| ----------- | ---------------------- | ----------------------------------------------------------------------- |
| KPI-ADM-004 | Admin manages theaters | Validate CRUD operations for theaters with database consistency checks. |

---

## Screens

| KPI Number  | KPI                   | Validation Method                                         |
| ----------- | --------------------- | --------------------------------------------------------- |
| KPI-ADM-005 | Admin manages screens | Verify CRUD operations update screen inventory correctly. |

---

## Shows

| KPI Number  | KPI                         | Validation Method                                                                  |
| ----------- | --------------------------- | ---------------------------------------------------------------------------------- |
| KPI-ADM-006 | Admin schedules shows       | Validate show creation includes valid movie, screen, timing, and seat inventory.   |
| KPI-ADM-007 | Overlapping shows prevented | Attempt scheduling overlapping shows on same screen and verify validation failure. |

---

## Reports

| KPI Number  | KPI                         | Validation Method                                                      |
| ----------- | --------------------------- | ---------------------------------------------------------------------- |
| KPI-ADM-008 | Admin views booking reports | Verify report data matches booking database records.                   |
| KPI-ADM-009 | RBAC enforced               | Validate only administrator accounts can access admin APIs and portal. |

---

# Module 11: API Performance & Reliability

| KPI Number  | KPI                        | Validation Method                                                                    |
| ----------- | -------------------------- | ------------------------------------------------------------------------------------ |
| KPI-API-001 | Authentication API latency | Verify authentication APIs respond within 500 ms under normal load.                  |
| KPI-API-002 | Movie API latency          | Validate movie listing APIs respond within 300 ms.                                   |
| KPI-API-003 | Booking API performance    | Verify booking completion APIs respond within 1 second excluding payment simulation. |
| KPI-API-004 | API availability           | Monitor APIs and verify uptime ≥99.9%.                                               |
| KPI-API-005 | Error rate                 | Verify application error rate remains below defined SLA threshold.                   |

---

# Module 12: State Management

| KPI Number    | KPI                                                 | Validation Method                                                                                                                                 |
| ------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| KPI-STATE-001 | Booking lifecycle follows defined state transitions | Validate booking transitions sequentially: Initiated → Seats Locked → Payment Pending → Confirmed → Ticket Generated. Reject invalid transitions. |
| KPI-STATE-002 | User session lifecycle managed correctly            | Verify session creation, expiration, renewal, and termination function correctly.                                                                 |
| KPI-STATE-003 | Show lifecycle managed correctly                    | Validate show status transitions (Scheduled, Active, Completed, Cancelled).                                                                       |
| KPI-STATE-004 | Movie lifecycle managed correctly                   | Verify movie transitions (Draft, Published, Archived).                                                                                            |

---

# Module 13: Error Handling

| KPI Number  | KPI                                     | Validation Method                                                                           |
| ----------- | --------------------------------------- | ------------------------------------------------------------------------------------------- |
| KPI-ERR-001 | Validation errors returned consistently | Verify invalid requests return standardized error responses with correct HTTP status codes. |
| KPI-ERR-002 | Authentication errors handled correctly | Validate unauthorized requests return HTTP 401 and forbidden requests return HTTP 403.      |
| KPI-ERR-003 | Booking errors handled gracefully       | Verify seat conflicts return meaningful error without corrupting booking state.             |
| KPI-ERR-004 | Payment errors handled safely           | Validate failed payment never generates confirmed booking or ticket.                        |
| KPI-ERR-005 | Retry strategy functions correctly      | Simulate transient failures and verify retry logic behaves according to specification.      |

---

# Module 14: Edge Case Validation

| KPI Number   | KPI                                         | Validation Method                                                                                            |
| ------------ | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| KPI-EDGE-001 | Simultaneous seat booking handled correctly | Execute concurrent booking requests for identical seats and verify only one succeeds.                        |
| KPI-EDGE-002 | Browser refresh preserves booking state     | Refresh browser during checkout and verify booking/session consistency.                                      |
| KPI-EDGE-003 | Session expiry during checkout              | Expire session before payment and verify secure recovery workflow.                                           |
| KPI-EDGE-004 | Duplicate click prevention                  | Submit repeated booking requests rapidly and verify only one booking is created.                             |
| KPI-EDGE-005 | Network interruption handled                | Simulate network failure during booking and verify recovery without duplicate records.                       |
| KPI-EDGE-006 | Movie removed after booking                 | Remove movie after confirmed booking and verify existing tickets remain valid.                               |
| KPI-EDGE-007 | Show cancellation handled                   | Cancel show after bookings exist and verify booking status updates appropriately.                            |
| KPI-EDGE-008 | City changed during checkout                | Change city mid-checkout and verify booking session is invalidated or restarted according to business rules. |

---

# Overall Product Success KPIs

| KPI Number   | KPI                                           | Validation Method                                                                                     |
| ------------ | --------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| KPI-BUS-001  | Booking conversion rate meets business target | Measure completed bookings divided by initiated booking sessions over a defined period.               |
| KPI-BUS-002  | Booking completion time                       | Verify median booking journey (movie selection to ticket generation) is completed in under 3 minutes. |
| KPI-BUS-003  | Active user growth                            | Monitor daily and monthly active users against product targets.                                       |
| KPI-BUS-004  | Repeat customer rate                          | Measure percentage of users completing multiple bookings within a defined time window.                |
| KPI-PROD-001 | Search success rate                           | Verify search queries return relevant results with minimal zero-result searches.                      |
| KPI-PROD-002 | Seat selection success                        | Measure percentage of seat selection attempts completed without conflicts.                            |
| KPI-PROD-003 | Ticket generation time                        | Verify digital ticket generation completes within 5 seconds after successful payment.                 |
| KPI-TECH-001 | Platform uptime                               | Continuously monitor infrastructure to ensure ≥99.9% availability.                                    |
| KPI-TECH-002 | System error rate                             | Measure unhandled exceptions and failed API requests against SLA thresholds.                          |

This KPI document provides **54 executable validation KPIs**, covering all functional modules, technical quality attributes, business metrics, and edge cases. Each KPI is written as a precise validation instruction suitable for AI-driven automated testing and end-to-end quality assurance.
