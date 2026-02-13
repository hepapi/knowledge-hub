# Test Plan Structure


Creating a test plan in JMeter is not just about placing components one after another. It’s actually somewhat similar to the concept of scope in object-oriented programming. JMeter operates on a hierarchical tree structure, and the "position" of an element in that tree determines the fate of the test.

### 1. Test Plan
The Test Plan is the roof at the top of everything. It’s not just a file name; you define the overall character of the test here.

- **Global Variables:** We place values that will be needed everywhere, such as BASE_URL, PORT, in the User Defined Variables section. So, if one day you’re told, "We’re switching from the test environment to staging," instead of manually going through 50 requests, you can simply change one variable here and get it done.

- **Functional Mode Warning:** Be cautious about the "Functional Test Mode" checkbox here! It’s great for debugging, but never enable it when performing load tests. If you do, JMeter will try to write the response of every request to the disk, and before the server even gets tired, your computer’s CPU will give up.

### 2. Config Elements
Configuration elements are the "dominant" characters in JMeter. The inheritance logic applies here.

- **Top-Level Effect:** If you place an HTTP Cookie Manager at the very top (under Test Plan), all the Thread Groups below it will share those cookies.

- **Override:** If you place a different setting inside a specific request, that sampler will ignore the global settings above and apply its own settings.

- **Priority Order:** Configuration elements, no matter where they are in the hierarchy, always run before samplers. First comes preparation, then comes the attack!

### 3. Logical Controllers
While Samplers just say "send a request," Logic Controllers act as traffic cops, telling the test when to "stop, go, or turn."

- **Transaction Controller:** This is my favorite. For example, if the "Make Payment" step consists of 5 different API calls, you can group them inside this controller and view them in reports as a single entry (with a single transaction time).

- **Throughput Controller:** If you want to say, "10% of users should go to the payment page, and the rest should browse the homepage," this is exactly what you need. It’s the most practical way to simulate real user behavior.

### 4. Pre & Post Processors
These are the closest coworkers of samplers.

- **Pre-Processors:** Modify the data just before the request is sent.

- **Post-Processors:** Extract the response data after the request. For example, if you log in, and you don’t capture the returned token with a JSON Extractor and assign it to a variable, your next request will likely return a "401 Unauthorized" error.

**Classic Error Note:** If you place an HTTP Header Manager inside the "Login" request and add an auth token, it will only affect the login request. The "Profile" request that follows won’t see this header and your test will fail. **Solution?** Move the Header Manager to the "parent" level that is common to both requests.
