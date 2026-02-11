# Page Object Model (POM)

Page Object Model is a fundamental design pattern in test automation.

## Purpose

- Reduce code duplication
- Improve readability
- Simplify maintenance
- Centralize UI changes

## Example Page Class

```ts
export class LoginPage {
  constructor(page) {
    this.page = page;
    this.email = page.locator('#email');
    this.password = page.locator('#password');
    this.loginBtn = page.locator('#login');
  }

  async login(email, password) {
    await this.email.fill(email);
    await this.password.fill(password);
    await this.loginBtn.click();
  }
}
```

## Test File

```ts
test('Successful login', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('test@mail.com', '123456');
});
```
