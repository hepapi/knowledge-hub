# Script Writing

The thing that mostly comforts you when you enter the world of k6 is that everything is essentially a familiar JavaScript file. In other words, we describe every action a virtual user (VU) will take in the system in the way we know best: through code.

But there is a key point here: the famous lifecycle within k6. If we miss the hierarchy of this flow by just a bit, there is a chance that those nice-looking graphs we see at the end of the day might mislead us, which is the last thing we want.

## What Awaits You When You Open a Script?

Typically, a standard k6 script is not overly complicated. First, we import the libraries we need (like `http` for HTTP requests or `check` for validations). Then comes the part where we make the real strategic decisions, the "rulebook," where we determine how many users we will load into the system: this is called the `options` section. Finally, we are met with the main function that carries the whole load.

## So, How Does This Cycle Work?

Once you trigger a test, k6 follows a specific order. Knowing this order is crucial to avoid battling with erroneous test results.

### 1. Preparation Phase (Init Context)

The moment the file is loaded into the system, this is triggered and runs only once. It is ideal for setting up variables or loading modules.

Note: Do not run HTTP requests for performance measurement here; k6 does not include those requests in its metrics the way you expect. Think of this as the behind-the-scenes preparation.

### 2. Action Time (Runtime Context)

#### `setup()` - Preparation

This runs just before the stage opens. It is the place for tasks you need to do only once (for example, getting a token or creating test data in a database). The data returned from here is passed like a relay to the main function.

#### `default()` - The Heart of the Test

This is where the real noise happens. The virtual users (VUs) run this function continuously in a loop throughout the test duration, based on the number of users you specified. Whether it is logging in, adding items to the cart, or anything else users do in the real world, it is all simulated here.

#### `teardown()` - Cleanup

This is triggered once more when everyone is done and the stage closes. It is basically the opposite of `setup`; it is the cleanup phase, used for tidying up after the test or closing open connections.

## Example k6 Script

```javascript
import http from 'k6/http'; // HTTP requests module
import { check, sleep } from 'k6'; // Modules for checks and sleep

// 1. Configuration (Performance Goals)
export const options = {
  vus: 10, // Number of Virtual Users (VUs)
  duration: '30s', // Duration of the test
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of response times must be under 500ms
    http_req_failed: ['rate<0.01'], // Failure rate must be below 1%
  },
};

// 2. Setup (Authentication, etc.)
export function setup() {
  // Make a POST request for authentication and get a token
  const res = http.post('https://api.example.com/login', { user: 'qa_admin' });
  return { token: res.json('token') }; // Return the token for use in the main test loop
}

// 3. Main Test Loop
export default function (data) {
  // Add the token to the request headers
  const params = { headers: { Authorization: `Bearer ${data.token}` } };

  // Make a GET request to fetch user data
  const res = http.get('https://api.example.com/users/1', params);

  // Check if the response status is 200
  check(res, {
    'is status 200': (r) => r.status === 200,
  });

  // Sleep for 1 second between requests
  sleep(1);
}
```
