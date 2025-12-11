#!/bin/bash
# run.sh - Start kdb+ tick architecture processes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting kdb+ Tick Architecture${NC}"

# Check if q is available
if ! command -v q &> /dev/null; then
    echo -e "${RED}Error: kdb+ q not found in PATH${NC}"
    echo "Please install kdb+ and add q to your PATH"
    exit 1
fi

# Check if required script files exist
REQUIRED_SCRIPTS=("tick/tick.q" "tick/r.q" "tick/h.q" "tick/gateway.q" "tick/feed.q")
for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [[ ! -f "$script" ]]; then
        echo -e "${RED}Error: Required script file '$script' not found${NC}"
        exit 1
    fi
done

# Create log directory
mkdir -p logs

# Function to check if process is running
check_process() {
    local pid=$1
    local name=$2
    sleep 0.5
    if ! kill -0 $pid 2>/dev/null; then
        echo -e "${RED}Error: Failed to start $name (PID $pid)${NC}"
        exit 1
    fi
}

# Start tickerplant (port 5010)
echo -e "${YELLOW}Starting tickerplant on port 5010...${NC}"
q tick/tick.q -p 5010 > logs/tick.log 2>&1 &
TICK_PID=$!
echo "Tickerplant PID: $TICK_PID"
check_process $TICK_PID "tickerplant"

# Start RDB (port 5011)
echo -e "${YELLOW}Starting RDB on port 5011...${NC}"
q tick/r.q -p 5011 > logs/rdb.log 2>&1 &
RDB_PID=$!
echo "RDB PID: $RDB_PID"
check_process $RDB_PID "RDB"

# Start HDB (port 5012)
echo -e "${YELLOW}Starting HDB on port 5012...${NC}"
q tick/h.q -p 5012 > logs/hdb.log 2>&1 &
HDB_PID=$!
echo "HDB PID: $HDB_PID"
check_process $HDB_PID "HDB"

# Start gateway (port 5013)
echo -e "${YELLOW}Starting gateway on port 5013...${NC}"
q tick/gateway.q -p 5013 > logs/gateway.log 2>&1 &
GW_PID=$!
echo "Gateway PID: $GW_PID"
check_process $GW_PID "gateway"

# Start feedhandler (port 5009)
echo -e "${YELLOW}Starting feedhandler on port 5009...${NC}"
q tick/feed.q -p 5009 > logs/feed.log 2>&1 &
FEED_PID=$!
echo "Feedhandler PID: $FEED_PID"
check_process $FEED_PID "feedhandler"

echo -e "${GREEN}All kdb+ processes started!${NC}"
echo "Processes:"
echo "  Tickerplant:  PID $TICK_PID (port 5010)"
echo "  RDB:          PID $RDB_PID (port 5011)"
echo "  HDB:          PID $HDB_PID (port 5012)"
echo "  Gateway:      PID $GW_PID (port 5013)"
echo "  Feedhandler:  PID $FEED_PID (port 5009)"
echo ""
echo "Logs are in the logs/ directory"
echo "Press Ctrl+C to stop all processes"

# Function to kill all processes on exit
cleanup() {
    echo -e "\n${YELLOW}Stopping all kdb+ processes...${NC}"

    # List of PIDs to clean up
    local pids=($TICK_PID $RDB_PID $HDB_PID $GW_PID $FEED_PID)
    local names=("tickerplant" "RDB" "HDB" "gateway" "feedhandler")
    local valid_pids=()

    # First, verify which PIDs are still live children
    for i in "${!pids[@]}"; do
        if kill -0 "${pids[$i]}" 2>/dev/null; then
            valid_pids+=("${pids[$i]}")
            echo "Terminating ${names[$i]} (PID ${pids[$i]})..."
        else
            echo "${names[$i]} (PID ${pids[$i]}) already stopped"
        fi
    done

    # Send SIGTERM to valid PIDs
    if [[ ${#valid_pids[@]} -gt 0 ]]; then
        kill "${valid_pids[@]}" 2>/dev/null
    fi

    # Poll for termination with timeout
    local max_attempts=6  # 3 seconds total (6 * 0.5s)
    local attempt=0
    while [[ $attempt -lt $max_attempts && ${#valid_pids[@]} -gt 0 ]]; do
        sleep 0.5
        local remaining_pids=()
        for pid in "${valid_pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                remaining_pids+=("$pid")
            fi
        done
        valid_pids=("${remaining_pids[@]}")
        ((attempt++))
    done

    # Send SIGKILL to any remaining processes
    if [[ ${#valid_pids[@]} -gt 0 ]]; then
        echo "Force killing remaining processes: ${valid_pids[*]}"
        kill -9 "${valid_pids[@]}" 2>/dev/null
    fi

    echo -e "${GREEN}All processes stopped${NC}"
    exit 0
}

# Set trap to cleanup on exit
trap cleanup SIGINT SIGTERM

# Wait for processes
wait