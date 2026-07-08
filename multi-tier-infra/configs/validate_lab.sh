#!/bin/bash
# Router VM – Lab Validation Script (Screenshot-Friendly Version)

echo "===================================================="
echo "              LAB VALIDATION START"
echo "===================================================="
echo ""

# -----------------------------
#  CONFIG
# -----------------------------
WEB01_IP="192.168.10.50"
WEB01_GW="192.168.10.1"

WEB02_IP="192.168.20.50"
WEB02_GW="192.168.20.1"

WEB01_PASS="<web01-password>"
WEB02_PASS="<web02-password>"

# -----------------------------
# 1. GATEWAY REACHABILITY
# -----------------------------
echo "[1] Testing VLAN Gateways"
echo "-------------------------"

echo "Ping VLAN10 Gateway ($WEB01_GW)"
ping -c 3 $WEB01_GW
echo ""

echo "Ping VLAN20 Gateway ($WEB02_GW)"
ping -c 3 $WEB02_GW
echo ""

# -----------------------------
# 2. BACKEND SERVER REACHABILITY
# -----------------------------
echo "[2] Testing Backend Servers"
echo "---------------------------"

echo "Ping Web01 ($WEB01_IP)"
ping -c 3 $WEB01_IP
echo ""

echo "Ping Web02 ($WEB02_IP)"
ping -c 3 $WEB02_IP
echo ""

# -----------------------------
# 3. VLAN ISOLATION TEST
# -----------------------------
echo "[3] Testing VLAN Isolation"
echo "--------------------------"

echo "Web01 → Web02 (should FAIL)"
sshpass -p "$WEB01_PASS" ssh -o StrictHostKeyChecking=no root@$WEB01_IP "ping -c 3 $WEB02_IP"
if [ $? -ne 0 ]; then
    echo "✔ VLAN isolation OK: Web01 cannot reach Web02"
else
    echo "❌ VLAN isolation FAIL: Web01 can reach Web02"
fi
echo ""

echo "Web02 → Web01 (should FAIL)"
sshpass -p "$WEB02_PASS" ssh -o StrictHostKeyChecking=no root@$WEB02_IP "ping -c 3 $WEB01_IP"
if [ $? -ne 0 ]; then
    echo "✔ VLAN isolation OK: Web02 cannot reach Web01"
else
    echo "❌ VLAN isolation FAIL: Web02 can reach Web01"
fi
echo ""

# -----------------------------
# 4. LOAD BALANCER TEST
# -----------------------------
echo "[4] Testing Nginx Load Balancer"
echo "-------------------------------"

for i in {1..6}; do
    echo "Request #$i:"
    curl -s http://web.lab
    echo ""
done

# -----------------------------
# 5. INTERFACE STATUS
# -----------------------------
echo "[5] Checking Router Interfaces"
echo "------------------------------"

ip a show ens38
echo ""
ip a show ens38.10
echo ""
ip a show ens38.20
echo ""
ip a show ens37
echo ""

# -----------------------------
# 6. ROUTING TABLE
# -----------------------------
echo "[6] Routing Table"
echo "-----------------"
ip route show
echo ""

echo "===================================================="
echo "               LAB VALIDATION COMPLETE"
echo "===================================================="
