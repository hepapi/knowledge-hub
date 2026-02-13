# Thread Groups & Samplers


When setting up a test in JMeter, there are two key questions you need to ask yourself: "Who will carry out the attack?" (Thread Group) and "With which weapon, and where will they strike?" (Sampler). If you don't get the balance between these two right, your test will either unnecessarily overload the system or not reflect the real world at all.

### 1. Thread Groups
Threads are the virtual users running at the operating system level. JMeter manages each of them independently as separate threads.

- **Ramp-up Period (Warm-up Time):**  
  This is the most common place where errors occur. Deploying 100 users to the system in the same second (Ramp-up: 0) is not a situation you encounter often in real life; at best, it would resemble a DDoS attack. For example, if you set 100 users and a 100-second ramp-up, a "fresh user" is added every second. Gradually warming up the server allows you to see bottlenecks (bottleneck) more clearly.

- **Loop Count vs. Duration (Loop or Time?):**  
  In most professional tests, the loop count is set to "Infinite" and the test duration is limited by "Duration." Why? Because having users create load on the system for 15 minutes rather than completing 5 rounds and leaving will provide much healthier results for measuring the server's stability performance.

- **Ultimate Thread Group (Plugin):**  
  If the standard group doesn’t suffice, this plugin is a lifesaver. You can easily create complex load scenarios that increase step by step, remain steady, and then spike (a sudden surge), just like drawing a graph.

### 2. Samplers
Samplers are JMeter’s "triggers." They are the units that send the actual request to the target server and say, "Give me this data."

- **HTTP Request:**  
  Our bread and butter. We manage all methods from GET to DELETE here.

- **JDBC Request:**  
  The answer to the question "The application is fast, but is the database slow?" is hidden here. We stress test the database with direct SQL queries.

- **JSR223 Sampler:**  
  When the standard option hits its limit, JSR223 allows you to create your own "special weapon" with Groovy. If you need to test a complex algorithm, look no further.

### Engineering Tip:
"HTTP 200 is Not Always Success!"  
Many people think a test has passed just because they see the HTTP 200 (OK) status. However, the server could return a 200 response but display a "Faulty Operation" message or a blank page. Therefore, always add a Response Assertion inside samplers. Is there a specific keyword you're expecting in the page content? If not, it’s safest to mark that test as "failed."
