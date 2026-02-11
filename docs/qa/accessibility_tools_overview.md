# Accessibility Testing Tools (Overview)

## **Purpose of This Page**

It deals with a real-world QA question that is posed on this page: 'What are the accessibility tools that we should actually use?'

Emphasis will be placed on a central, realistic set of tools that the QA teams could use immediately rather than a complete list of tools that are available.

For more information on accessibility principles and strategies for testing, see What is Accessibility Testing?

## **Recommended Core Toolset**

### **Browser Extensions (Quick Checks)**

| **Tool** | **Purpose** | **Best For** |
|----|----|----|
| **axe DevTools** | Primary automated WCAG checker | Specific problem identification |
| **WAVE** | Visual structure overview | Quick Visual Audit |

Such tools are very useful in development environments before conducting official QA tests.

### **Screen Readers (Essential Manual Testing)**

Screen reader testing cannot be compromised when it comes to accessibility quality.

| Platform    | Screen Reader | Cost     |
|-------------|---------------|----------|
| Windows     | NVDA          | Free     |
| macOS / iOS | VoiceOver     | Built-in |
| Android     | TalkBack      | Built-in |
| Windows     | JAWS          | Paid     |

#### *Essential Screen Reader Shortcuts*

**NVDA (Windows)**

| Action             | Shortcut  |
|--------------------|-----------|
| Start/Stop reading | NVDA + ↓  |
| Next heading       | H         |
| Next link          | K         |
| Next form field    | F         |
| Elements list      | NVDA + F7 |

**VoiceOver (macOS)**

| Action           | Shortcut     |
|------------------|--------------|
| Start VoiceOver  | Cmd + F5     |
| Next item        | VO + →       |
| Rotor (elements) | VO + U       |
| Next heading     | VO + Cmd + H |
| Next link        | VO + Cmd + L |

*VO = Control + Option*

### **Automated Testing & CI/CD**

| Tool              | Use Case                                 |
|-------------------|------------------------------------------|
| **axe-core**      | Integration with test frameworks         |
| **Pa11y**         | CLI and CI/CD pipelines                  |
| **Lighthouse CI** | Performance + accessibility in pipelines |

#### *Playwright + axe-core Example*

**import** { test, expect } **from** '@playwright/test';  
**import** AxeBuilder **from** '@axe-core/playwright';  
  
test('checkout page accessibility', **async** ({ page }) **=\>** {  
**await** page.goto('/checkout');  
  
**const** results = **await** **new** AxeBuilder({ page })  
.withTags(\['wcag2a', 'wcag2aa'\])  
.analyze();  
  
expect(results.violations).toEqual(\[\]);  
});

#### *Cypress + axe-core Example*

describe('Accessibility Tests', () **=\>** {  
it('homepage should have no violations', () **=\>** {  
cy.visit('/');  
cy.injectAxe();  
cy.checkA11y();  
});  
});

### **Color & Contrast Tools**

| Tool                         | Purpose                           |
|------------------------------|-----------------------------------|
| **WebAIM Contrast Checker**  | Web-based contrast validation     |
| **Colour Contrast Analyser** | Desktop app with eyedropper       |
| **Stark**                    | Figma/Sketch plugin for designers |

**Contrast Requirements for WCAG:**

- Normal text: **4.5:1** (AA)

- Large text (18pt+): **3:1** (AA)

- UI components: **3:1** (AA)

### **Development Linters**

| Tool                       | Framework |
|----------------------------|-----------|
| **eslint-plugin-jsx-a11y** | React     |
| **vue-a11y**               | Vue.js    |
| **angular-eslint**         | Angular   |

Angular Linters decrease the number of accessibility bugs that reach the QA phase.

## **Practical QA Workflow**

1\. Automated Scan → axe DevTools / WAVE  
↓  
2. Keyboard Testing → Tab, Enter, Escape, Arrow keys  
↓  
3. Screen Reader → NVDA / VoiceOver on key flows  
↓  
4. Visual Checks → Contrast, zoom (400%), reflow  
↓  
5. CI/CD Integration → axe-core in test pipeline

This layered approach balances speed, coverage, and real user validation.

## **What Tools Can and Cannot Do**

### **Automated tools CAN detect:**

- Missing alt text

- Color contrast issues

- Missing form labels

- Invalid ARIA attributes

- Broken skip links

### **Automated tools CANNOT reliably validate:**

- Meaningfulness of alt text content

- Logical reading order

- Real screen reader usability

- Keyboard trap scenarios

- Overall user comprehension

!!! warning “Important” Automated tools catch ~30-40% of accessibility issues. Human evaluation remains essential.

## **Tool Selection Guide**

| Scenario        | Recommended Tools                   |
|-----------------|-------------------------------------|
| Quick dev check | axe DevTools, WAVE                  |
| Sprint testing  | axe + NVDA/VoiceOver                |
| CI/CD pipeline  | axe-core, Pa11y, Lighthouse         |
| Mobile testing  | VoiceOver (iOS), TalkBack (Android) |
| Design review   | Stark, Contrast Checker             |

## **QA Perspective**

Assistance tools help in QA judgment; they do not replace it.

The best possible accessibility tests are achieved through the integration of the:

- WCAG standards (what to test)

- Automated tooling (speed)

- Manual testing with assistive technologies (validation)

## **Conclusion**

Accessibility testing tools make it efficient for problems to be not only identified but prevented, although accessibility cannot be solely dependent on tools. The inclusion itself can be achieved by applying the right tool at the right time, as implemented by QA teams.

!!! quote ‘Final Reminder’ The strongest tool in the field of accessibility is a QA expert well-versed in the technology and its effects.
