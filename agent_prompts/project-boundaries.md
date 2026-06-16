# project-boundaries.md

# Movie Ticketing Platform (BookMyShow Clone)

## Included Scope

The project includes the design, development, testing, and deployment of a Minimum Viable Product (MVP) for an online movie ticket booking platform supporting end-to-end booking operations.

### 1. User Management

* User registration
* User authentication (login/logout)
* Session management
* Password encryption
* Protected user APIs

### 2. City Management

* Select city
* Change city
* City-specific movie listings

### 3. Movie Discovery

* Browse currently available movies
* Search movies by title
* Filter by language, genre, rating, and format
* View detailed movie information
* Display posters, synopsis, cast, duration, language, and ratings

### 4. Theater & Show Management

* View theaters for selected movie
* Browse show dates and timings
* Display screen-wise show availability

### 5. Seat Booking

* Interactive seat selection
* Real-time seat availability
* Seat locking mechanism
* Booking limit validation
* Prevention of duplicate seat booking
* Automatic seat lock expiration

### 6. Checkout

* Booking summary
* Ticket price calculation
* Convenience fee calculation
* Total payable amount

### 7. Payment

* Simulated payment processing
* Payment success workflow
* Payment failure handling
* Payment timeout handling
* Duplicate payment prevention

### 8. Ticket Generation

* Digital ticket generation
* Unique booking ID
* QR code generation
* Ticket linked to booking

### 9. Booking History

* View previous bookings
* Access digital tickets
* Authorization checks for booking ownership

### 10. Admin Portal

* Movie CRUD
* Theater CRUD
* Screen CRUD
* Show scheduling
* Booking reports
* Role-Based Access Control (RBAC)

### 11. System Quality

* API performance monitoring
* Booking lifecycle management
* Session lifecycle management
* Movie and show lifecycle management
* Standardized error handling
* Edge case validation
* Concurrency handling for seat booking

---

# Technical Constraints

## Architecture

* Modular architecture with clear separation of frontend, backend, and database layers.
* RESTful API communication.
* Stateless authentication using JWT or equivalent session mechanism.

## Security

* Passwords must be securely hashed.
* Authentication required for protected resources.
* Authorization enforced for administrative operations.
* Users can only access their own bookings.

## Performance

* Authentication APIs should respond within **500 ms**.
* Movie listing APIs should respond within **300 ms**.
* Booking completion APIs should respond within **1 second** (excluding payment simulation).
* Platform availability target of **99.9%**.
* Support hundreds of concurrent booking requests.

## Data Consistency

* Seat locking must prevent double booking.
* Booking lifecycle must follow valid state transitions.
* Payment and booking operations should be transactional where applicable.

## Scalability

* Support multiple cities.
* Support hundreds of theaters and screens.
* Allow future integration of real payment gateways without major architectural changes.

## Compatibility

* Responsive user interface for desktop, tablet, and mobile devices.
* Modern web browsers supported.

---

# Assumptions

* Payment processing is simulated for the MVP.
* Movies, theaters, screens, and shows are managed exclusively through the admin portal.
* Theater seat layouts are predefined.
* Internet connectivity is available during booking.
* Users register using a unique email address.
* Each booking is associated with a single authenticated user.
* QR codes are generated digitally and are sufficient for ticket validation.
* City selection determines all movie and theater availability.
* Convenience fee rules are predefined and configurable.
* Historical bookings remain accessible even if movies are archived or removed.

---

# Risks

## Functional Risks

* Concurrent seat booking may lead to race conditions if locking is improperly implemented.
* Inconsistent booking state during payment failures.
* Session expiration during checkout affecting user experience.
* Duplicate booking requests caused by repeated user actions.

## Technical Risks

* Performance degradation under peak booking traffic.
* Database contention during high concurrency.
* API latency impacting booking completion.
* Inadequate transaction handling causing data inconsistency.

## Security Risks

* Unauthorized access to user bookings.
* Privilege escalation within the admin portal.
* Token misuse or session hijacking.
* Exposure of sensitive user information.

## Operational Risks

* Incorrect movie or show schedules entered by administrators.
* Show cancellations after bookings have been confirmed.
* Data synchronization issues between theaters and the platform.

---

## Boundary Summary

### In Scope

* Complete end-to-end movie ticket booking workflow
* Admin management for movies, theaters, screens, and shows
* Simulated payment
* Digital ticket generation
* Booking history
* Secure authentication and authorization
* Real-time seat locking and booking consistency
* Performance, reliability, and edge-case validation aligned with the defined KPIs.  

### Out of Scope

* Production payment gateway integration
* Refunds and cancellations
* Food ordering
* Loyalty and rewards
* Notifications (email/SMS/push)
* User reviews and recommendations
* Dynamic pricing
* Ticket scanning hardware integration
* Marketing campaigns
* Live events and non-movie ticketing
* Multi-language localization
* Advanced analytics beyond basic booking reports
