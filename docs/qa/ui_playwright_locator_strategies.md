# Locator Strategies

Playwright offers one of the most powerful locator engines in the testing ecosystem.

## Recommended Locator Priority

### `getByRole()`

```ts
page.getByRole('button', { name: 'Login' });
```

### `getByTestId()`

```ts
page.getByTestId('login-btn');
```

### `getByText()`

```ts
page.getByText('Sign In');
```

### CSS / XPath (last resort)

## Why XPath Is Discouraged

- Easily breaks with UI changes
- Hard to maintain
- Low readability
- Causes flaky tests

## Playwright Locators Are

- More stable
- Easier to read
- Auto-wait enabled
