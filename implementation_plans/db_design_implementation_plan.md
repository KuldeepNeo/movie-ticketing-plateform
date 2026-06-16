# Implementation Plan - Generate Database Design

This plan outlines the approach to create the comprehensive `database-design.md` document for the Movie Ticketing Platform (BookMyShow Clone) under the `agent_prompts/system_design_plan/` directory.

## Proposed Changes

We will create a database design document matching the requested template:

### [Database Design Plan]

#### [NEW] [database-design.md](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/system_design_plan/database-design-template.md) (Actually generating database-design.md)

We will write a comprehensive database design document containing:
1. **Database Information**: SQLite 3 as the primary engine (for development/MVP), character set, naming conventions (`snake_case`), and storage choices.
2. **Entity List**: High-level identification of all entities (Users, Cities, Movies, Theaters, Screens, Seats, Showtimes, ShowtimeSeats, Bookings, Payments, Tickets).
3. **Entity Relationship Diagram (ERD)**: A detailed Mermaid diagram outlining relationships, primary keys, foreign keys, and cardinalities.
4. **Table Definitions & Column Definitions**: Schema definitions for all 11 tables, including column types (using SQLite types), nullability, defaults, keys, and constraints.
5. **Data Types & SQLite Specifics**: Explanation of SQLite storage classes (INTEGER, TEXT, REAL) and how we handle dates (ISO 8601 strings) and monetary values (integers in cents to avoid floating-point inaccuracies).
6. **Constraints**: Define UNIQUE constraints (e.g. emails, show seat combinations), CHECK constraints (e.g. positive amounts, status values, runtime boundaries), and NOT NULL constraints.
7. **Primary Keys**: Key generation strategies (auto-incrementing integers for SQLite, UUIDs for PostgreSQL migration).
8. **Foreign Keys**: Specific delete/update rules (e.g., `ON DELETE CASCADE` for screen seats, `ON DELETE RESTRICT` for movies/screens with scheduled shows to avoid data loss).
9. **Index Strategy**: Target performance optimizations for search (movies), schedules (show dates/times), seat layouts, and user booking lookups.
10. **Normalization Analysis**: Trace the schema normalization state through 1NF, 2NF, and 3NF, detailing why each entity meets 3NF.
11. **Audit & Soft Delete Strategy**: Common audit columns (`created_at`, `updated_at`, `created_by`, `updated_by`) and soft delete columns (`deleted_at`, `deleted_by`) to preserve historical tickets/reporting.
12. **Migration & Seed Strategy**: Initial schemas and seed setup.
13. **Future Scalability**: Sharding, partitioning, PostgreSQL sharding, and caching strategies.

## Verification Plan

### Manual Verification
- Review the Mermaid ERD syntax to ensure proper rendering.
- Cross-reference table columns and relationships with the PRD requirements and the user persona rules (RBAC dependencies).
