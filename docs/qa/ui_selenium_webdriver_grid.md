# WebDriver & Selenium Grid (Brief)

Selenium is composed of several components, the most important ones being WebDriver and Selenium Grid.

## Selenium WebDriver

WebDriver is the core component of Selenium.

- It directly controls the browser
- Simulates real user behavior
- Interacts with the DOM

### Supported Browsers

- Chrome
- Firefox
- Edge
- Safari

### Example (Java)

```java
WebDriver driver = new ChromeDriver();
driver.get("https://example.com");
driver.findElement(By.id("login")).click();
```

### Advantages

- Flexible
- Powerful
- Supports many programming languages

### Limitations

- Requires manual waits
- Setup can be complex
- Parallel execution requires extra configuration

## Selenium Grid

Selenium Grid allows tests to be executed in parallel across multiple browsers and machines.

### What Does Grid Provide?

- Cross-browser testing
- Cross-platform execution
- Faster test execution through parallelism

### Typical Usage Scenarios

- Chrome + Firefox + Edge at the same time
- Windows + macOS + Linux environments
- Large regression test suites

Selenium Grid is commonly used with:

- Jenkins
- Docker
- Kubernetes
