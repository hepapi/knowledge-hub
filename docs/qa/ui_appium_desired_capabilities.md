# Desired Capabilities

Desired Capabilities are configuration parameters that tell Appium: "Which device, which app, and how the test should run."

They are sent before the test session starts.

## Android Example

```json
{
  "platformName": "Android",
  "deviceName": "Pixel_6",
  "automationName": "UiAutomator2",
  "app": "/apps/app.apk"
}
```

## iOS Example

```json
{
  "platformName": "iOS",
  "deviceName": "iPhone 15",
  "automationName": "XCUITest",
  "bundleId": "com.company.app"
}
```

## Common Capabilities

- `platformName`
- `deviceName`
- `automationName`
- `app` / `bundleId`
- `noReset`
- `fullReset`
- `autoGrantPermissions`

Proper capability configuration equals more stable tests.
