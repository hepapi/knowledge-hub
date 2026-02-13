# What is JMeter?


If we define JMeter as just "a tool that puts load on websites," we’re doing it a disservice. Developed entirely in Java, with its multi-threaded operation model and ability to communicate with almost every protocol, it transforms from a simple request sender into a true performance laboratory.

In fact, JMeter simulates a massive client that sends requests to the target system. However, there’s a detail that should not be confused here: While its operation is somewhat similar to a web browser, things work quite differently under the hood.

### 1. Java-Based Thread Architecture
JMeter runs each virtual user (Virtual User) as a separate Java thread at the operating system level. This is JMeter's greatest advantage but also the area that requires the most attention.

- **Why is it good?** It can perform synchronous operations like a real user. In other words, you can realistically simulate complex user flows where each step depends on the previous one.

- **Technical Cost:** Each thread consumes considerable memory (stack memory) and CPU on the JVM. If you're planning massive tests with 50,000+ users, you must optimize JVM heap settings (those famous -Xmx, -Xms parameters) according to your hardware. Otherwise, you might find your system locking up with an "OutOfMemory" error halfway through the test.

### 2. Golden Rule: "JMeter is NOT a Browser"
Sometimes, JMeter behaves like a browser; it stores cookies, manages headers, etc., but it is not a browser.

- **No DOM and Rendering:** JMeter reads the HTML content from the server as plain text. It doesn't "render" the page (i.e., it doesn’t display it visually).

- **Doesn't Run JavaScript:** JMeter doesn’t run those fancy AJAX calls or JavaScript code triggered when a page loads, such as React/Angular code.

**Engineer’s Note:** When testing modern web applications, don't waste time simulating clicks on buttons. Instead, capture the REST or GraphQL calls triggered in the background by those buttons and directly target those. Otherwise, you’ll only be measuring a static page and fooling yourself.

### 3. Unrestricted Protocol Support
The reason JMeter hasn't become outdated over the years is that it doesn’t just stop at HTTP. It can touch every layer of the enterprise architecture:

- **Database:** With JDBC, you can directly stress test SQL queries and search for answers to "Where is this database locking up?"

- **Messaging:** You can test the capacity of message queue systems like Kafka, RabbitMQ, or ActiveMQ via JMS.

- **Low-Level:** With the TCP Sampler, you can even go down to the socket level and measure data transfer speeds.

### 4. JSR223 and Groovy
Where standard JMeter components reach their limits, the JSR223 Sampler comes to the rescue. Here, you can write custom scripts using Groovy. This allows JMeter to move beyond being a static tool, transforming into a dynamic platform capable of performing complex data manipulations.

**A small tip:** For performance, always prefer Groovy. Older BeanShell solutions can unnecessarily stress the system under heavy loads, as proven through experience.
