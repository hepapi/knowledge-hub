# RCA Example & QA Perspective

# Scenario: Timeout Error in Payment Service

**Problem Description:** 15% of users in the production environment are unable to complete payment transactions. Users receive "Transaction timed out" error. The issue is observed more frequently during peak hours.

**Impact:**

- Daily transaction loss

- Customer complaints

- Increased ticket volume to support team

# 5 Whys Technique Application

| **Step** | **Question** | **Answer** |
|----|----|----|
| 1 | Why are users unable to make payments? | Payment API returns timeout error |
| 2 | Why does the API timeout? | Database query responds late |
| 3 | Why does the query respond late? | Full table scan is performed on the Orders table |
| 4 | Why is a full table scan performed? | Index is not defined on the relevant column |
| 5 | Why is the index not defined? | Table growth was not anticipated, performance testing was not conducted |

**Root Cause:** user_id column lacks an index, and performance testing under load was not performed.

# Fishbone Analysis (Ishikawa Diagram)

The following table categorizes the factors contributing to the payment timeout error:

<table style="width:92%;">
<colgroup>
<col style="width: 46%" />
<col style="width: 46%" />
</colgroup>
<thead>
<tr>
<th><strong>Category</strong></th>
<th><strong>Factors</strong></th>
</tr>
<tr>
<th><strong>PEOPLE</strong></th>
<th>• Performance check was skipped during code review<br />
• DBA approval was not obtained</th>
</tr>
<tr>
<th><strong>METHOD</strong></th>
<th>• Load testing was not performed<br />
• DB migration checklist was incomplete</th>
</tr>
<tr>
<th><strong>SYSTEM</strong></th>
<th>• Index is missing<br />
• Connection pool is insufficient</th>
</tr>
<tr>
<th><strong>ENVIRONMENT</strong></th>
<th>• Peak hour traffic increase<br />
• Concurrent user count increased 3x</th>
</tr>
<tr>
<th><strong>MEASUREMENT</strong></th>
<th>• DB response time was not monitored<br />
• Alert threshold was not defined</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

**Main Problem:** PAYMENT TIMEOUT ERROR

# Actions Taken

## Short-Term (Immediate Fix)

- Index added to orders.user_id column

- Connection pool size increased

- API timeout duration optimized

## Medium-Term (Preventive Actions)

- Index review step added to DB migration checklist

- Load testing process integrated into CI/CD pipeline

- Monitoring and alerts defined for database response time

## Long-Term (Process Improvement)

- Performance testing strategy documented

- Performance criteria added to code review checklist

- Capacity planning process established

# QA's Role in the RCA Process

QA engineers should take an active role in the RCA process and ask the following questions:

## Test Coverage Analysis

- Was this scenario within test coverage?

- Was load testing performed? If so, under what conditions?

- Were edge cases evaluated?

## Test Strategy Assessment

- Why did the current testing approach fail to catch this bug?

- Which type of testing was missing? (Performance, Load, Stress)

- How accurately did the test environment reflect production?

## Regression Strategy

- Which areas carry regression risk after this fix?

- What should be added to automation coverage?

- Should the smoke test suite be updated?

## Defect Pattern Analysis

- Have similar bugs occurred before?

- Is there a common pattern?

- Which module or component is at risk?

# RCA Report Template

An RCA report should include the following sections:

## Summary

- Incident ID: INC-2024-0892

- Date: 2024-01-15

- Severity: P1

- Affected System: Payment Service

- Impact Duration: 3 hours 20 minutes

## Problem Description

\[Description of the problem and how it was detected\]

## Timeline

- 09:15 - First alert triggered

- 09:22 - Incident opened

- 09:45 - Root cause identified

- 10:30 - Hotfix deployed

- 12:35 - Service stabilized

## Root Cause

\[Root cause identified through 5 Whys or other technique used\]

## Impact Analysis

- Number of affected users

- Number of failed transactions

- Financial impact (if any)

## Actions Taken Table

| **Action**        | **Owner**   | **Due Date** | **Status**  |
|-------------------|-------------|--------------|-------------|
| Add index         | DB Team     | 2024-01-16   | Completed   |
| Add load testing  | QA Team     | 2024-01-22   | In Progress |
| Set up monitoring | DevOps Team | 2024-01-25   | Planned     |
| Update checklist  | QA Team     | 2024-01-20   | Completed   |

## Lessons Learned

\[Conclusions drawn regarding process, system, and team\]

## Approval

- Prepared by: \[Name\]

- Approved by: \[Name\]

- Date: \[Date\]

# Lessons Learned

Questions to be evaluated as a team at the end of each RCA process:

**From a Process Perspective:**

- Which control points were missing?

- Which existing processes should be updated?

- Is there an automation opportunity?

**From a Technical Perspective:**

- Is an architectural or design change required?

- Is monitoring and alerting sufficient?

- Is documentation up to date?

**From a Team Perspective:**

- Was there a knowledge gap?

- Was a training need identified?

- Were communication processes adequate?

Lessons learned outputs should be shared with the entire team and stored as a reference to prevent similar errors.
