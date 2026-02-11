# Installation (Brief)

One of Playwright’s biggest advantages is its extremely simple installation process.

### 1. Installation

```bash
npm init playwright@latest
```

This command:

- Installs Playwright
- Downloads Chromium, Firefox, and WebKit
- Creates example test files
- Generates `playwright.config.ts`
- Sets up the project structure automatically

### 2. Running Tests

```bash
npx playwright test
```

### 3. UI Mode (Highly Recommended)

```bash
npx playwright test --ui
```

With UI Mode, you can:

- Visually observe test execution
- Debug step by step
- Inspect locators in real time
- Analyze failures more easily
