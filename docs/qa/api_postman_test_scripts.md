# Test Scripts


Postman isn't just for sending requests; its JavaScript sandbox is where you actually turn a simple "call" into a real "test." Instead of manually checking the response body every time, you write scripts that do the boring work for you.

In our workflow, a request isn't considered "done" or production-ready unless it covers these three critical validation layers:

#### **1. Status Code Validation**

This is the bare minimum. We check if the server responded with what we expected (like a 200 OK or a 201 Created). It’s our first line of defense—if the status code is wrong, there's no point in checking anything else.

#### **2. Response Time (The Performance Guard)**

Functional correctness is great, but if your API takes 10 seconds to respond, it’s still a failure in the real world. We set a threshold (usually under 200ms or 500ms) to catch performance regressions early before they hit production.

#### **3. Payload & Schema Checks**

This is where we dig into the JSON. We don't just check if the data is there; we make sure it’s the *right* data. Using pm.expect(), we validate that the fields exist, the types are correct (string vs. number), and the values match our business logic.

### **2.1 Status & Performance Validation**

The first thing we do is a basic "sanity check." Before we start parsing complex JSON, we need to know if the server is even breathing and if it's responding fast enough.

#### **Why Status Codes Matter**

It sounds obvious, but you’d be surprised how often people skip this. Checking the status code is your first line of defense. If you're hitting a "Create User" endpoint, you aren't just looking for any success—you want that specific 201 Created.

#### **Example:** 

For example, when creating a new resource, you would typically expect a 201 Created status code to indicate a successful creation:

<img src="https://hepapi.github.io/knowledge-hub/qa/karate1-media/media/postman2-image2.png" style="width:6.5in;height:0.73611in" />

#### **Performance: Don’t Let it Slide**

Functional tests often pass even if the API is painfully slow. In a production environment, a 2-second delay is a failure. We set a hard limit (like 400ms) right in the test script. If a recent code change slows down the endpoint, our pipeline catches it immediately.

#### **Example: Performance Validation**

In addition to the status code, you might want to verify that the response time is within an acceptable threshold, say 400ms, to ensure the API’s responsiveness:

<img src="https://hepapi.github.io/knowledge-hub/qa/karate1-media/media/postman2-image4.png" style="width:6.5in;height:0.73611in" />

This two-step validation is our "baseline." If these fail, we don't even bother checking the rest of the payload—we already know something is wrong.

### **2.2 Functional Payload Validation (Business Logic)**

Checking the status code is just the handshake. The real work starts when you dig into the **response body**. You need to make sure the API didn't just return *something*, but that it returned exactly what you asked for, following your business rules.

If you’re fetching a user profile and the API returns 200 OK but the email field is empty, your test shouldn't pass. This layer is where you catch the subtle bugs that status codes miss.

#### **Validating the Data Logic**

In this step, we parse the JSON and check specific fields. Are the values correct? Is the account status what it should be? This is your safety net against logic errors in the backend.

#### **Example: Functional Payload Validation**

Let’s consider an example where you’re testing the **Get User Details API**:

<img src="https://hepapi.github.io/knowledge-hub/qa/karate1-media/media/postman2-image8.png" style="width:6.5in;height:1.55556in" />

#### **Why we don't skip this**

I've seen plenty of APIs that return a 200 OK while sending back an error message in the payload. Without payload validation, your automation suite is basically blind. By checking the actual data, you ensure that the "business" part of the business logic is actually working. If a developer accidentally changes a field name or breaks a database query, this test will catch it instantly.

### **2.3 Schema Enforcement (Contract Testing)**

If payload validation is about checking the **data**, Schema Validation is about checking the **contract**. In a microservices world, if a developer renames a field or changes a UserID from a number to a string, things break fast.

We use JSON Schema validation (via the **Ajv** library built into Postman) to make sure the response structure hasn't shifted under our feet.

#### **What are we actually catching?**

- **Type Mismatches:** Did we get a string where we expected an integer?

- **Missing Keys:** Did a "mandatory" field suddenly disappear?

- **Structural Chaos:** Did the nested object we rely on just get flattened or moved?

#### **Example: Schema Validation**

For instance, suppose you have a predefined JSON schema for a User object. You can use the following script to validate the response:

<img src="https://hepapi.github.io/knowledge-hub/qa/karate1-media/media/postman2-image6.png" style="width:6.5in;height:2.84722in" />

#### **Why we consider this non-negotiable**

We have seen too many "minor updates" break production because a small change in the JSON structure wasn't communicated to the frontend or mobile teams. Schema validation is your **early warning system**. It catches those "silent" breaking changes that might not trigger a 404 or a 500 error but will definitely crash your application logic.

### **Conclusion: Why the Three Layers Matter**

We don't do these three layers (Status, Payload, Schema) because we like writing scripts. We do them because they solve different problems:

1.  **Status/Performance:** Is the service up and fast?

2.  **Payload:** Is the business logic correct?

3.  **Schema:** Did the "contract" stay the same?

When you combine all three, you stop worrying about whether the API "might" break. You have a robust, multi-layered defense that catches bugs before they even reach your staging environment. It’s about building **confidence** in your releases, not just checking boxes.
