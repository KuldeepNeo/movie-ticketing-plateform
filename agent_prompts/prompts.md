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

---

## Generate backend setup.

## Role

Act as the Solution Architect.

### Required Inputs
[solution-architect.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/solution-architect.md)  
[system-design.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/system_design_plan/system-design.md) 
[database-design.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/system_design_plan/database-design.md) 
[api-contract.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/system_design_plan/api-contract.md) 

Strictly follow all the intructions.


Action:
Design the Backend Project Structure.

Generate only:
backend-project-setup.md

Do not generate source code.

---

## Generate Frontend setup.

## Role

Act as the Solution Architect.

### Required Inputs
[solution-architect.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/solution-architect.md)  
[system-design.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/system_design_plan/system-design.md) 
[api-contract.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/system_design_plan/api-contract.md) 

Strictly follow all the intructions.


Action:
Design the Frontend Project Structure.

Generate only:
frontend-project-setup.md

Do not generate source code.

---

# Generate Sprint Roadmap

## Role
Act as a Senior Business Analyst 

## Action

Review the provided project documentation and generate a Sprint Roadmap.

### Required Inputs
[bussiness-analyst.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/bussiness-analyst.md) 
Strictly follow all the intructions.


- Continue until all approved features are planned.
- Do not generate code, SQL, APIs, or UI. Generate only the Sprint Roadmap.

---

# Generate Implementation Roadmap

## Role
Act as a Senior Technical Lead

## Action

Review the provided project documentation and generate a Sprint Roadmap.

### Required Inputs
[senior-technical-lead.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/senior-technical-lead.md) 
Strictly follow all the intructions.


- Do not generate code, SQL, APIs, or UI. Generate only the Implementation Roadmap.

---

# Sprint 1: Foundation & Identity - Backend Implementation

## Role:
Act as the Backend Developer.

## Task:
Implement only the backend work for the current sprint as defined in the Sprint Roadmap and Implementation Roadmap.


Context:
Review [backend-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/backend-developer.md), [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/save-token.md), [implementation-roadmap.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/implementation-roadmap.md) .

Requirements:
- Strictly follow Sprint 1: Foundation & Identity -> Backend Tasks.
- Strictly follow Implementation Order
- Follow the approved System Design, Database Design, API Contract, and Backend Project Setup.
- Generate only the files required for this sprint.
- Do not modify architecture, database schema, API contracts, or unrelated modules.

Output:
Generate production-ready backend code only.

---

# Sprint 1: Foundation & Identity - Frontend Implementation

Role:
Act as the Frontend Flutter Developer

## Task:

Implement only the frontend work for the current sprint as defined in the Sprint 1: Foundation & Identity.

Context:
Review [flutter-developer.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/personas/flutter-developer.md) , [save-token.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/save-token.md), [implementation-roadmap.md](file;file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/agent_prompts/implementation-roadmap.md) 

Requirements:
- Follow the approved System Design, API Contract, and Frontend Project Setup.
- Consume only approved APIs.
- Generate only the UI, components, state management, and integrations required for this sprint.
- Do not modify backend code, API contracts, or future sprint functionality.

Output:
Generate production-ready frontend code only.

---