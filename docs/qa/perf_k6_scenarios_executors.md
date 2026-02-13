# Scenarios & Executors

One of the biggest mistakes in performance testing is imagining user traffic as a straight, predictable line all the time. In real life, traffic behaves differently. Sometimes users come in slowly like a calm river, and sometimes a campaign causes a sudden flood.

k6 helps model these real-world traffic patterns through **executors**. You can even define multiple load profiles in a single test, such as gradual growth plus sudden spikes.

## So, Which Model Should We Choose?

The answer depends on what you want to measure.

## 1. Constant Number of Users (`constant-vus`)

Here we tell k6: keep this number of users fixed until the test ends.

Why we use it:

- Endurance/soak testing
- Long-running stability checks

What it tells us:

- Whether the system gets tired under long-term load
- Whether memory leaks or resource issues appear over time

```javascript
import http from 'k6/http'; // HTTP requests module
import { sleep } from 'k6'; // Sleep module to pause between requests

// Test configuration
export const options = {
  scenarios: {
    constant_load: {
      executor: 'constant-vus', // Using constant Virtual Users (VUs) executor
      vus: 50, // 50 virtual users
      duration: '5m', // Test will run for 5 minutes
      gracefulStop: '30s', // Additional time (30 seconds) to complete ongoing requests
    },
  },
};

// Main test function
export default function () {
  // Send a GET request to fetch product data
  http.get('https://api.example.com/products');

  // Sleep for 1 second between requests to simulate user behavior
  sleep(1);
}
```

## 2. Gradual Increase in Users (`ramping-vus`)

This model increases load step by step instead of jumping to max load at once.

Why we use it:

- Simulate realistic traffic growth
- Observe warm-up behavior

What it tells us:

- The point where performance starts degrading
- How CPU and memory usage change as user count grows

```javascript
import http from 'k6/http'; // HTTP requests
import { sleep } from 'k6'; // Sleep between requests

// Test configuration
export const options = {
  scenarios: {
    ramp_up_test: {
      executor: 'ramping-vus', // Gradually ramp virtual users
      startVUs: 0, // Start with 0 VUs
      stages: [
        { duration: '2m', target: 50 }, // Ramp up to 50 VUs in 2 minutes
        { duration: '5m', target: 100 }, // Ramp up to 100 VUs in 5 minutes
        { duration: '3m', target: 0 }, // Ramp down to 0 VUs in 3 minutes
      ],
      gracefulStop: '30s', // Allow 30s for ongoing requests to finish
    },
  },
};

// Main test function
export default function () {
  http.get('https://api.example.com/items'); // Fetch item data
  sleep(1); // Sleep for 1 second
}
```

## 3. Constant Request Rate (`constant-arrival-rate`)

This model focuses on target request rate (RPS), not active user count.

Why we use it:

- To validate throughput goals, e.g. 500 successful requests/sec

What it tells us:

- True bottlenecks under sustained pressure
- Real system behavior without false comfort from naturally dropping request rates

```javascript
import http from 'k6/http'; // HTTP requests
import { sleep } from 'k6'; // Sleep between requests

// Test configuration
export const options = {
  scenarios: {
    rps_test: {
      executor: 'constant-arrival-rate', // Constant rate of requests
      rate: 100, // 100 requests per second
      timeUnit: '1s', // Time unit in seconds
      duration: '2m', // Run for 2 minutes
      preAllocatedVUs: 10, // Minimum VUs (for optimization)
      maxVUs: 100, // Max VUs (used if system becomes more flexible)
    },
  },
};

// Main test function
export default function () {
  http.get('https://api.example.com/checkout'); // Fetch checkout data
  sleep(0.1); // Short sleep to maintain RPS target
}
```

## 4. Gradual Request Increase (`ramping-arrival-rate`)

Logic:
Similar to constant arrival rate, but the request rate increases gradually.

Why we use it:

- Capacity planning
- Finding the exact point where bottlenecks begin

## Advanced Scenario Definitions

With k6, you are not limited to a single executor. In one script, you can run different scenarios at the same time, such as:

- A gradual UI user ramp
- A constant API request stream in parallel

This makes tests closer to real-world mixed traffic patterns.

```javascript
import http from 'k6/http'; // HTTP requests
import { sleep } from 'k6'; // Sleep between requests

// Test configuration
export const options = {
  scenarios: {
    // Scenario 1: Website Browsing (Ramping VUs)
    website_browsing: {
      executor: 'ramping-vus', // Gradually ramp virtual users
      startVUs: 0, // Start with 0 VUs
      stages: [
        { duration: '1m', target: 20 }, // Ramp up to 20 VUs in 1 minute
        { duration: '2m', target: 50 }, // Ramp up to 50 VUs in 2 minutes
        { duration: '1m', target: 0 }, // Ramp down to 0 VUs in 1 minute
      ],
      gracefulStop: '30s', // Allow 30s for ongoing requests to finish
      exec: 'browseWebsite',
    },

    // Scenario 2: API Interactions (Constant Arrival Rate)
    api_interactions: {
      executor: 'constant-arrival-rate', // Constant rate of requests
      rate: 20, // 20 requests per second
      timeUnit: '1s', // Time unit in seconds
      duration: '4m', // Run for 4 minutes
      preAllocatedVUs: 5, // Minimum VUs for optimization
      maxVUs: 30, // Max VUs if needed
      gracefulStop: '30s', // Allow 30s for ongoing requests to finish
      exec: 'performAPIRequests', // Function to execute for this scenario
    },
  },
};

// Function to simulate website browsing
export function browseWebsite() {
  http.get('https://www.example.com/home'); // Visit home page
  sleep(2); // Sleep for 2 seconds
  http.get('https://www.example.com/products'); // Visit products page
  sleep(1); // Sleep for 1 second
}

// Function to simulate API interactions
export function performAPIRequests() {
  http.post(
    'https://api.example.com/data',
    JSON.stringify({ key: 'value' }),
    {
      headers: { 'Content-Type': 'application/json' },
    }
  ); // POST request
  sleep(0.5); // Sleep for 0.5 seconds
}
```

This variety of scenarios and executors makes performance tests more realistic and meaningful.

