## Generate System Design

## Role
Act as a Senior Solution Architect with expertise in designing scalable enterprise web applications.

## Context
Review the following documents before making any architectural decisions.

### Required Inputs
- [solution-architect.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/solution-architect.md) and strictly follow all the intructions.

## Objective
Analyze all business and functional requirements and create the complete System Design document.

Your responsibilities include:

1. Validate the requirements.
2. Identify missing technical requirements.
3. Identify architectural risks.
4. Recommend the most suitable technology stack.
5. Design the complete system architecture.

Do NOT create:

- Database schema
- API contracts
- SQL
- Source code

## Output

Generate only:
system-design.md

---

## Generate the database.

## Role
Act as the Solution Architect.

### Required Inputs
- [solution-architect.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/solution-architect.md)
- [database-design-template.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/system_design_plan/database-design-template.md) 

Strictly follow all the intructions.


Context:

Design the database based on the approved system architecture.

Generate only:
database-design.md

Do not generate SQL scripts.

---

## Generate APIs Contract.

## Role

Act as the Solution Architect.

### Required Inputs
- [solution-architect.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/solution-architect.md)
- [api-contract-template.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/system_design_plan/api-contract-template.md) 

Strictly follow all the intructions.

Context:
Design the REST API Contract.
Generate only:
api-contract.md

Do not generate implementation code.

