# user-flows.md

# Movie Ticketing Platform (BookMyShow Clone)

---

# Document Information

| Item     | Value                                                    |
| -------- | -------------------------------------------------------- |
| Document | User Flows                                               |
| Version  | 2.0                                                      |
| Status   | Approved                                                 |
| Purpose  | Source of Truth for User Journey                         |
| Audience | Product Manager, UI/UX, Frontend, Backend, QA, AI Agents |

---

# Purpose

This document defines every user journey supported by the platform.

It serves as the single source of truth for:

* Frontend Development
* Backend Development
* QA Test Cases
* API Integration
* Navigation Logic
* Access Control

---

# Supported User Personas

| Persona              | Description                                                                |
| -------------------- | -------------------------------------------------------------------------- |
| Guest User           | Visitor without authentication                                             |
| Registered User      | Authenticated customer who can book tickets                                |
| System Administrator | Platform administrator responsible for managing movies, theatres and shows |

---

# Global Navigation

## Guest Navigation

* Logo
* Home
* Search
* Login
* Register

---

## Registered User Navigation

* Logo
* Home
* Search
* Current City
* My Bookings
* Profile
* Logout

---

## Administrator Navigation

* Dashboard
* Movies
* Theatres
* Screens
* Shows
* Reports
* Logout

---

# USER FLOW SECTION A

# Guest User Flows

---

# UF-001 Landing Page

### Entry

User visits website.

### Display

* Hero Banner
* Now Showing Movies
* Search Bar
* Genre Filters
* Login
* Register

### Available Actions

* Browse Movies
* Search Movies
* Filter Movies
* Open Movie Details
* Login
* Register

### Restricted Actions

* Book Tickets
* Checkout
* My Bookings

### Success

Guest continues browsing.

---

# UF-002 Search Movies

Guest types movie name.

System filters movie cards instantly.

If no movie exists

Display

"No movies found."

---

# UF-003 Filter Movies

Guest selects Genre.

Examples

* Action
* Comedy
* Horror
* Drama

System displays matching movies.

---

# UF-004 Movie Details

Guest opens Movie Details.

Display

* Banner
* Poster
* Synopsis
* Cast
* Runtime
* Rating
* Language

CTA

Book Tickets

---

When Guest clicks

Book Tickets

↓

System redirects

↓

Login Page

---

# UF-005 Registration

Guest opens Register.

Inputs

* Name
* Email
* Password
* Confirm Password

Validation

* Email unique
* Password valid
* Passwords match

Success

↓

Login

Failure

Remain on Register page.

---

# UF-006 Login

Guest enters credentials.

Success

↓

City Selection (First Login)

or

Homepage

Failure

Display

Invalid credentials.

---

# USER FLOW SECTION B

# Registered User Flows

---

# UF-101 City Selection

Trigger

First Login

or

Change City

Display

Available Cities

User

Select City

↓

Save

System

Updates

* Movies
* Theatres
* Showtimes

---

# UF-102 Homepage

Display

* Current City
* Now Showing
* Search
* Filters
* Navigation

User can

* Search
* Filter
* Change City
* Open Movie Details

---

# UF-103 Movie Details

Display

* Banner
* Synopsis
* Cast
* Crew
* Runtime
* Language
* Rating

CTA

Book Tickets

---

# UF-104 Theatre Selection

Display

Date Selector

↓

Available Theatres

↓

Available Showtimes

User selects

Date

↓

Theatre

↓

Showtime

Success

↓

Seat Selection

---

# UF-105 Seat Selection

Display

SCREEN

↓

Seat Grid

Seat States

Available

Booked

Selected

Summary Panel

Movie

Seats

Price

Convenience Fee

Grand Total

User

Select Seats

↓

Summary Updates

↓

Proceed to Payment

Validation

* Seat available
* Minimum one seat
* Maximum booking limit

---

# UF-106 Checkout

Display

Movie

Theatre

Date

Time

Seats

Subtotal

Convenience Fee

Total

User

Confirm & Pay

---

# UF-107 Payment

Current Version

Simulated Payment

Success

↓

Booking Created

↓

Seats Locked

↓

Digital Ticket Generated

Failure (Future)

↓

Unlock Seats

↓

Retry

---

# UF-108 Digital Ticket

Display

* Booking ID
* QR Placeholder
* Movie
* Theatre
* Showtime
* Seats

