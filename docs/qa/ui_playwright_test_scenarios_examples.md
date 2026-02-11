# Test Scenario Examples

## Positive Scenario

```ts
test('User logs in successfully', async ({ page }) => {
  await page.goto('/login');
  await page.fill('#email', 'test@mail.com');
  await page.fill('#password', '123456');
  await page.click('#login');

  await expect(page).toHaveURL('/dashboard');
});
```

## Negative Scenarios

- Invalid password
- Empty fields
- Incorrect email format
- Timeout handling
- Unauthorized access

## Playwright Handles These Scenarios With

- Stability
- Speed
- Detailed reporting
- Screenshots and videos
