# Jira Usage

## How QA Teams Use Jira in Practice

In our QA practices, Jira is used as a central workspace where testing activities, defect tracking, and quality visibility come together. Rather than serving only as a bug reporting tool, Jira supports the entire testing lifecycle and enables collaboration between QA, development, and product teams.

From a QA standpoint, the purpose of using Jira is to ensure that quality-related information is visible, traceable, and continuously updated throughout the project. Clear tracking of defects and testing progress helps teams make informed decisions and avoid last-minute surprises.

This page outlines how QA teams typically use Jira in day-to-day project work, based on real project experience.

## About Jira Boards and Visual Examples

The Jira board structures and visual examples shared in this documentation are intended to support understanding and knowledge transfer.

There is no single "correct" Jira configuration. In practice, Jira boards may differ depending on:

- Company processes and internal standards
- Project scope and technical complexity
- Team size and role distribution
- Agile or hybrid delivery models

All visual examples included here represent sample setups created for explanatory purposes. Teams should adapt Jira workflows according to their own project needs and organizational context.

## QA Responsibilities Within Jira

QA teams are responsible for validating that implemented features meet expected quality standards before release. This includes functional verification, risk identification, and communication of quality status.

In Jira, QA engineers commonly:

- Create and manage bug tickets
- Track testing progress during sprints
- Share testing results with stakeholders
- Maintain traceability between requirements and defects

In consultancy-based projects, QA engineers also contribute by guiding teams on testing discipline and improving visibility of quality-related risks.

## Managing Testing Activities Through Jira

Testing activities should be planned and tracked as part of the development lifecycle. Jira allows QA teams to follow testing status continuously rather than only at the end of development.

Typical QA-related statuses tracked in Jira include:

- Items prepared for testing
- Features currently under test
- Items ready for UAT
- Failed tests requiring rework

Tracking testing activities in this way helps ensure alignment with sprint goals and release plans.

## Example QA-Oriented Board Flow

The following workflow represents a commonly used QA-oriented board structure:

- **Ready for Test**: Development is complete and the item is available for QA validation.
- **In Test**: Test execution is in progress.
- **Ready for UAT**: QA validation is complete and the item is ready for business testing.
- **In UAT**: End users or stakeholders are validating the feature.
- **Test Fail**: Issues identified during testing require fixes.
- **Done**: All validation steps are completed and approved.

This structure allows teams to quickly understand the quality status of work items at any time.

## Jira Access and Permissions

Jira access is typically managed by client-side administrators in consultancy projects. Permissions are assigned according to role and responsibility.

QA engineers usually have access to:

- Assigned project boards
- Relevant issue types
- Bug creation and update features

Well-defined access rules support secure and transparent collaboration.

## Common Jira Issue Types Used by QA

QA teams interact with different issue types depending on the nature of the work:

- **Bug**: Used to report defects discovered during testing
- **Story**: Describes a feature or requirement from a user perspective
- **Task**: Represents a specific unit of work
- **Epic**: Groups related stories and tasks
- **Non-Development Task**: Used for documentation or analysis activities

Using appropriate issue types helps maintain structure and reporting consistency.

## Closing Notes

Using Jira effectively enables QA teams to maintain quality visibility throughout the project lifecycle. Clear workflows, consistent issue tracking, and active collaboration help reduce risks and improve delivery outcomes.

This documentation is intended to support QA engineers in understanding practical Jira usage and aligning testing activities with project goals.

