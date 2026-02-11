# Test Levels (Unit / Integration / System / Acceptance)

# The Hierarchy from Unit Testing to User Acceptance

Software testing is conducted in a hierarchical structure, typically within the V-Model framework, to isolate errors as early as possible, reduce costs, and ensure every part of the system is built correctly.

- Unit Testing: A white-box technique that verifies the smallest building blocks of the software (functions, methods, or classes) work as expected. Usually performed by developers during the coding phase, it aims to isolate a section of code and verify its correctness. It is the level where bugs are caught most early and cheaply.
- Integration Testing: Aims to expose defects in data communication and interaction between individually tested units when they are combined. It verifies if modules work harmoniously as a whole. Three main strategies are used:
  Big Bang Approach: All components are integrated simultaneously and tested as a single unit. Suitable for small systems, but defect isolation is difficult.
  Incremental Approach: Modules are merged in a logical order. Two sub-methods are used:
  Top-Down: High-level modules are tested first; "Stubs" (dummy programs) are used for low-level modules not yet ready.
  Bottom-Up: Low-level modules are tested first; "Drivers" (calling programs) are used to simulate high-level modules.
  Sandwich (Hybrid) Approach: A combination of Top-Down and Bottom-Up; it focuses on critical modules using both Stubs and Drivers.
- System Testing: The level that measures the compliance of the fully integrated system against the functional and non-functional requirements (SRS) defined at the start. The software undergoes a holistic evaluation before being presented to the end user.
- User Acceptance Testing (UAT): The final stage of testing to verify the software workflow. Often involving multiple users, this process determines if the software meets real-world needs.
- Requirement: Since developers might build software based on their own understanding, UAT ensures alignment with customer expectations.
- V-Model Correspondence: In the V-Model, UAT directly corresponds to the "Requirement Analysis" phase at the very beginning of the SDLC.
