# What is Root Cause Analysis (RCA)?

# Definition

RCA (Root Cause Analysis) is a systematic investigation process aimed at identifying the actual source of a problem rather than addressing its superficial symptoms. It is known as **Root Cause Analysis** in software engineering and quality assurance processes.

Instead of providing an immediate answer to the question "Why did this error occur?", RCA seeks a permanent answer to the question "What is the true source of this error and how do we prevent its recurrence?"

# Distinguishing Symptoms from Root Causes

The most common mistake when solving a problem is accepting the visible symptom as the root cause.

| **Symptom** | **Possible Root Cause** |
|----|----|
| Users cannot log in | Database connection pool exhausted |
| Page loads slowly | Unoptimized SQL query |
| Same bug reopened | Insufficient test coverage or incomplete code review |
| Payment transaction fails randomly | Third-party service timeout mismatch |
| Service crashed after deployment | Missing environment variable definition |

RCA aims to eliminate the source of the problem rather than temporarily alleviating symptoms.

# Core Principles of RCA

## 1. Data-Driven Approach

Progress is made with concrete data, not assumptions. Log records, metrics, test results, and error reports are the primary inputs of the analysis process.

## 2. Systems Thinking

The problem is evaluated as part of the system, not as an isolated event. Dependencies and interactions between components are taken into consideration.

## 3. Learning, Not Blaming

RCA is conducted to identify process and system vulnerabilities, not to find someone to blame. The focus is not "Who made the mistake?" but rather "Why did the system allow this error to occur?"

## 4. Documentation and Reusability

Identified root causes and applied solutions are documented. This creates organizational memory and provides a reference for similar issues.

# Common RCA Techniques

## 5 Whys

The "Why?" question is asked repeatedly to dig deeper into the problem. It is a simple and quickly applicable technique.

## Fishbone Diagram (Ishikawa)

Visualizes factors affecting the problem by categorizing them. Categories typically include: People, Method, System, Environment, Measurement. It is effective for multi-factor problems.

## Fault Tree Analysis

Starting from a top-level error, it models possible causes in a tree structure using logical gates (AND/OR). It is preferred in safety-critical systems and risk analysis.

# RCA's Place in Software Processes

RCA is applied in software development and QA processes in the following situations:

- **Production Incidents:** Outages or critical errors occurring in the live environment

- **Recurring Defects:** Bugs that are closed and reopened or appear in different forms

- **Security Vulnerabilities:** Identified vulnerabilities or breaches

- **Performance Anomalies:** Unexpected slowdowns or resource consumption issues

- **Post-Release Issues:** Unexpected behaviors that emerge following deployment

From a QA perspective, RCA means analyzing why the bug was not caught during the testing process and updating the test strategy accordingly.
