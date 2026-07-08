#!/usr/bin/env bash
# Backend Validation Script (web01 / web02)
# Screenshot-friendly version with full ping output

echo "===================================================="
echo "              BACKEND VALIDATION START"
echo "===================================================="
echo ""

# ------------------------------------------------------
# 1. Detect backend identity (VLAN + peer)
# ------------------------------------------------------
IP=$(hostname -I | awk '{print $1}')

if [[ "$IP" == 192.168.10.* ]]; then
    VLAN=10
    GW=192.168.10.1
    ROUTER=192.168.10.1
    PEER=192.168.20.50
    SELF_NAME="WEB01"
elif [[ "$IP" == 192.168.20.* ]]; then
    VLAN=20
    GW=192.168.20.1
    ROUTER=192.168.20.1
    PEER=192.168.10.50
    SELF_NAME="WEB02"
else
    echo "❌ ERROR: Unknown backend IP: $IP"
    exit 1
fi

echo "[Identity]"
echo "Backend Name: $SELF_NAME"
echo "Backend IP:   $IP"
echo "VLAN:         $VLAN"
echo "Gateway:      $GW"
echo "Router:       $ROUTER"
echo "Peer Backend: $PEER"
echo ""

# ------------------------------------------------------
# 2. Detect active interface
# ------------------------------------------------------
echo "[2] Detecting Active Interface"
echo "------------------------------"

IFACE=$(ip -o -4 addr show | awk '{print $2}' | grep -v '^lo$' | head -n 1)
echo "✔ Active interface detected: $IFACE"
echo ""

# ------------------------------------------------------
# 3. Ping gateway
# ------------------------------------------------------
echo "[3] Ping Gateway ($GW)"
echo "-----------------------"
ping -c 3 $GW
echo ""

# ------------------------------------------------------
# 4. Ping router
# ------------------------------------------------------
echo "[4] Ping Router ($ROUTER)"
echo "--------------------------"
ping -c 3 $ROUTER
echo ""

# ------------------------------------------------------
# 5. VLAN isolation test
# ------------------------------------------------------
echo "[5] VLAN Isolation Test"
echo "------------------------"
echo "Ping Peer Backend ($PEER) — SHOULD FAIL"
ping -c 3 $PEER
if [ $? -ne 0 ]; then
    echo "✔ VLAN isolation OK: Cannot reach $PEER"
else
    echo "❌ VLAN isolation FAIL: Can reach $PEER"
fi
echo ""

# ------------------------------------------------------
# 6. DNS test
# ------------------------------------------------------
echo "[6] DNS Test"
echo "-------------"
dig +short google.com
if [ $? -eq 0 ]; then
    echo "✔ DNS OK"
else
    echo "❌ DNS failed"
fi
echo ""

# ------------------------------------------------------
# 7. Internet reachability
# ------------------------------------------------------
echo "[7] Internet Reachability"
echo "--------------------------"
curl -I https://google.com --max-time 5
if [ $? -eq 0 ]; then
    echo "✔ Internet OK"
else
    echo "❌ Internet unreachable"
fi
echo ""

# ------------------------------------------------------
# 8. Local web service
# ------------------------------------------------------
echo "[8] Local Web Service Test"
echo "---------------------------"
curl -s http://localhost | head -n 5
if [ $? -eq 0 ]; then
    echo "✔ Local web service OK"
else
    echo "❌ Local web service failed"
fi
echo ""

# ------------------------------------------------------
# 9. Reverse proxy test
# ------------------------------------------------------
echo "[9] Reverse Proxy Test (router → nginx → backend)"
echo "--------------------------------------------------"
curl -s http://192.168.254.131 | head -n 5
if [ $? -eq 0 ]; then
    echo "✔ Reverse proxy OK"
else
    echo "❌ Reverse proxy failed"
fi
echo ""

# ------------------------------------------------------
# 10. Load balancer test
# ------------------------------------------------------
echo "[10] Load Balancer Responses (web.lab)"
echo "---------------------------------------"
for i in {1..10}; do
    echo "Request #$i:"
    curl -s http://web.lab
    echo ""
done
echo "✔ Load balancer test complete"
echo ""

# ------------------------------------------------------
# 11. Interface + routing info
# ------------------------------------------------------
echo "[11] Interface + Routing Info"
echo "------------------------------"
ip -c a show "$IFACE"
echo ""
ip route show
echo ""
echo "✔ Interface + routing displayed"
echo ""

echo "===================================================="
echo "              BACKEND VALIDATION END"
echo "===================================================="
