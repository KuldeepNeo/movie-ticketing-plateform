# Implementation Plan - Implementation Roadmap Generation

This plan outlines the approach to generate the `implementation-roadmap.md` document for the Movie Ticketing Platform, acting as the Senior Technical Lead.

## Proposed Changes

We will translate the business-focused Sprint Roadmap into a highly detailed, technical Implementation Roadmap. This document will dictate the exact execution sequence for Backend Engineers, Frontend Engineers, and QA.

### [Implementation Roadmap Plan]

#### [NEW] [implementation-roadmap.md](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/implementation-roadmap.md)

We will document the technical roadmap with the following structure, strictly adhering to the Senior Technical Lead persona guidelines:

1. **Global Planning Principles**: Reiterate the strict execution order (Foundation → DB → Backend → Frontend → Testing → Integration).
2. **Sprint-by-Sprint Technical Breakdown (Sprints 1-6)**:
   For every sprint, we will generate:
   - **Sprint Goal**: The business/technical objective.
   - **Implementation Order**: An ordered list of steps guaranteeing APIs exist before frontend development, and DB exists before APIs.
   - **Backend Tasks**: Specific development tasks (migrations, models, services, controllers).
   - **Frontend Tasks**: Specific UI tasks (screens, Riverpod state controllers, API integration).
   - **QA Tasks**: Testing activities tied to the `master-kpi.md`.
   - **Deliverables**: Tangible outputs.
   - **Dependencies**: Internal, external, and blocking items.
   - **Definition of Done**: Clear completion criteria.
   - **Risk Assessment**: Technical, Business, Performance, and Security risks with mitigations.
3. **Module Implementation Details (Tabular Format)**:
   A comprehensive table detailing every module containing:
   - Module Name
   - Feature IDs
   - BDD Scenario References
   - Database Tables
   - API Endpoints
   - Frontend Pages
   - Backend Components
   - Testing Activities
   - Acceptance Criteria
   - Estimated Complexity
   - Dependencies

*Constraint Check*: The document will strictly be a planning artifact. It will not generate any application source code, SQL scripts, or API implementation code. It will be saved to `agent_prompts/implementation-roadmap.md`.

## Verification Plan

### Manual Verification
- Review the generated roadmap to ensure the implementation order strictly follows DB -> API -> UI.
- Verify that all Sprints (1 to 6) from the `sprint_plan.md` are translated into technical tasks.
- Ensure the Module Implementation section uses the required tabular format and includes all specified columns.
