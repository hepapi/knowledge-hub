# k6 Cloud / Grafana Integration

Let’s be honest: running tests on your local machine is a clean and safe lab experiment up to a point. But when traffic reaches thousands of users and global complexity, local CPU and network limits quickly become visible.

That is where the k6 Cloud and Grafana combination becomes critical.

## 7.1 k6 Cloud

When local resources are not enough, k6 Cloud helps, but its value is not only extra CPU.

### Global Load (Cloud Execution)

If your audience is global, generating traffic from a single office location is not realistic.

With k6 Cloud, you can apply load from different regions (for example Tokyo and Virginia) and measure latency under true global conditions.

### Leaving Infrastructure Labor Behind

You do not need to spend effort on:

- Docker setup and maintenance
- Load generator machine health
- Local environment bottlenecks

k6 Cloud handles infrastructure overhead so teams can focus on results.

### Anomaly Detection

k6 Cloud can surface unusual behavior during test execution, not only after test completion. This helps teams detect risk earlier.

## 7.2 Grafana & Prometheus

Reading only a post-test report is like autopsy. With Grafana integration, monitoring becomes live surgery.

### Real-Time Monitoring

During execution, metrics can be streamed to Prometheus and visualized in Grafana in near real-time.

This allows second-by-second visibility instead of delayed analysis.

### The Power of Correlation

This is the most valuable part:

- k6 latency and error metrics
- Server CPU/RAM metrics
- Database behavior

Seeing these together helps answer root-cause questions such as:

- "When response time spikes, is database connection pool saturation happening?"

### Historical Comparison

k6 Cloud keeps report history for a limited period, but self-managed Grafana/Prometheus storage can preserve data much longer.

Long-term history is essential for questions like:

- "How did the system perform during last year’s campaign, and how does it compare today?"

