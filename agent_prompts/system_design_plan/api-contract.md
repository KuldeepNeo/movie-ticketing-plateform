# API Contract Specification
## Movie Ticketing Platform (BookMyShow Clone)

| Document | REST API Contract Specification |
|---|---|
| **Version** | 1.0 |
| **Status** | Approved |
| **Author** | Senior Solution Architect |
| **Audience** | Frontend Team, Backend Team, QA Team |

---

## 1. API Standards

* **Protocol**: HTTPS only (all endpoints enforce TLS encryption).
* **Data Format**: JSON (`Content-Type: application/json`) for all request bodies and response payloads.
* **Architecture**: RESTful resource-oriented URLs.
* **Base URL**: `https://{domain}/api/v1`
* **Naming Convention**: Lowercase, hyphenated, plural nouns for resources (e.g., `/movies`, `/bookings`, `/show-seats`).
* **HTTP Methods**: `GET` (read), `POST` (create), `PUT` (full update), `PATCH` (partial update), `DELETE` (soft-delete).
* **Versioning**: URL path versioning (e.g., `/api/v1/...`).
* **Character Encoding**: UTF-8.
* **Monetary Values**: All monetary fields are represented as **integers in cents** (e.g., `1550` represents $15.50 / ₹15.50).
* **Date/Time Format**: ISO 8601 UTC strings (e.g., `"2026-06-15T14:30:00Z"`).

---

## 2. Authentication

### Strategy
Stateless JWT-based authentication using Access Tokens and Refresh Tokens.

### Token Types

| Token | Lifetime | Storage | Transport |
|---|---|---|---|
| **Access Token** | 15 minutes | In-memory (Flutter) | `Authorization: Bearer <token>` header |
| **Refresh Token** | 7 days | Flutter Secure Storage / HttpOnly Cookie | `POST /api/v1/auth/refresh` request body or cookie |

### Headers

