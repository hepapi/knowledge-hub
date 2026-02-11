# Test Types (Functional / Non-Functional / Regression)

## Functional and Non-Functional Parameters

The success of software depends on both its functional accuracy and its structural robustness (performance, security, etc.).

### Functional Testing and Techniques

Functional testing verifies if the system performs correctly according to requirements. **Black Box** techniques, which do not require knowledge of the internal code structure, are typically used:

- **Equivalence Partitioning:** Dividing inputs into logical groups.
- **Decision Table:** Testing combinations of inputs.
- **State Transition:** Examining changes in states.
- **All-pairs Testing:** Covering input pairs.
- **Regression Testing:** Verifies that a change has not broken existing functionality. It can focus on only the changed unit (URT) or the entire product (FRT).

### Non-Functional Testing

Tests conducted to increase the efficiency and reliability of the software:

- **Performance Testing:** Measures the 3S (**Speed, Scalability, Stability**). It includes Load Testing (measuring daily use) and Stress Testing (pushing limits).
- **Security Testing:** Identifies system vulnerabilities through scans, penetration tests, and risk assessments.
- **Accessibility Testing:** Measures the usability of the system for individuals with disabilities using assistive technologies like screen readers.
