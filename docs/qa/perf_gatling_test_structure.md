# Test Structure

Gatling tests follow a specific structure, which significantly increases both the readability and maintainability of the tests. A well-organized test structure makes the process of maintaining and developing large scenarios much easier.
A Gatling test consists of the following components:

- **Simulation**
- **Scenario**
- **Protocol Configuration**
- **User Injection Profile**

### Simulation

Every Gatling test starts with a Simulation class. This class is the main entry point of the test, where all the components are brought together.

```scala
class LoginSimulation extends Simulation {

  // Test configuration is defined here

}
```

Inside the Simulation class, the following operations are typically performed:

- Scenarios are defined
- User load profiles are specified
- HTTP protocol settings are configured

In short, the Simulation class is the main control point that defines how the test will run.

### Scenario

A Scenario defines how a virtual user interacts with the system. It simulates a real user's behavior within the application, step by step.

```scala
val loginScenario = scenario("User Login Scenario")
  .exec(http("Login Request")
    .post("/login")
    .body(StringBody("""{ "username": "test", "password": "1234" }"""))
    .check(status.is(200))
  )
```

Here:

- Request steps are executed in sequence
- User behavior is simulated exactly

### Protocol Configuration

In this section, the protocol through which the test will run and its basic settings are defined. The HTTP protocol is used in most scenarios.
Here, typically:

- The base URL is defined
- Common header information is added
- Timeout and connection settings are configured

These settings apply to all requests within the scenario.

### User Injection

In this section, it is determined when, at what rate, and how many users will be loaded onto the system. This profile directly defines the load characteristics of the test.

```scala
setUp(
  loginScenario.inject(
    rampUsers(100).during(60)
  )
).protocols(httpProtocol)
```

For example:

- Gradual increase in users over a certain period
- Sudden user spikes
- Long-duration tests under a constant load

Thanks to this structure, Gatling tests can be designed to create both flexible and realistic load scenarios.
