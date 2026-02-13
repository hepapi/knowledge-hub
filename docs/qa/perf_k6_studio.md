# k6 Studio

Let’s be honest: viewing k6 Studio as just a "tool for people who don’t like writing code" is a big mistake.

In our team, we mostly use Studio as a rapid prototyping tool instead of manually writing 40-50 step user scenarios, which can be very time-consuming. It is a strategic shortcut that lets us spend time on the core test logic, not repetitive coding effort.

## Recording and Workflow

The most tedious part of performance testing is opening browser network traffic and manually sorting which requests matter.

With Studio, we delegate this to a browser extension (Chrome/Firefox):

- Open the extension
- Navigate the site like a real user (add products, pay, update profile, etc.)
- Stop recording
- Transfer flows directly into k6 Studio

The key benefit:

After recording, you can optimize the raw output with engineering judgment as if you wrote it manually. This makes it much easier to adapt generated code to your real test goals.

## Engineering Touches Within Studio

Studio is not only a recorder; it also acts as a practical editor. These features solve common field problems:

### Automatic Correlation

Studio can detect dynamic values like tokens and session IDs, then map them to variables.

This reduces manual regex work and prevents fragile scripts.

### Visual Assertions (Checks)

Without deep code edits, you can add checks through the UI, such as:

- "Is the page title correct?"
- "Is the response status 200?"

### Parameterization

Binding user data (for example from CSV files) to scenarios is faster and less error-prone compared to manual parsing.

## Why Should Studio Be Used?

| Situation | Why Use Studio |
|---|---|
| Speed (Velocity) | A 50-step checkout flow can take hours to code manually, but can be recorded in minutes. |
| Visual Validation | Seeing request order and dependencies visually reduces logic mistakes. |
| Team Collaboration | Product Owners or Manual QA engineers can review scenarios and make simple updates without deep coding. |