```
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

### Token Payload (JWT Claims)

```json
{
  "sub": 1,
  "email": "user@example.com",
  "role": "customer",
  "iat": 1718450000,
  "exp": 1718450900
}
```

---

## 3. Standardized Response Format

### Success Response

```json
{
  "status": "success",
  "data": { },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

> `meta` is included only for paginated list endpoints. Single-resource responses omit `meta`.

### Error Response

```json
{
  "status": "error",
  "code": "RESOURCE_NOT_FOUND",
  "message": "The requested movie does not exist.",
  "errors": []
}
```

### Validation Error Response

```json
{
  "status": "error",
  "code": "VALIDATION_ERROR",
  "message": "One or more fields failed validation.",
  "errors": [
    {
      "field": "email",
      "message": "Email address is required."
    },
    {
      "field": "password",
      "message": "Password must be at least 8 characters."
    }
  ]
}
```

---

## 4. Error Codes

| HTTP Status | Code Constant | Description | Use Case |
|---|---|---|---|
| `400` | `VALIDATION_ERROR` | Request body or query parameters failed validation. | Missing fields, invalid format, bad data types. |
| `401` | `UNAUTHORIZED` | Authentication required or token expired. | Missing/invalid/expired JWT. |
| `403` | `FORBIDDEN` | Authenticated but insufficient permissions. | Customer accessing admin routes; accessing another user's booking. |
| `404` | `RESOURCE_NOT_FOUND` | The requested resource does not exist. | Invalid movie ID, show ID, booking ID. |
| `409` | `CONFLICT` | Resource state conflict. | Duplicate email, seat already locked/booked. |
| `410` | `GONE` | Resource is no longer available. | Seat lock expired before payment. |
| `422` | `UNPROCESSABLE_ENTITY` | Semantically invalid request. | Booking exceeding max seat limit, overlapping show times. |
| `429` | `RATE_LIMIT_EXCEEDED` | Too many requests from this client. | Brute-force login attempts. |
| `500` | `INTERNAL_SERVER_ERROR` | Unhandled server error. | Database failures, unhandled exceptions. |

---

## 5. Endpoint Catalogue

### 5.1 Authentication Module

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `POST` | `/api/v1/auth/register` | Register a new user account. | No | Public |
| `POST` | `/api/v1/auth/login` | Authenticate and receive tokens. | No | Public |
| `POST` | `/api/v1/auth/refresh` | Refresh an expired access token. | No | Public |
| `POST` | `/api/v1/auth/logout` | Invalidate the current session. | Yes | Customer, Admin |
| `GET` | `/api/v1/auth/me` | Get the authenticated user's profile. | Yes | Customer, Admin |

### 5.2 City Module

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `GET` | `/api/v1/cities` | List all active cities. | No | Public |

### 5.3 Movie Module

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `GET` | `/api/v1/movies` | List movies (with search, filter, pagination). | No | Public |
| `GET` | `/api/v1/movies/:id` | Get detailed movie information. | No | Public |

### 5.4 Theater & Show Module

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `GET` | `/api/v1/movies/:movieId/shows` | List theaters and showtimes for a movie in a city on a date. | No | Public |
| `GET` | `/api/v1/shows/:showId/seats` | Get seat layout and availability for a specific show. | Yes | Customer |

### 5.5 Booking Module

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `POST` | `/api/v1/bookings` | Lock seats and create a new booking. | Yes | Customer |
| `POST` | `/api/v1/bookings/:id/payment` | Process simulated payment for a booking. | Yes | Customer |
| `GET` | `/api/v1/bookings` | List the authenticated user's booking history. | Yes | Customer |
| `GET` | `/api/v1/bookings/:id` | Get booking details including ticket. | Yes | Customer |

### 5.6 Admin — Movie Management

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `GET` | `/api/v1/admin/movies` | List all movies (including drafts/archived). | Yes | Admin |
| `POST` | `/api/v1/admin/movies` | Create a new movie. | Yes | Admin |
| `PUT` | `/api/v1/admin/movies/:id` | Update movie details. | Yes | Admin |
| `DELETE` | `/api/v1/admin/movies/:id` | Soft-delete a movie. | Yes | Admin |

### 5.7 Admin — Theater Management

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `GET` | `/api/v1/admin/theaters` | List all theaters. | Yes | Admin |
| `POST` | `/api/v1/admin/theaters` | Create a new theater. | Yes | Admin |
| `PUT` | `/api/v1/admin/theaters/:id` | Update theater details. | Yes | Admin |
| `DELETE` | `/api/v1/admin/theaters/:id` | Soft-delete a theater. | Yes | Admin |

### 5.8 Admin — Screen Management

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `GET` | `/api/v1/admin/theaters/:theaterId/screens` | List screens in a theater. | Yes | Admin |
| `POST` | `/api/v1/admin/theaters/:theaterId/screens` | Create a new screen with seat layout. | Yes | Admin |
| `PUT` | `/api/v1/admin/screens/:id` | Update screen details. | Yes | Admin |
| `DELETE` | `/api/v1/admin/screens/:id` | Soft-delete a screen. | Yes | Admin |

### 5.9 Admin — Show Management

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `GET` | `/api/v1/admin/shows` | List all shows with filters. | Yes | Admin |
| `POST` | `/api/v1/admin/shows` | Schedule a new show. | Yes | Admin |
| `PUT` | `/api/v1/admin/shows/:id` | Update show details. | Yes | Admin |
| `DELETE` | `/api/v1/admin/shows/:id` | Cancel/soft-delete a show. | Yes | Admin |

### 5.10 Admin — Reports

| Method | Endpoint | Description | Auth | Role |
|---|---|---|---|---|
| `GET` | `/api/v1/admin/reports/bookings` | Get booking report data. | Yes | Admin |

---

## 6. Detailed Request & Response Contracts

---

### 6.1 Authentication APIs

---

#### `POST /api/v1/auth/register`

Register a new customer account.

**Request Body:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecureP@ss1",
  "confirm_password": "SecureP@ss1"
}
```

**Validation Rules:**
| Field | Rules |
|---|---|
| `name` | Required. String. Min 2 characters. Max 100 characters. |
| `email` | Required. Valid email format. Max 255 characters. |
| `password` | Required. Min 8 characters. Must contain at least 1 uppercase, 1 lowercase, 1 digit, and 1 special character. |
| `confirm_password` | Required. Must match `password`. |

**Success Response: `201 Created`**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "customer",
    "created_at": "2026-06-15T10:30:00Z"
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing or invalid fields. |
| `409` | `CONFLICT` | Email address already registered. |

---

#### `POST /api/v1/auth/login`

Authenticate a user and return JWT tokens.

**Request Body:**

```json
{
  "email": "john@example.com",
  "password": "SecureP@ss1"
}
```

**Validation Rules:**
| Field | Rules |
|---|---|
| `email` | Required. Valid email format. |
| `password` | Required. Non-empty string. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "customer"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "expires_in": 900
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing email or password. |
| `401` | `UNAUTHORIZED` | Invalid email or password. |

---

#### `POST /api/v1/auth/refresh`

Generate a new access token using a valid refresh token.

**Request Body:**

```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

**Validation Rules:**
| Field | Rules |
|---|---|
| `refresh_token` | Required. Non-empty string. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
    "expires_in": 900
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Refresh token is invalid, expired, or revoked. |

