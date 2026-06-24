# Multi-Tier Infrastructure Troubleshooting KB

## Troubleshooting Methodology

Always validate in this order:

1. IP Address
2. Routing
3. Connectivity
4. DNS
5. Application

---

## Common Issues

### ❌ No Internet Access

Symptom:
ping 8.8.8.8 fails

Fix:
ip route add default via 192.168.247.50

---

### ❌ DNS Not Resolving

Symptom:
curl google.com fails

Fix:
/etc/resolv.conf → nameserver 192.168.247.50

---

### ❌ Packet Filtered

Cause:
Firewall blocking forwarding

Fix:
Configure firewalld policy (dmz → external)

---

### ❌ 502 Bad Gateway

Cause:
SELinux blocking nginx

Fix:
setsebool -P httpd_can_network_connect 1

---

### ❌ Backend Not Reachable

Cause:
nginx not running or firewall

Fix:
systemctl enable --now nginx
firewall-cmd --add-service=http --permanent
firewall-cmd --reload

---

### ❌ Load Balancing Not Working

Cause:
proxy_pass pointing to IP instead of upstream

Fix:
proxy_pass http://backend;
