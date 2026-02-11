# Project Structure & Best Practices

A clean and scalable project structure is essential for long-term maintainability.

## Recommended Folder Structure

```text
├── tests/
│   ├── login.spec.ts
│   ├── register.spec.ts
├── pages/
│   ├── login.page.ts
│   ├── dashboard.page.ts
├── utils/
│   ├── test-data.ts
├── fixtures/
├── playwright.config.ts
```

## Best Practices

### 1. Use Page Object Model (POM)

Keeps UI logic separated from test logic.

### 2. Keep tests small and independent

Each test should validate a single behavior.

### 3. Avoid hardcoded data

Use configuration files or environment variables.

### 4. Use parallel execution

Playwright is optimized for parallel test runs.

### 5. Enable screenshots and videos

Helps significantly with debugging failures.
