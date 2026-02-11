# What Is Appium?

Appium is an open-source mobile test automation framework that enables testing of Android, iOS, and hybrid mobile applications using a single API.

Its main goal is simple: automate real user interactions to ensure mobile application quality.

## Why Appium?

Appium provides several advantages:

- Cross-platform support (Android and iOS)
- Supports Native, Hybrid, and Mobile Web apps
- Multiple programming languages:
  - Java
  - JavaScript
  - Python
  - Ruby
  - C#

This flexibility allows teams to use their existing tech stack without learning a new language.

## How Appium Works

Appium follows the WebDriver protocol.

Flow:

`Test Code -> Appium Server -> Native Drivers -> Mobile Device`

Under the hood:

- Android -> UiAutomator2
- iOS -> XCUITest

This architecture enables: "Write once, run on multiple devices."

You can reuse most of your test logic across platforms.
