# Mobile Locator Strategies

Locator strategy directly affects test stability and performance.

- Poor locator -> Flaky tests
- Good locator -> Stable tests

## Recommended Order

### Accessibility ID (Best Practice)

```ruby
driver.find_element(:accessibility_id, "login_button")
```

- Fast
- Stable
- Cross-platform

### ID / Resource ID

```ruby
driver.find_element(:id, "com.app:id/loginBtn")
```

- Very reliable for Android

### XPath (Last Resort)

```xpath
//android.widget.Button[@text='Login']
```

- Slow
- Fragile
- Breaks easily after UI changes

## Best Practice

- Ask developers to add accessibility IDs
- Avoid XPath whenever possible

This dramatically reduces flaky tests.
