# Thresholds & Checks


After running a performance test, simply saying "the system did not crash" does not provide enough value. What matters is whether the system stayed within the performance budget (SLA/SLO) defined in advance.

In k6, this is handled at two levels with different purposes:

## Checks: "Is Everything Running Smoothly?" Validation

A `check` is a basic assertion. In k6, even if a check fails, the test continues. It works like a silent witness and reports the failure ratio at the end.

Example interpretation:

- "5% of requests did not return 200 OK."

Where checks are useful:

- Response code validations (e.g. status is `200`)
- Response content validations (e.g. expected `id` field exists)
- Real-time data consistency checks without interrupting the load flow

## Thresholds: The Real Quality Gate

Thresholds are the true control mechanism in k6. They do not just report data; they can fail the test run and return a non-zero exit code, which can stop CI/CD pipelines.

If response time, error rate, or other critical metrics exceed limits, k6 exits with failure. This is the technical equivalent of saying:

- "This build cannot go live with current performance."

## Critical Field Note

Do not rely only on averages. Averages can hide real user pain.

Focus on percentiles like `p(95)` and `p(99)`:

- One user at 100ms and another at 5s can still produce a "reasonable" average.
- The slowest 1% usually reveals the real bottlenecks.

## Example Threshold Configuration

```javascript
export const options = {
  thresholds: {
    http_req_failed: ['rate<0.01'],
    // Failures must be less than 1%

    http_req_duration: ['p(95)<200'],
    // 95% of requests must be under 200ms

    'http_req_duration{status:200}': ['max<500'],
    // Max duration of successful requests must be under 500ms
  },
};
```

With this approach, you can define performance limits for specific metrics and enforce them as release criteria.
