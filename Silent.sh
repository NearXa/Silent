#!/bin/bash

# Banner display
clear
cat << EOF
┌──────────────────────────────────────────────┐
│                                              │
│       Silent - Stealth Port Scanner          │
│       Author: NearXa - 2025 Solo Project     │
│                                              │
└──────────────────────────────────────────────┘
EOF

# Inspirational hacker quotes
HACKER_QUOTES=(
    "Ports whisper secrets in the silence."
    "Shadows scan where light fears to tread."
    "Packets unseen, results revealed."
    "Stealth: not a choice, but a necessity."
    "What you can't see will find you."
    "Closed ports? Just a matter of time."
    "Your defenses meet my SYN."
    "Scanning? No, this is digital espionage."
    "Firewalls crumble under persistent curiosity."
    "Your network's edge? Already mapped."
)
SELECTED_QUOTE=${HACKER_QUOTES[$RANDOM % ${#HACKER_QUOTES[@]}]}
echo -e "\n🔍 $SELECTED_QUOTE\n"

# Dependency verification
DEPENDENCIES=("hping3" "nc" "timeout" "awk")
for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        echo "[!] Missing dependency: '$dep' is not installed."
        exit 1
    fi
done

# Default settings
SCAN_DELAY=0.1
STEALTH_MODE=false
VERBOSE_MODE=false

# Parse command-line options
while getopts ":d:sv" option; do
    case $option in
        d) SCAN_DELAY=$OPTARG ;;
        s) STEALTH_MODE=true ;;
        v) VERBOSE_MODE=true ;;
        *) ;;
    esac
done
shift $((OPTIND - 1))

# Input validation
TARGET_IP=$1
PORT_START=$2
PORT_END=$3

if [[ -z $TARGET_IP || -z $PORT_START || -z $PORT_END ]]; then
    cat << EOF
Usage: $0 [-d delay] [-s] [-v] <target_ip> <start_port> <end_port>
    -d delay    Set delay between scans (e.g., 0.2 for 200ms)
    -s          Enable super-stealth mode (randomized ports and delays)
    -v          Enable verbose output (displays each scanned port)
EOF
    exit 1
fi

# Initialize logging
IP_FORMATTED=$(echo "$TARGET_IP" | tr '.' '_')
CURRENT_TIME=$(date +"%Y%m%d_%H%M%S")
LOGFILE="Silent_${IP_FORMATTED}_${CURRENT_TIME}.log"

echo "[+] Initiating scan on $TARGET_IP (Ports: $PORT_START-$PORT_END)"
echo "[+] Scan delay: $SCAN_DELAY seconds"
$STEALTH_MODE && echo "[+] Super-stealth mode: ON"
$VERBOSE_MODE && echo "[+] Verbose output: ON"

# Port sequence setup
PORT_RANGE=$(seq "$PORT_START" "$PORT_END")
$STEALTH_MODE && PORT_RANGE=$(echo "$PORT_RANGE" | shuf)

# Semaphore for parallel scanning
MAX_CONCURRENT=20
TEMP_SEM="/tmp/silent_scan_$$.fifo"
mkfifo "$TEMP_SEM"
exec 4<>"$TEMP_SEM"
rm "$TEMP_SEM"
for ((i=0; i<MAX_CONCURRENT; i++)); do echo >&4; done

# Port scanning function
perform_scan() {
    local target=$1
    local port=$2

    $VERBOSE_MODE && echo "[*] Probing port $port..."

    if timeout 2 hping3 -S -p "$port" -c 1 "$target" 2>/dev/null | grep -q "flags=SA"; then
        echo "Port $port: OPEN" | tee -a "$LOGFILE"
    elif timeout 2 hping3 -S -p "$port" -c 1 "$target" 2>/dev/null | grep -q "flags=RA"; then
        echo "Port $port: CLOSED" >> "$LOGFILE"
    else
        echo "Port $port: FILTERED/NO RESPONSE" >> "$LOGFILE"
    fi
}

# Main scanning loop
for port in $PORT_RANGE; do
    read -u 4
    {
        $STEALTH_MODE && sleep $(awk -v min="$SCAN_DELAY" 'BEGIN { srand(); print min + rand() * min }')
        perform_scan "$TARGET_IP" "$port"
        echo >&4
    } &
done

wait
exec 4>&-

echo -e "\n[+] Scan completed. Results logged to $LOGFILE"
echo "[+] Target fully reconnoitered."