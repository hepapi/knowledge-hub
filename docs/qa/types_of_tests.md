## TYPES OF TESTS

Software testing is the process of evaluating software applications, systems, or components to ensure they meet specified requirements and function as expected. It is categorized into two main types: functional testing and non-functional testing.



### 1. Functional Testing

Functional testing focuses on verifying that the software operates according to its intended functionality, based on specified requirements.

#### Types of Functional Testing

Unit Testing
Unit testing verifies the smallest testable parts of the software, such as functions or methods, in isolation. It is typically performed by developers during the coding phase and ensures that each unit of the software works as intended.

Example: Testing the "Add to Cart" function to ensure the selected item is correctly added to the shopping cart.

Technique: White-box testing.

Integration Testing
Integration testing examines how different modules or components of the software interact with each other. It ensures seamless communication between individual units.

Example: In a banking application, verifying that the "Deposit Funds" function updates the balance correctly and the "View Balance" function reflects the updated value.

System Testing
System testing validates the complete and integrated system to ensure that it meets the defined requirements.

Example: Testing an e-commerce website to ensure product searches, payment processing, and order tracking work together seamlessly.

Sanity Testing
It is performed after the project is built to ensure that the errors have been resolved and no new issues have been introduced due to code changes.

Example: After fixing a payment error, testing only the payment process to ensure it works correctly.

Smoke Testing
Smoke testing ensures the basic functionalities of the software are operational. It acts as a preliminary check before moving into detailed testing.

Example: Checking whether a website loads properly and the login feature works.

Regression Testing
Regression testing ensures that newly added features or bug fixes do not negatively impact the existing functionality.

Example: After adding a new payment method, verifying that older payment options like credit cards still function correctly.

Types:

Unit Regression Testing (URT): Tests only the modified unit.

Regional Regression Testing (RRT): Tests modules affected by the changes.

Full Regression Testing (FRT): Tests the entire system.

Exploratory Testing
Exploratory testing is performed without predefined test cases or plans. The tester investigates the software to discover potential issues.

Example: Clicking on various categories, attempting unusual login credentials, or initiating and canceling payments to observe system behavior.

User Acceptance Testing (UAT)
UAT validates whether the software meets the end-users' requirements and expectations. It is the final testing phase before the product is released.

Example: A banking application is tested by real users to ensure smooth fund transfers and accurate balance displays.



### 2. Non-Functional Testing

Non-functional testing evaluates the operational aspects of the software, such as performance, security, usability, and reliability. It focuses on "how" the software works rather than "what" it does.

#### Types of Non-Functional Testing

Performance Testing
This measures the system's speed, stability, and scalability under varying conditions.

Example: Checking the response time of a website under normal user loads.

Load Testing
Load testing determines how the system performs under expected user traffic or load.

Example: Simulating 5,000 concurrent users on an e-commerce website during peak hours.

Stress Testing
Stress testing evaluates the system's stability under extreme or unexpected conditions, such as high user loads or resource limitations.

Example: Simulating 50,000 users during a Black Friday sale to observe if the system crashes.

Security Testing
Security testing identifies vulnerabilities and ensures the software is protected from unauthorized access or data breaches.

Example: Testing a banking application to ensure sensitive data is encrypted and accessible only by authorized users.

Usability Testing
This ensures the software is user-friendly and provides a positive user experience.

Example: Evaluating whether a mobile app's interface is intuitive and easy to navigate.

Compatibility Testing
Compatibility testing ensures the software performs consistently across various devices, browsers, operating systems, and networks.

Example: Verifying that a website works seamlessly on Chrome, Safari, and Firefox.

Recovery Testing
Recovery testing examines the system's ability to recover from failures, such as power outages or hardware crashes.

Example: Testing whether a database restores correctly after an unexpected shutdown.



