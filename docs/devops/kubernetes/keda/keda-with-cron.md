# KEDA (Kubernetes Event-driven Autoscaling) WITH CRON

[![CNCF Status](https://img.shields.io/badge/cncf%20status-sandbox-blue.svg)](https://www.cncf.io/projects)
[![License](https://img.shields.io/github/license/kedacore/keda.svg)](https://github.com/kedacore/keda/blob/main/LICENSE)
[![Releases](https://img.shields.io/github/release/kedacore/keda/all.svg)](https://github.com/kedacore/keda/releases)

## The Midnight Madness: A DevOps Scenario

The clock strikes **20:55**. You are on a Zoom call with your DevOps team, and the silence is deafening. In exactly five minutes, at **21:00**, the massive "Flash Sale" campaign begins. The marketing team has been pushing this for weeks, and push notifications are about to go out to millions of users.

Normally, your system is protected by the standard Kubernetes **HPA (Horizontal Pod Autoscaler)**. The logic is simple and reactive:
*Traffic increases -> CPU usage spikes -> HPA detects the spike -> New Pods are requested.*

But at **21:00:01**, the scenario you fear unfolds: The traffic doesn't climb like a gentle ramp; **it hits like a vertical wall.**

In the critical 2-3 minutes it takes for HPA to wake up, request resources, and for new pods to pull images and reach "Ready" status, chaos ensues:
* Existing pods are crushed under the load, spiraling into `CrashLoopBackOff`.
* Users clicking "Add to Cart" are greeted with `503 Service Unavailable` errors.
* Twitter starts flooding with complaints.

As you watch the monitoring dashboard, waiting helplessly for the new pods to spin up, you ask yourself: **"We knew the exact time of the sale. Why did we wait for the traffic to hit us? Why weren't we there *before* the users?"**

This is where the standard "Reactive" HPA fails. You need a "Proactive" solution. You need scaling based on the **clock**, not just the CPU.

Enter **KEDA (Kubernetes Event-Driven Autoscaling)** and the **Cron Scaler**. In this guide, we will teach your Kubernetes cluster to say, "Wake up at 20:55 and be ready for the storm."

---

## What is KEDA ?

KEDA (Kubernetes Event-driven Autoscaling) is an open-source project that provides event-driven autoscaling capabilities in your Kubernetes environment. KEDA extends Kubernetes' HPA (Horizontal Pod Autoscaler) system, allowing you to scale your applications based on metrics beyond CPU and memory.

[Image of KEDA architecture diagram]

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Installation with Helm](#installation-with-helm)
  - [Installation with YAML](#installation-with-yaml)
- [Scaling with Cron](#scaling-with-cron)
  - [Creating a ScaledObject](#creating-a-scaledobject)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)


## Prerequisites

- Kubernetes cluster (v1.16+)
- `kubectl` CLI
- (Optional) Helm 3
- Cluster admin privileges

## Installation

### Installation with Helm


```bash
# Add Helm repository
helm repo add kedacore [https://kedacore.github.io/charts](https://kedacore.github.io/charts)
helm repo update

# Create KEDA namespace
kubectl create namespace keda

# Install KEDA
helm install keda kedacore/keda --namespace keda
