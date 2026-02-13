# Metrics & Reporting


When you run k6, it creates a large stream of data in the terminal. k6 measures many metrics by default, but in complex systems we often need more than defaults.

That is where **Custom Metrics** become important. With custom metrics, we can answer business-focused questions such as:

- "How many users successfully completed payment?"

instead of only technical questions like:

- "Did the request succeed?"

## Which Metric to Use Where?

Metric types should be treated as practical test instruments, not just names.

### Counter

Simple cumulative logic; it keeps increasing.

Typical uses:

- Total number of errors during the test
- Number of times "add to cart" was clicked

### Gauge

Snapshot value at a specific moment.

Typical uses:

- Current number of active users
- Instant CPU load

Think of it like a speedometer showing the current state.

### Trend

Used for values that vary over time.

Typical uses:

- Response times
- Database query durations

This is also where percentile analysis (`p(95)`, `p(99)`) becomes most useful.

## Engineering Tip: Fast Bottleneck Detection

If the system feels slow, first check:

- `http_req_waiting` (TTFB - Time to First Byte)

Why this helps:

- If `http_req_waiting` is high, the issue is usually not network transport.
- The root cause is often application processing or database query performance.

This shortcut helps you focus quickly on the true bottleneck.

## Exporting Results

```bash
k6 run --out json=results.json script.js
```

This command exports test results as JSON, which you can process later using reporting or analytics tools.