Actions

View Booking

Back Home

---

# UF-109 My Bookings

Display

Booking History

Each Booking

* Poster
* Movie
* Booking ID
* Date
* Time
* Seats
* Status

User can

View Ticket

---

# UF-110 Logout

Destroy Session

↓

Login

---

# USER FLOW SECTION C

# Administrator Flows

---

# UF-201 Admin Login

Administrator enters credentials.

Success

↓

Dashboard

Failure

Display error.

---

# UF-202 Dashboard

Display

* Total Movies
* Total Cities
* Total Theatres
* Today's Shows
* Total Bookings
* Active Screens

Navigation

Movies

Theatres

Screens

Shows

Reports

Logout

---

# UF-203 Movie Management

Movies

↓

Movie List

↓

Add Movie

Edit Movie

Delete Movie

Movie Fields

* Poster
* Banner
* Title
* Runtime
* Language
* Genre
* Rating
* Synopsis
* Cast
* Crew

Save

↓

Movie available on Homepage.

---

# UF-204 Theatre Management

Theatre List

↓

Add Theatre

↓

Update Theatre

↓

Delete Theatre

Fields

* Name
* Address
* City
* Area

---

# UF-205 Screen Management

Select Theatre

↓

Create Screen

↓

Configure

* Rows
* Columns
* Seat Categories

↓

Save

---

# UF-206 Show Management

Create Show

Movie

↓

Theatre

↓

Screen

↓

Date

↓

Start Time

↓

End Time

↓

Ticket Price

↓

Save

System automatically creates seat inventory.

---

# UF-207 Booking Reports

Administrator can view

* Daily Bookings
* Movie Occupancy
* Theatre Occupancy
* Revenue (Future)
* Popular Movies

---

# UF-208 Admin Logout

Logout

↓

Admin Login

---

# Navigation Rules

## Guest

Landing

↓

Movies

↓

Movie Details

↓

Login

↓

Register

---

## Registered User

Homepage

↓

Movie Details

↓

Theatre

↓

Showtime

↓

Seat Selection

↓

Checkout

↓

Payment

↓

Digital Ticket

↓

My Bookings

---

## Administrator

Dashboard

↓

Movies

↓

Theatres

↓

Screens

↓

Shows

↓

Reports

↓

Logout

---

# Error Flows

Authentication Errors

* Invalid Login
* Duplicate Email

Booking Errors

* Seat Already Booked
* No Seats Selected
* No Shows Available
* Movie Not Available

Admin Errors

* Duplicate Theatre
* Invalid Show Timing
* Missing Required Fields

---

# Edge Cases

Guest tries direct URL

↓

Redirect Login

---

Expired Session

↓

Login

---

Seat booked by another user

↓

Refresh Seat Layout

---

Double-click Payment

↓

Single Booking Created

---

Browser Refresh during Checkout

↓

Restore Booking Session (if supported)

---

# QA Coverage Matrix

Guest Flows

UF-001 → UF-006

Registered User Flows

UF-101 → UF-110

Administrator Flows

UF-201 → UF-208

Every flow must have:

* Positive Test Cases
* Negative Test Cases
* Validation Tests
* Permission Tests
* Navigation Tests
* API Tests
* UI Verification

---

# Flow Dependency Matrix

| Flow   | Depends On |
| ------ | ---------- |
| UF-002 | UF-001     |
| UF-004 | UF-001     |
| UF-101 | UF-006     |
| UF-102 | UF-101     |
| UF-103 | UF-102     |
| UF-104 | UF-103     |
| UF-105 | UF-104     |
| UF-106 | UF-105     |
| UF-107 | UF-106     |
| UF-108 | UF-107     |
| UF-109 | UF-107     |
| UF-202 | UF-201     |
| UF-203 | UF-202     |
| UF-204 | UF-202     |
| UF-205 | UF-204     |
| UF-206 | UF-205     |
| UF-207 | UF-202     |

---

# Definition of Done

The application is considered functionally complete when:

* Guests can browse and discover movies but cannot initiate bookings.
* Registered users can complete the entire booking lifecycle from authentication to viewing their digital ticket in **My Bookings**.
* Administrators can manage movies, theatres, screens, show schedules, and operational reports through the admin dashboard.
* All user flows (UF-001 to UF-208) are fully implemented, validated, and covered by automated and manual QA tests.
