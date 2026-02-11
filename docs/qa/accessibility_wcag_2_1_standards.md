# WCAG 2.1 Standards

## **Overview**

WCAG (Web Content Accessibility Guidelines) is a worldwide rule for web accessibility. It was built by the W3C (World Wide Web Consortium) Web Openness Activity. It permits a set of necessities, or victory criteria, which can be tried in order to guarantee that web content is accessible to clients with diverse disabilities. This is accomplished in WCAG 2.1.

For QA groups, "WCAG" gives a lingua franca for analysts, engineers, planning groups, and other partners. This makes it conceivable for openness bugs to be categorized in a standardized manner.

For common methodologies related to testing, see “What is Openness Testing?”.

## **WCAG Conformance Levels**

| Level | Description | Target |
|----|----|----|
| **Level A** | Minimum requirements. Failure often blocks users. | Must have |
| **Level AA** | Addresses most common barriers. **Recommended target.** | Should have |
| **Level AAA** | Highest level. Often aspirational. | Nice to have |

Most organizations aim for **Level AA conformance** as a realistic and legally defensible standard.

## **The Four Principles of WCAG (POUR)**

### **Perceivable**

Users must be able to understand information in text, audio, or visuals. Examples: alternative text, captions, color contrast.

### **Operable**

Users ought to have the capability to interact with the interface using various types of input methods. Examples: keyboard access, focus sequence, absence of traps.

### **Understandable**

The content, interaction, or user experience needs to be understandable and predictable. Examples include error messages, navigation, and text.

### **Robust**

The content should play well with assistive technology. Examples include valid HTML, semantic HTML, and using ARIA.

## **What’s New in WCAG 2.1**

WCAG 2.1 (June 2018) introduced 17 new success criteria that mainly dealt with

- **Mobile accessibility**

- **Low vision users**

- **Cognitive disabilities**

### **Key New Criteria for QA**

| **Criterion** | **Level** | **What to Test** |
|----|----|----|
| 1.3.4 Orientation | AA | Content works in both portrait and landscape |
| 1.3.5 Identify Input Purpose | AA | Autocomplete attributes on form fields |
| 1.4.10 Reflow | AA | No horizontal scroll at 320px width (400% zoom) |
| 1.4.11 Non-text Contrast | AA | UI components have 3:1 contrast ratio |
| 1.4.13 Content on Hover/Focus | AA | Tooltips dismissible, hoverable, persistent |
| 2.1.4 Character Key Shortcuts | A | Single-key shortcuts can be disabled/remapped |
| 2.5.1 Pointer Gestures | A | Multi-point gestures have single-pointer alternative |
| 2.5.3 Label in Name | A | Visible label matches accessible name |
| 2.5.4 Motion Actuation | A | Shake/tilt features have button alternative |

## **Commonly Tested WCAG Areas in QA**

Rather than test each criterion, the QA teams would usually target high-impact areas:

- Text alternatives for non-text content

- Keyboard accessibility and focus management

- Color contrast and text resizing

- Form labels, directions, and error messages

- Page Structure and Navigation Consistency

- Touch target sizes (minimum 44x44px)

These areas account for the biggest chunk of defects in real-world projects.

## **Using WCAG in QA Testing**

### **Practical Workflow**

1.  **Set target level (normally Level AA)**

2.  **Testing criteria applicable to feature or user flow**

3.  **Map findings to WCAG references**

4.  **Prioritize based on user impact**

### **Example Defect Mapping**

Issue: "Submit button not reachable via keyboard"  
→ WCAG 2.1.1 (Keyboard, Level A)  
→ Severity: Blocker  
→ Target Users: Keyboard-only users, screen reader users

## **Common Failures of WCAG**

### **Critical (Level A)**

- Missing alternative tags for images

- Broken keyboard navigation

- Form fields without labels

- Keyboard traps

### **Important (Level AA)**

- Color contrast insufficient (\< 4.5:1) for text

- Lacking visible focus indicators

- No skip navigation for repetitive content

- Content breaks at 400% zoom

## **ARIA Essentials for QA**

While testing the implementation of ARIA, the following:

| Check        | Question                                  |
|--------------|-------------------------------------------|
| Roles        | Is the role attribute appropriate?        |
| Labels       | Does aria-label or aria-labelledby exist? |
| States       | Are aria-expanded, aria-selected updated? |
| Live regions | Is aria-live used for dynamic content?    |

Warning: “ARIA Rule” Do not use poor-quality ARIA. Using poor-quality ARIA creates accessibility problems.

## **WCAG 2.2 Note**

“Update” WCAG 2.2 has been released in October 2023, introducing new guidelines such as Focus Not Obscured (2.4.11) and Dragging Movements (2.5.7). However, it is recommended to check for updates.

## **QA Perspective**

The WCAG Guidelines should not be viewed as a checklist to complete at the conclusion of the development process. The Guidelines serve as a continuous assessment tool that can be employed to assist in attaining the following objectives:

- Early risk detection

- Clear defect communication

- Consistent prioritization

Accessibility maturity is enhanced with the inclusion of WCAG guidelines in day-to-day QA processes.

## **Conclusion**

WCAG 2.1 offers a systematic and testable means for accessibility checking. By aiming for Level AA conformance and integrating WCAG accessibility checks into overall QA processes, developers can provide inclusive experiences.

!!! quote “Remember,” WCAG is a guideline—not the goal itself. The goal is usable, inclusive products.