---

#### `POST /api/v1/auth/logout`

Invalidate the current session.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:** None.

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "message": "Logged out successfully."
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |

---

#### `GET /api/v1/auth/me`

Get the authenticated user's profile.

**Headers:** `Authorization: Bearer <access_token>`

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "customer",
    "created_at": "2026-06-15T10:30:00Z"
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |

---

### 6.2 City APIs

---

#### `GET /api/v1/cities`

List all active cities.

**Headers:** None required.

**Query Parameters:** None.

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": [
    { "id": 1, "name": "Mumbai" },
    { "id": 2, "name": "Delhi" },
    { "id": 3, "name": "Bengaluru" },
    { "id": 4, "name": "Chennai" },
    { "id": 5, "name": "Hyderabad" },
    { "id": 6, "name": "Kolkata" },
    { "id": 7, "name": "Ahmedabad" }
  ]
}
```

---

### 6.3 Movie APIs

---

#### `GET /api/v1/movies`

List movies currently available in the selected city. Supports search, filtering, sorting, and pagination.

**Headers:** None required.

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `city_id` | Integer | Yes | — | Filter movies by city (shows must exist in theaters within this city). |
| `search` | String | No | — | Search movies by title (case-insensitive partial match). |
| `language` | String | No | — | Filter by language (e.g., `English`, `Hindi`). |
| `genre` | String | No | — | Filter by genre (e.g., `Action`, `Comedy`). |
| `age_rating` | String | No | — | Filter by age rating (e.g., `U/A`, `A`). |
| `sort_by` | String | No | `title` | Sort field. Allowed: `title`, `rating`, `release_date`. |
| `sort_order` | String | No | `asc` | Sort direction. Allowed: `asc`, `desc`. |
| `page` | Integer | No | `1` | Page number for pagination. |
| `limit` | Integer | No | `20` | Records per page. Max: `50`. |

**Example Request:**
```
GET /api/v1/movies?city_id=3&genre=Action&language=English&page=1&limit=10
```

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "title": "Galactic Storm",
      "language": "English",
      "genre": "Action",
      "age_rating": "U/A",
      "runtime_minutes": 148,
      "poster_url": "https://cdn.example.com/posters/galactic-storm.jpg",
      "status": "published"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "total_pages": 1
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing `city_id` or invalid query parameters. |

---

#### `GET /api/v1/movies/:id`

Get detailed information for a specific movie.

**Headers:** None required.

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | Integer | Yes | Movie ID. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "title": "Galactic Storm",
    "synopsis": "A team of astronauts must save Earth from an interstellar threat...",
    "runtime_minutes": 148,
    "language": "English",
    "genre": "Action",
    "age_rating": "U/A",
    "poster_url": "https://cdn.example.com/posters/galactic-storm.jpg",
    "banner_url": "https://cdn.example.com/banners/galactic-storm.jpg",
    "status": "published",
    "created_at": "2026-06-01T08:00:00Z"
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `404` | `RESOURCE_NOT_FOUND` | Movie with this ID does not exist or is soft-deleted. |

---

### 6.4 Theater & Show APIs

---

#### `GET /api/v1/movies/:movieId/shows`

List available theaters and showtimes for a specific movie in a given city on a specific date.

**Headers:** None required.

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `movieId` | Integer | Yes | Movie ID. |

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `city_id` | Integer | Yes | — | City ID to filter theaters. |
| `date` | String | Yes | — | Show date in `YYYY-MM-DD` format. |

**Example Request:**
```
GET /api/v1/movies/1/shows?city_id=3&date=2026-06-20
```

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": [
    {
      "theater": {
        "id": 1,
        "name": "PVR Multiplex",
        "area": "Indiranagar",
        "address": "100 Feet Road, Indiranagar, Bengaluru"
      },
      "shows": [
        {
          "id": 10,
          "screen_name": "Screen 1",
          "start_time": "2026-06-20T10:30:00Z",
          "end_time": "2026-06-20T13:00:00Z",
          "ticket_price": 25000,
          "status": "scheduled"
        },
        {
          "id": 11,
          "screen_name": "IMAX 3D",
          "start_time": "2026-06-20T14:00:00Z",
          "end_time": "2026-06-20T16:30:00Z",
          "ticket_price": 45000,
          "status": "scheduled"
        }
      ]
    },
    {
      "theater": {
        "id": 2,
        "name": "INOX Garuda Mall",
        "area": "MG Road",
        "address": "Garuda Mall, MG Road, Bengaluru"
      },
      "shows": [
        {
          "id": 12,
          "screen_name": "Screen 2",
          "start_time": "2026-06-20T18:45:00Z",
          "end_time": "2026-06-20T21:15:00Z",
          "ticket_price": 30000,
          "status": "scheduled"
        }
      ]
    }
  ]
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing `city_id` or `date`, or invalid date format. |
| `404` | `RESOURCE_NOT_FOUND` | Movie with this ID does not exist. |

---

#### `GET /api/v1/shows/:showId/seats`

Get the interactive seat layout and real-time availability for a specific show.

**Headers:** `Authorization: Bearer <access_token>`

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `showId` | Integer | Yes | Show ID. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "show": {
      "id": 10,
      "movie_title": "Galactic Storm",
      "theater_name": "PVR Multiplex",
      "screen_name": "Screen 1",
      "show_date": "2026-06-20",
      "start_time": "2026-06-20T10:30:00Z",
      "ticket_price": 25000
    },
    "screen": {
      "rows_count": 10,
      "columns_count": 15
    },
    "seats": [
      {
        "id": 1,
        "show_seat_id": 101,
        "row_label": "A",
        "column_number": 1,
        "seat_category": "classic",
        "status": "available"
      },
      {
        "id": 2,
        "show_seat_id": 102,
        "row_label": "A",
        "column_number": 2,
        "seat_category": "classic",
        "status": "booked"
      },
      {
        "id": 3,
        "show_seat_id": 103,
        "row_label": "A",
        "column_number": 3,
        "seat_category": "classic",
        "status": "locked"
      }
    ]
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `404` | `RESOURCE_NOT_FOUND` | Show with this ID does not exist. |

---

### 6.5 Booking APIs

---

#### `POST /api/v1/bookings`

Lock selected seats and initiate a new booking. The system validates seat availability, enforces the maximum booking limit, applies convenience fee, calculates total, and creates a time-limited lock.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**

```json
{
  "show_id": 10,
  "seat_ids": [101, 102, 103]
}
```

> **Note**: `seat_ids` refers to `show_seats.id` values (not `seats.id`), as they represent the transactional availability record for a specific show.

**Validation Rules:**
| Field | Rules |
|---|---|
| `show_id` | Required. Integer. Must reference an active, scheduled show. |
| `seat_ids` | Required. Array of integers. Min 1 seat. Max 10 seats. All must be `available` for the given show. |

**Success Response: `201 Created`**

```json
{
  "status": "success",
  "data": {
    "booking": {
      "id": 501,
      "show_id": 10,
      "status": "seats_locked",
      "seats": [
        { "show_seat_id": 101, "row_label": "A", "column_number": 1, "seat_category": "classic" },
        { "show_seat_id": 102, "row_label": "A", "column_number": 2, "seat_category": "classic" },
        { "show_seat_id": 103, "row_label": "A", "column_number": 3, "seat_category": "classic" }
      ],
      "subtotal": 75000,
      "convenience_fee": 7500,
      "total_amount": 82500,
      "lock_expires_at": "2026-06-20T10:40:00Z",
      "created_at": "2026-06-20T10:30:00Z"
    }
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing fields, empty seat list, or invalid data types. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `404` | `RESOURCE_NOT_FOUND` | Show does not exist or is not active/scheduled. |
| `409` | `CONFLICT` | One or more selected seats are already locked or booked. |
| `422` | `UNPROCESSABLE_ENTITY` | Seat count exceeds maximum booking limit (10). |

---

#### `POST /api/v1/bookings/:id/payment`

Process simulated payment for a locked booking. On success, permanently books seats and generates a digital ticket.

**Headers:** `Authorization: Bearer <access_token>`

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | Integer | Yes | Booking ID. |

**Request Body:**

```json
{
  "payment_method": "simulator"
}
```

**Validation Rules:**
| Field | Rules |
|---|---|
| `payment_method` | Required. String. Allowed: `simulator`. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "booking": {
      "id": 501,
      "status": "confirmed",
      "total_amount": 82500,
      "created_at": "2026-06-20T10:30:00Z"
    },
    "payment": {
      "id": 301,
      "amount": 82500,
      "status": "success",
      "transaction_id": "SIM-TXN-20260620-501",
      "provider": "simulator"
    },
    "ticket": {
      "id": 201,
      "booking_id": 501,
      "qr_code_token": "a1b2c3d4e5f6-booking-501",
      "status": "valid",
      "movie_title": "Galactic Storm",
      "theater_name": "PVR Multiplex",
      "screen_name": "Screen 1",
      "show_date": "2026-06-20",
      "start_time": "2026-06-20T10:30:00Z",
      "seats": ["A1", "A2", "A3"]
    }
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing or invalid payment method. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | Booking does not belong to the authenticated user. |
| `404` | `RESOURCE_NOT_FOUND` | Booking with this ID does not exist. |
| `409` | `CONFLICT` | Booking already confirmed (duplicate payment attempt). |
| `410` | `GONE` | Seat lock has expired. Seats have been released. |

---

#### `GET /api/v1/bookings`

List the authenticated user's booking history. Supports pagination and sorting.

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `status` | String | No | — | Filter by booking status (e.g., `confirmed`, `failed`). |
| `sort_by` | String | No | `created_at` | Sort field. Allowed: `created_at`. |
| `sort_order` | String | No | `desc` | Sort direction. Allowed: `asc`, `desc`. |
| `page` | Integer | No | `1` | Page number. |
| `limit` | Integer | No | `20` | Records per page. Max: `50`. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": [
    {
      "id": 501,
      "movie_title": "Galactic Storm",
      "poster_url": "https://cdn.example.com/posters/galactic-storm.jpg",
      "theater_name": "PVR Multiplex",
      "show_date": "2026-06-20",
      "start_time": "2026-06-20T10:30:00Z",
      "seats": ["A1", "A2", "A3"],
      "total_amount": 82500,
      "status": "confirmed",
      "created_at": "2026-06-20T10:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "total_pages": 1
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |

---

#### `GET /api/v1/bookings/:id`

Get detailed information for a specific booking, including the associated ticket.

**Headers:** `Authorization: Bearer <access_token>`

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | Integer | Yes | Booking ID. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "booking": {
      "id": 501,
      "show_id": 10,
      "status": "confirmed",
      "subtotal": 75000,
      "convenience_fee": 7500,
      "total_amount": 82500,
      "created_at": "2026-06-20T10:30:00Z"
    },
    "show": {
      "movie_title": "Galactic Storm",
      "theater_name": "PVR Multiplex",
      "screen_name": "Screen 1",
      "show_date": "2026-06-20",
      "start_time": "2026-06-20T10:30:00Z"
    },
    "seats": [
      { "row_label": "A", "column_number": 1, "seat_category": "classic" },
      { "row_label": "A", "column_number": 2, "seat_category": "classic" },
      { "row_label": "A", "column_number": 3, "seat_category": "classic" }
    ],
    "payment": {
      "id": 301,
      "amount": 82500,
      "status": "success",
      "transaction_id": "SIM-TXN-20260620-501",
      "provider": "simulator"
    },
    "ticket": {
      "id": 201,
      "qr_code_token": "a1b2c3d4e5f6-booking-501",
      "status": "valid"
    }
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | Booking does not belong to the authenticated user. |
| `404` | `RESOURCE_NOT_FOUND` | Booking with this ID does not exist. |

---

### 6.6 Admin — Movie Management APIs

---

#### `GET /api/v1/admin/movies`

List all movies including drafts and archived (admin view).

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `status` | String | No | — | Filter by status (`draft`, `published`, `archived`). |
| `search` | String | No | — | Search by title. |
| `page` | Integer | No | `1` | Page number. |
| `limit` | Integer | No | `20` | Records per page. Max: `50`. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "title": "Galactic Storm",
      "language": "English",
      "genre": "Action",
      "age_rating": "U/A",
      "runtime_minutes": 148,
      "poster_url": "https://cdn.example.com/posters/galactic-storm.jpg",
      "status": "published",
      "created_at": "2026-06-01T08:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "total_pages": 1
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |

---

#### `POST /api/v1/admin/movies`

Create a new movie entry.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**

```json
{
  "title": "Galactic Storm",
  "synopsis": "A team of astronauts must save Earth from an interstellar threat...",
  "runtime_minutes": 148,
  "language": "English",
  "genre": "Action",
  "age_rating": "U/A",
  "poster_url": "https://cdn.example.com/posters/galactic-storm.jpg",
  "banner_url": "https://cdn.example.com/banners/galactic-storm.jpg",
  "status": "published"
}
```

**Validation Rules:**
| Field | Rules |
|---|---|
| `title` | Required. String. Min 1. Max 255. |
| `synopsis` | Required. String. Min 10. Max 5000. |
| `runtime_minutes` | Required. Integer. Greater than 0. |
| `language` | Required. String. Max 50. |
| `genre` | Required. String. Max 50. |
| `age_rating` | Required. String. Allowed: `U`, `U/A`, `A`, `PG-13`, `R`. |
| `poster_url` | Required. Valid URL string. |
| `banner_url` | Required. Valid URL string. |
| `status` | Optional. Allowed: `draft`, `published`. Default: `draft`. |

**Success Response: `201 Created`**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "title": "Galactic Storm",
    "synopsis": "A team of astronauts must save Earth from an interstellar threat...",
    "runtime_minutes": 148,
    "language": "English",
    "genre": "Action",
    "age_rating": "U/A",
    "poster_url": "https://cdn.example.com/posters/galactic-storm.jpg",
    "banner_url": "https://cdn.example.com/banners/galactic-storm.jpg",
    "status": "published",
    "created_at": "2026-06-01T08:00:00Z"
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing or invalid fields. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |

---

#### `PUT /api/v1/admin/movies/:id`

Update an existing movie's details.

**Headers:** `Authorization: Bearer <access_token>`

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | Integer | Yes | Movie ID. |

**Request Body:** Same schema as `POST /api/v1/admin/movies`. All fields are optional for partial updates.

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "title": "Galactic Storm: Director's Cut",
    "synopsis": "Updated synopsis...",
    "runtime_minutes": 165,
    "language": "English",
    "genre": "Action",
    "age_rating": "U/A",
    "poster_url": "https://cdn.example.com/posters/galactic-storm-dc.jpg",
    "banner_url": "https://cdn.example.com/banners/galactic-storm-dc.jpg",
    "status": "published",
    "updated_at": "2026-06-10T12:00:00Z"
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Invalid field values. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Movie with this ID does not exist. |

---

#### `DELETE /api/v1/admin/movies/:id`

Soft-delete a movie (sets `deleted_at` timestamp). Existing bookings remain valid.

**Headers:** `Authorization: Bearer <access_token>`

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | Integer | Yes | Movie ID. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "message": "Movie deleted successfully."
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Movie with this ID does not exist. |
| `409` | `CONFLICT` | Movie has future scheduled shows. Archive or cancel shows first. |

---

### 6.7 Admin — Theater Management APIs

---

#### `POST /api/v1/admin/theaters`

Create a new theater.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**

```json
{
  "name": "PVR Multiplex",
  "address": "100 Feet Road, Indiranagar, Bengaluru",
  "city_id": 3,
  "area": "Indiranagar"
}
```

**Validation Rules:**
| Field | Rules |
|---|---|
| `name` | Required. String. Min 2. Max 255. |
| `address` | Required. String. Min 5. Max 500. |
| `city_id` | Required. Integer. Must reference an active city. |
| `area` | Required. String. Min 2. Max 100. |

**Success Response: `201 Created`**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "PVR Multiplex",
    "address": "100 Feet Road, Indiranagar, Bengaluru",
    "city_id": 3,
    "area": "Indiranagar",
    "status": "active",
    "created_at": "2026-06-01T08:00:00Z"
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing or invalid fields. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Referenced city does not exist. |

---

#### `PUT /api/v1/admin/theaters/:id`

Update theater details.

**Headers:** `Authorization: Bearer <access_token>`

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | Integer | Yes | Theater ID. |

**Request Body:** Same schema as `POST`. All fields are optional for partial updates.

**Success Response: `200 OK`** (Returns the updated theater object.)

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Invalid field values. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Theater with this ID does not exist. |

---

#### `DELETE /api/v1/admin/theaters/:id`

Soft-delete a theater. Screens and shows must be removed or cancelled first.

**Headers:** `Authorization: Bearer <access_token>`

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "message": "Theater deleted successfully."
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Theater with this ID does not exist. |
| `409` | `CONFLICT` | Theater has active screens or scheduled shows. |

---

### 6.8 Admin — Screen Management APIs

---

#### `POST /api/v1/admin/theaters/:theaterId/screens`

Create a new screen with its seat layout. The system automatically generates seat records based on `rows_count` and `columns_count`.

**Headers:** `Authorization: Bearer <access_token>`

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `theaterId` | Integer | Yes | Theater ID. |

**Request Body:**

```json
{
  "name": "Screen 1",
  "rows_count": 10,
  "columns_count": 15,
  "seat_categories": {
    "A-C": "premium",
    "D-J": "classic"
  }
}
```

**Validation Rules:**
| Field | Rules |
|---|---|
| `name` | Required. String. Min 1. Max 100. |
| `rows_count` | Required. Integer. Min 1. Max 26. |
| `columns_count` | Required. Integer. Min 1. Max 50. |
| `seat_categories` | Optional. Object mapping row ranges to category names. Default: all seats `classic`. |

**Success Response: `201 Created`**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "theater_id": 1,
    "name": "Screen 1",
    "rows_count": 10,
    "columns_count": 15,
    "total_seats": 150,
    "status": "active",
    "created_at": "2026-06-01T08:00:00Z"
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Invalid dimensions or missing required fields. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Theater with this ID does not exist. |

---

### 6.9 Admin — Show Management APIs

---

#### `POST /api/v1/admin/shows`

Schedule a new show. The system automatically generates `show_seats` inventory for every active seat in the screen.

**Headers:** `Authorization: Bearer <access_token>`

**Request Body:**

```json
{
  "movie_id": 1,
  "screen_id": 1,
  "show_date": "2026-06-20",
  "start_time": "2026-06-20T10:30:00Z",
  "end_time": "2026-06-20T13:00:00Z",
  "ticket_price": 25000
}
```

**Validation Rules:**
| Field | Rules |
|---|---|
| `movie_id` | Required. Integer. Must reference a published movie. |
| `screen_id` | Required. Integer. Must reference an active screen. |
| `show_date` | Required. String. `YYYY-MM-DD` format. Must be today or a future date. |
| `start_time` | Required. String. ISO 8601 UTC timestamp. |
| `end_time` | Required. String. ISO 8601 UTC timestamp. Must be after `start_time`. |
| `ticket_price` | Required. Integer. Min 0 (in cents). |

**Business Rules:**
* The system validates that no other show exists on the same `screen_id` with overlapping time ranges on the same `show_date`.
* On creation, the system automatically inserts a `show_seats` record for every active seat in the referenced screen, initialized with `status: 'available'`.

**Success Response: `201 Created`**

```json
{
  "status": "success",
  "data": {
    "id": 10,
    "movie_id": 1,
    "screen_id": 1,
    "show_date": "2026-06-20",
    "start_time": "2026-06-20T10:30:00Z",
    "end_time": "2026-06-20T13:00:00Z",
    "ticket_price": 25000,
    "status": "scheduled",
    "total_seats_created": 150,
    "created_at": "2026-06-15T08:00:00Z"
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Missing or invalid fields. `end_time` before `start_time`. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Movie or screen does not exist. |
| `422` | `UNPROCESSABLE_ENTITY` | Overlapping show on the same screen and date. |

---

#### `PUT /api/v1/admin/shows/:id`

Update show details (timing, price). Only allowed if no bookings exist for the show.

**Headers:** `Authorization: Bearer <access_token>`

**Path Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | Integer | Yes | Show ID. |

**Request Body:** Same schema as `POST`. All fields optional.

**Success Response: `200 OK`** (Returns the updated show object.)

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Invalid field values. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Show with this ID does not exist. |
| `409` | `CONFLICT` | Show has existing bookings. Cannot modify. |
| `422` | `UNPROCESSABLE_ENTITY` | Updated time range overlaps with another show. |

---

#### `DELETE /api/v1/admin/shows/:id`

Cancel/soft-delete a show. Existing confirmed bookings are updated to `cancelled` status.

**Headers:** `Authorization: Bearer <access_token>`

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "message": "Show cancelled successfully.",
    "affected_bookings": 3
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |
| `404` | `RESOURCE_NOT_FOUND` | Show with this ID does not exist. |

---

### 6.10 Admin — Reports API

---

#### `GET /api/v1/admin/reports/bookings`

Get booking report data with aggregate statistics.

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `start_date` | String | No | — | Filter bookings from this date (inclusive). `YYYY-MM-DD`. |
| `end_date` | String | No | — | Filter bookings up to this date (inclusive). `YYYY-MM-DD`. |
| `movie_id` | Integer | No | — | Filter by specific movie. |
| `theater_id` | Integer | No | — | Filter by specific theater. |
| `city_id` | Integer | No | — | Filter by specific city. |

**Success Response: `200 OK`**

```json
{
  "status": "success",
  "data": {
    "summary": {
      "total_bookings": 1250,
      "confirmed_bookings": 1100,
      "failed_bookings": 100,
      "cancelled_bookings": 50,
      "total_revenue": 27500000,
      "total_seats_booked": 3500
    },
    "by_movie": [
      {
        "movie_id": 1,
        "movie_title": "Galactic Storm",
        "bookings_count": 450,
        "revenue": 11250000,
        "occupancy_rate": 78.5
      }
    ],
    "by_theater": [
      {
        "theater_id": 1,
        "theater_name": "PVR Multiplex",
        "city_name": "Bengaluru",
        "bookings_count": 320,
        "revenue": 8000000,
        "occupancy_rate": 82.1
      }
    ]
  }
}
```

**Error Responses:**
| Status | Code | Condition |
|---|---|---|
| `400` | `VALIDATION_ERROR` | Invalid date format or range. |
| `401` | `UNAUTHORIZED` | Missing or invalid access token. |
| `403` | `FORBIDDEN` | User is not an administrator. |

---

## 7. Pagination Strategy

All list endpoints that may return large datasets support **offset-based pagination** using the following query parameters:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `page` | Integer | `1` | The page number to retrieve (1-indexed). |
| `limit` | Integer | `20` | Number of records per page. Min: `1`. Max: `50`. |

### Pagination Response (`meta` object)

```json
{
  "meta": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

### Paginated Endpoints
* `GET /api/v1/movies`
* `GET /api/v1/bookings`
* `GET /api/v1/admin/movies`
* `GET /api/v1/admin/theaters`
* `GET /api/v1/admin/shows`

---

## 8. Filtering Strategy

### Search
* **Parameter**: `search`
* **Behavior**: Case-insensitive partial match on the primary text field of the resource (e.g., `title` for movies).
* **Example**: `GET /api/v1/movies?city_id=3&search=galactic`

### Tag / Attribute Filters
* Discrete filters applied via query parameters:
  * `language`, `genre`, `age_rating` for movies.
  * `status` for admin movie/show/booking lists.
  * `city_id` for movie and theater queries.
* **Example**: `GET /api/v1/movies?city_id=3&genre=Action&language=Hindi`

### Date Range
* `start_date` and `end_date` parameters for time-bounded queries.
* **Example**: `GET /api/v1/admin/reports/bookings?start_date=2026-06-01&end_date=2026-06-30`

### Sorting
* **Parameter**: `sort_by` (field name) and `sort_order` (`asc` or `desc`).
* **Default**: Resource-specific (e.g., `title` asc for movies, `created_at` desc for bookings).
* **Example**: `GET /api/v1/bookings?sort_by=created_at&sort_order=desc`

---

## 9. API Versioning

### Strategy
**URL Path Versioning**: All endpoints are prefixed with `/api/v1/`. This provides explicit, visible versioning that is easy to route at the reverse proxy (Nginx) level.

### Current Version
* `v1` — Initial release covering all MVP modules.

### Future Version Policy
* `v2` — Reserved for breaking changes (e.g., real payment gateway integration, new entity structures).
* **Deprecation Policy**: When a new version is released, the previous version will be supported for a minimum of **6 months** with deprecation warnings in response headers (`Sunset: <date>`, `Deprecation: true`).
* **Non-Breaking Changes**: Additive changes (new optional fields, new endpoints) are released within the current version without incrementing.

---

## 10. Security

### Rate Limiting

| Endpoint Group | Limit | Window |
|---|---|---|
| `/api/v1/auth/login` | 10 requests | 15 minutes per IP |
| `/api/v1/auth/register` | 5 requests | 15 minutes per IP |
| `/api/v1/auth/refresh` | 20 requests | 15 minutes per IP |
| `/api/v1/bookings` (POST) | 10 requests | 5 minutes per user |
| All other endpoints | 100 requests | 15 minutes per IP |

Rate limit headers included in every response:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 97
X-RateLimit-Reset: 1718450900
```

When exceeded, the API returns:
```json
{
  "status": "error",
  "code": "RATE_LIMIT_EXCEEDED",
  "message": "Too many requests. Please try again later.",
  "errors": []
}
```

### CORS Policy
* **Allowed Origins**: Configured per environment (e.g., `https://app.example.com`, `http://localhost:3000` for development).
* **Allowed Methods**: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`.
* **Allowed Headers**: `Content-Type`, `Authorization`, `Accept`.
* **Credentials**: `true` (to support HttpOnly cookie-based refresh tokens on web).

### Authentication Enforcement
* All endpoints except those marked `Auth: No` in the endpoint catalogue require a valid JWT in the `Authorization` header.
* Expired tokens return `401 UNAUTHORIZED` with `code: "TOKEN_EXPIRED"`.

### Authorization Enforcement (RBAC)
* Middleware validates the `role` claim in the JWT payload against the required role for each route.
* Customer attempting admin routes returns `403 FORBIDDEN`.
* Users can only access their own bookings; accessing another user's booking returns `403 FORBIDDEN`.

### Input Validation
* All request bodies are validated against Zod/Joi schemas before reaching the controller logic.
* Path parameters and query parameters are type-checked and sanitized.
* SQL injection is prevented by Knex.js parameterized queries.

### Security Headers
* Enforced via `helmet` middleware:
  * `X-Content-Type-Options: nosniff`
  * `X-Frame-Options: DENY`
  * `Strict-Transport-Security: max-age=31536000; includeSubDomains`
  * `X-XSS-Protection: 0` (modern browsers use CSP instead)
  * `Content-Security-Policy: default-src 'self'`
