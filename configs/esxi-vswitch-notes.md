# ESXi vSwitch Notes (Nested Lab)

## Purpose

These notes document ESXi virtual switching behavior in a nested ESXi environment running inside VMware Workstation.

---

## vSwitch Configuration

### Standard Switch

* vSwitch0 used for all VM traffic
* Portgroup: `VM Network`

---

## Security Settings (Required for Nested Virtualization)

These settings were required to allow proper traffic flow from nested VMs:

* Promiscuous Mode: **Accept**
* MAC Address Changes: **Accept**
* Forged Transmits: **Accept**

> These settings are required because nested VMs generate traffic with MAC addresses that differ from the ESXi host's physical NIC.

---

## Verification Commands

```bash
esxcli network nic list
esxcli network vswitch standard list
esxcli network vm list
esxcli network vm port list -w <world-id>
vmkping -I vmk0 8.8.8.8
```

---

## Key Observation

Even when ESXi management networking is functional, guest VM connectivity can fail if:

* vSwitch security policies block MAC spoofing
* Portgroup is incorrectly assigned
* Upstream NAT/bridging is misconfigured in VMware Workstation
