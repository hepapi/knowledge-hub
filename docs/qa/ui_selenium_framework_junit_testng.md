# Framework Approach (JUnit / TestNG)

Selenium alone is not a testing framework. It must be combined with a testing framework such as JUnit or TestNG.

## JUnit

JUnit is one of the oldest and most widely used testing frameworks in Java.

### Key Features

- Simple structure
- Annotation-based
- Best suited for unit testing
- Lightweight and easy to learn

### Example

```java
@Test
public void loginTest() {
    driver.get("https://example.com");
    Assert.assertTrue(driver.getTitle().contains("Login"));
}
```

### Pros

- Easy to learn
- Good for small projects

### Cons

- Limited parallel execution
- Basic reporting capabilities

## TestNG

TestNG is the most popular testing framework used with Selenium today.

### Key Features

- Parallel test execution
- Test grouping
- Test prioritization
- XML-based configuration
- Advanced reporting

### Example

```java
@Test(priority = 1)
public void loginTest() {
    // test steps
}
```

### Advantages

- Ideal for large projects
- CI/CD friendly
- Highly configurable

