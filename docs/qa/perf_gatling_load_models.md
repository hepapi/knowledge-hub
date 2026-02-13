# Load Models

A load model defines how the system will operate under load during the test. If the correct load model is not chosen, the results obtained may not reflect real user behavior, significantly reducing the value of the test.

### Common Load Model Types

1. **Ramp-Up Load**
The number of users is gradually increased over a certain period.

```scala
rampUsers(500).during(5.minutes)
```

**When is it used?**

- To observe how the system behaves under increasing load
- To identify the system's capacity limits

This model is very useful for understanding how the server responds to an increase in load.

2. **Constant Load**
A specific number of users continuously load the system throughout the duration of the test.

```scala
constantUsersPerSec(50).during(10.minutes)
```

**When is it used?**

- In stability tests
- In long-duration performance measurements
- In memory leak or resource consumption analysis

3. **Spike Load**
Simulates sudden and short-term high traffic spikes.

```scala
atOnceUsers(1000)
```

**When is it used?**

- In scenarios such as campaigns, flash sales, or sudden traffic spikes

### Realistic Load Model Design

In real systems, typically, a single model is not used. To obtain more realistic results, different load types are combined.
The most common approach:

- Combination of ramp-up + constant load
- Separate user profiles for different scenarios
- Simulation of peak hours during the day

Tests created in this way provide results much closer to real user behavior, and the system's true capacity is measured more accurately.
