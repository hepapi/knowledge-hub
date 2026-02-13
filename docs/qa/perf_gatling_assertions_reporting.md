# Assertions & Reporting

Simply saying "test completed" is not enough to determine whether a performance test has truly been successful. What really matters is whether the results meet the predefined performance goals. Gatling offers powerful analysis capabilities at this point with its assertion and reporting mechanisms.

### Assertions

Assertions check whether the test results meet predefined threshold values. This way, the success criteria of the test are automatically validated.

```scala
setUp(
  loginScenario.inject(rampUsers(100).during(1.minute))
).assertions(
  global.responseTime.mean.lt(500),
  global.successfulRequests.percent.gt(99)
)
```

**In this example:**

- The average response time should be under 500 ms
- The success rate of requests should be above 99%

These types of rules are added to the test scenario and automatically evaluated at the end of the test. If any of the assertions fail, the test result is marked as "failed." This feature is especially critical in CI/CD processes because it prevents a build with performance issues from passing through the pipeline.

### Reporting

When Gatling tests are completed, it automatically generates detailed HTML-based reports. These reports allow for quick and clear analysis of the test's overall performance.

Reports generally include the following metrics:

- Response time distributions (min, max, percentiles)
- Requests per second (RPS)
- Error rates
- Scenario-based performance metrics

These visual reports are designed to be understandable not only for technical teams but also for non-technical stakeholders. This way, test results can be more easily shared and interpreted across teams.
