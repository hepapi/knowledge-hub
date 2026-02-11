# SDLC & STLC (High-level)

## Software and Test Life Cycles

Quality is not a final act; it is the result of the seamless integration between development (SDLC) and testing (STLC) processes throughout the project.

### A. Software Development Life Cycle (SDLC)

SDLC is the framework that defines the tasks performed at each step in the software development process to produce high-quality software.

- Planning & Risk Analysis: Defining scope, resource allocation, and identifying potential project risks.
- Requirement Analysis: Gathering business and technical needs to create documents like BRD (Business Requirements Document) and FRD (Functional Requirements Document).
- Design (DDS): Architects create the Design Document Specification, outlining the system's structure and data flow.
- Development (Coding): The actual phase where developers write code based on the design specifications.
- Testing: Verifying that the application is bug-free and meets the initial requirements.
- Deployment & Maintenance: Releasing the product to the market and providing updates or fixes as needed.

### B. Software Testing Life Cycle (STLC)

STLC is a sequence of specific activities conducted during the testing process to ensure software quality goals are met.

| Phase | Core Objective | Deliverables |
|---|---|---|
| Test Planning | Determining strategy, tools, and timelines. | Test Plan, Resource Plan |
| Test Analysis | Identifying what to test by reviewing requirements. | Test Conditions, RTM (Traceability Matrix) |
| Test Design | Creating detailed steps and preparing data. | Test Cases, Test Scripts, Test Data |
| Environment Setup | Preparing the hardware/software "test bed." | Test Environment Ready |
| Test Execution | Running the tests and reporting defects. | Bug Reports, Test Logs |
| Test Closure | Evaluating exit criteria and summarizing results. | Test Summary Report |

### C. The Golden Rule: Verification vs. Validation

In QA, we distinguish between building the system correctly and building the correct system.

#### Verification (Process-Oriented)

- The Question: "Are we building the product right?"
- Method: Static testing. It involves reviewing documents, designs, and code without executing the software.
- Focus: Compliance with specifications and standards.

#### Validation (Product-Oriented)

- The Question: "Are we building the right product?"
- Method: Dynamic testing. It involves running the actual software to see if it meets user expectations.
- Focus: End-user satisfaction and real-world functionality.

Pro Tip: In the V-Model, Verification activities happen on the left side (Requirement Analysis, Design), while Validation activities happen on the right side (Unit, Integration, System, and UAT testing).
