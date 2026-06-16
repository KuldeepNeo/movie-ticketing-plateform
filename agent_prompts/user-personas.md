# user-personas.md

# Movie Ticketing Platform (BookMyShow Clone)

## Document Information

| Item     | Value                                                                              |
| -------- | ---------------------------------------------------------------------------------- |
| Document | User Personas                                                                      |
| Product  | Movie Ticketing Platform                                                           |
| Version  | 1.0                                                                                |
| Status   | Approved                                                                           |
| Audience | Product Manager, UX Designer, Frontend Developer, Backend Developer, QA, AI Agents |

---

# Purpose

This document defines the different user personas that interact with the Movie Ticketing Platform. It outlines their goals, responsibilities, permissions, pain points, and system interactions.

The personas serve as the foundation for:

* User Experience Design
* Feature Development
* Functional Testing
* Authorization Rules
* Acceptance Testing
* Future Enhancements

---

# User Types

The platform consists of three primary user roles:

1. Guest User
2. Registered User (Customer)
3. System Administrator

---

# Persona 1 — Guest User

## Description

A Guest User is someone who visits the platform without creating an account or logging in.

The primary objective of the Guest User is to explore the platform and discover movies before deciding to register.

---

## Goals

* Explore currently playing movies
* View movie information
* Understand available theaters
* Decide whether to create an account

---

## Permissions

### Allowed

* View Homepage
* Browse movies
* Search movies
* Filter movies
* View movie details
* View theater list
* View available showtimes

### Restricted

* Book Tickets
* Select Seats
* Checkout
* Make Payment
* View Bookings
* Save Favorite Movies
* Access User Profile

---

## Pain Points

* Cannot reserve seats
* Cannot complete bookings
* Must register before purchasing tickets

---

## Typical Journey

Landing Page

↓

Browse Movies

↓

Search Movie

↓

Movie Details

↓

Click "Book Tickets"

↓

Redirect to Login/Register

---

# Persona 2 — Registered User (Customer)

## Description

A Registered User is an authenticated customer who can access the complete booking experience.

This is the primary user of the platform.

---

## Goals

* Book movie tickets
* Discover movies
* Find nearby theaters
* Choose preferred seats
* Receive digital tickets
* Access booking history

---

## Responsibilities

* Maintain valid account information
* Select correct city
* Review booking details before payment

---

## Permissions

### Account

* Register
* Login
* Logout
* Update Profile (future enhancement)
* Change Current City

---

### Movies

* Browse movies
* Search movies
* Filter movies
* View movie details

---

### Booking

* View theaters
* Select date
* Select showtime
* Select seats
* Deselect seats
* View booking summary
* Simulate payment
* Receive digital ticket

---

### Bookings

* View booking history
* View digital ticket
* Retrieve previous bookings

---

## Restrictions

Registered users cannot:

* Modify theater information
* Add movies
* Edit show schedules
* Change ticket pricing
* Book already reserved seats
* Access another user's bookings

---

## Pain Points

* Desired seats may already be booked
* Preferred showtime may be sold out
* Movie may not be available in selected city

---

## Primary User Journey

Login

↓

Select City

↓

Browse Movies

↓

Movie Details

↓

Book Tickets

↓

Choose Date

↓

Choose Theater

↓

Choose Showtime

↓

Seat Selection

↓

Booking Summary

↓

Payment

↓

Digital Ticket

↓

My Bookings

---

## Success Criteria

The user should be able to complete the entire booking process without encountering ambiguity or unnecessary friction.

---

# Persona 3 — System Administrator

## Description

The System Administrator manages platform content and operational data.

Administrators do not participate in the customer booking journey but ensure the platform remains updated and functional.

---

## Goals

* Keep movie listings updated
* Manage theaters
* Configure showtimes
* Monitor bookings
* Maintain system accuracy

---

## Responsibilities

* Add new movies
* Update movie information
* Remove inactive movies
* Add theaters
* Manage screens
* Configure show schedules
* Maintain city availability
* Monitor booking activity

---

## Permissions

### Movie Management

* Create movie
* Update movie
* Delete movie
* Upload movie poster
* Update synopsis
* Update cast and crew
* Configure runtime
* Configure language
* Configure genre
* Configure age rating

---

### Theater Management

* Create theater
* Edit theater
* Remove theater
* Manage screens
* Configure seating layout

---

### Show Management

* Create show
* Update show
* Delete show
* Configure ticket price
* Configure show dates
* Configure show timings

---

### Booking Management

* View bookings
* Monitor occupancy
* Generate booking reports

---

## Restrictions

Administrator cannot:

* View user passwords
* Modify completed bookings
* Change booking history
* Override booked seats after confirmation

---

## Success Criteria

Maintain accurate and up-to-date platform data while ensuring uninterrupted booking operations.

---

# Role Permission Matrix

| Feature              | Guest | Registered User | Administrator |
| -------------------- | :---: | :-------------: | :-----------: |
| Browse Movies        |   ✅   |        ✅        |       ✅       |
| Search Movies        |   ✅   |        ✅        |       ✅       |
| Filter Movies        |   ✅   |        ✅        |       ✅       |
| View Movie Details   |   ✅   |        ✅        |       ✅       |
| Register Account     |   ✅   |        ❌        |       ❌       |
| Login                |   ✅   |        ✅        |       ✅       |
| Change City          |   ❌   |        ✅        |       ✅       |
| Book Tickets         |   ❌   |        ✅        |       ❌       |
| Select Seats         |   ❌   |        ✅        |       ❌       |
| Checkout             |   ❌   |        ✅        |       ❌       |
| Simulated Payment    |   ❌   |        ✅        |       ❌       |
| Digital Ticket       |   ❌   |        ✅        |       ❌       |
| My Bookings          |   ❌   |        ✅        |       ❌       |
| Manage Movies        |   ❌   |        ❌        |       ✅       |
| Manage Theaters      |   ❌   |        ❌        |       ✅       |
| Manage Shows         |   ❌   |        ❌        |       ✅       |
| View Booking Reports |   ❌   |        ❌        |       ✅       |

---

# Authorization Rules

## Guest User

* Authentication not required.
* Read-only access to public content.
* Attempting to book tickets redirects to Login/Register.

---

## Registered User

* Authentication required.
* Can only access their own profile and bookings.
* Cannot modify system data.
* Can only book available seats.

---

## Administrator

* Authentication required.
* Elevated privileges.
* Full access to management modules.
* Restricted from accessing sensitive user credentials.

---

# Design Considerations

The user interface should adapt based on the active user role.

## Guest User

Display:

* Register
* Login

Hide:

* My Bookings
* Logout
* Profile

---

## Registered User

Display:

* My Bookings
* Change City
* Logout
* User Profile

Hide:

* Admin Controls

---

## Administrator

Display:

* Dashboard
* Movie Management
* Theater Management
* Show Management
* Reports

Hide:

* Customer Booking Flow

---

# Persona Summary

| Persona              | Primary Objective                        | Authentication Required |
| -------------------- | ---------------------------------------- | ----------------------- |
| Guest User           | Explore movies and register              | No                      |
| Registered User      | Discover, book, and manage movie tickets | Yes                     |
| System Administrator | Manage platform content and operations   | Yes                     |

---

# Definition of Done

The platform shall enforce role-based access control (RBAC) such that:

* Guests can browse but cannot book.
* Registered Users can complete the full booking lifecycle and access only their own data.
* Administrators can manage platform content and operational data without interfering with completed customer bookings.

These personas form the foundation for UI behavior, navigation, authorization, API access control, and QA test scenarios throughout the Movie Ticketing Platform.
