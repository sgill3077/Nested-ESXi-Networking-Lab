# VLAN Isolation Troubleshooting

**Full Root-Cause Analysis & Resolution KB**

This Knowledge Base (KB) documents the complete troubleshooting process that led to successful VLAN isolation between **VLAN10** and **VLAN20** in a Fedora-based router VM using **firewalld** with an **nftables** backend. It tracks every major discovery, failure point, correction, and verification step from start to finish.

## Overview

The homelab environment requires strict internal network segmentation:

- **VLAN10** → Dedicated to WEB01
- **VLAN20** → Dedicated to WEB02
- **Router VM** → Fedora 40+ using `firewalld` with an `nftables` backend

Despite correct VLAN tagging and routing configurations, initial validation showed that inter-VLAN isolation was not functioning.

---

# Step-by-Step Troubleshooting

## 1. Identify the Symptom

Anomalous cross-communication was discovered during routine validation.

- Validation script returned **VLAN Isolation: FAIL**
- WEB01 could successfully ping WEB02
- **Expected:** VLAN10 and VLAN20 should not communicate directly

---

## 2. Check Firewalld Policy State (Critical)

Reloading firewalld failed with:

```text
PARSE_ERROR: Missing attribute target for policy
```

**Impact**

A malformed legacy `block_intervlan` policy prevented firewalld from reloading, leaving the firewall in a stale state.

---

## 3. Remove the Invalid Policy (Resolved)

```bash
firewall-cmd --permanent --delete-policy=block_intervlan
firewall-cmd --reload
```

Result:

- Firewalld reloaded successfully
- Firewall accepted new rule changes

---

## 4. Apply Direct FORWARD Rules (Recommended)

```bash
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -s 192.168.10.0/24 -d 192.168.20.0/24 -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -s 192.168.20.0/24 -d 192.168.10.0/24 -j DROP
firewall-cmd --reload
```

These explicit bidirectional DROP rules enforce VLAN isolation.

---

## 5. Verify Rules in nftables (Verified)

```bash
nft list ruleset | grep -A5 'chain FORWARD'
```

Result:

- DROP rules were successfully installed in the kernel FORWARD chain.

---

## 6. Run Validation Script Again (Verified)

Validation results:

- ✅ VLAN Isolation: OK
- ✅ DNS & Internet: OK
- ✅ Reverse Proxy & Load Balancer: OK
- ✅ Routing Tables: Correct

---

## 7. Resolve Load Balancer Output Issue (Secondary Bug)

**Problem**

WEB01 returned blank responses when accessing the internal load balancer.

**Root Cause**

WEB01 was using Google's public DNS (`8.8.8.8`) instead of the internal router, preventing `web.lab` from resolving.

**Fix**

```bash
nmcli con mod ens33 ipv4.dns "192.168.10.1"
```

Result:

- Internal DNS resolved immediately
- Load balancer functionality restored

---

## 8. Final Validation (Complete)

Final review confirmed:

- Stable routing
- Functional firewall
- Working load balancing
- Successful VLAN isolation

---

# Summary of Root Causes & Fixes

| Component                 | Root Cause                                                           | Resolution                                                       |
| ------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Firewall / VLAN Isolation | Malformed firewall policy prevented firewalld from loading new rules | Removed invalid policy and implemented direct FORWARD DROP rules |
| Load Balancer             | WEB01 used public DNS instead of internal DNS                        | Reconfigured interface to use the router as DNS                  |

---

# Final State

The completed homelab now provides:

- Hardware-level kernel VLAN isolation
- Reliable firewalld reloads
- Consistent internal DNS resolution
- Fully operational reverse proxy and load-balanced services
