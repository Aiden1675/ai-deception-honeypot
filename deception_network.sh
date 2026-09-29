#!/bin/bash

LOG="/home/vboxuser/deception_hits.log"
PORTS=(3306 5432 6379 27017 8080)
SERVICES=("MySQL" "PostgreSQL" "Redis" "MongoDB" "WebServer")

echo "== DECEPTION NETWORK =="
echo "Deploying fake services..."
echo "Time: $(date)"
echo ""

for port in "${PORTS[@]}"; do
    fuser -k $port/tcp 2>/dev/null
done

for i in "${!PORTS[@]}"; do
    port="${PORTS[$i]}"
    service="${SERVICES[$i]}"

    case $port in
        3306) bannner="MySQL Server 8.0.32 - Unauthorized access prohibited" ;;
        5432) bannner="PostgreSQL 14.5 - Authentication required" ;;
        6379) banner="Redis 7.0.5 - Protected mode enabled" ;;
        27017) banner="MongoDB 6.0 - Authentication required" ;;
        8080) banner="HTTP/1.1 200 OK - Internal Web Server" ;;
   esac

   while true; do
       echo "$banner" | nc -l -p $port -w 5 >> $LOG 2>/dev/null
       if [ $? -eq 0 ]; then
           echo "[$(date)] HONEYPOT HIT: $service on port $port" | tee -a $LOG
           echo "[ALERT] Attacker connected to fake $service!"
           echo "        Port:    $port"
           echo "        Service: $service"
           echo "        MITRE:   T1046 - Network Service Discovery"
           echo "        Action:  Log and monitor attacker"
           echo ""
       fi
   done &

   echo "  [DEPLOYED] Fake $service on port $port"
done

echo ""
echo "== DECEPTION NETWORK ACTIVE =="
echo "Monitoring for attackers..."
echo "Hits logged to: $LOG"
echo "Press CTRL+C to stop"
echo ""

tail -f $LOG &

wait
