#!/bin/bash
# Autonomous Wake-Up Trigger for Claude Code (Mac Version)
#
# This script triggers Claude Code to run an autonomous wake-up session.
# It's designed to be called by launchd at scheduled intervals.
#
# SETUP: Configure via environment variables or edit the defaults below.

set -euo pipefail

# === CONFIGURATION ===
# These can be overridden by environment variables
PROJECT_PATH="${AI_COMPANION_PATH:-$HOME/Documents/AI-Companion}"
CLAUDE_PATH="${CLAUDE_CODE_PATH:-$(which claude 2>/dev/null || echo "$HOME/.local/bin/claude")}"
LOG_DIR="${PROJECT_PATH}/logs"
PROTOCOL_FILE="${PROJECT_PATH}/autonomous-wakeup.md"

# === LOGGING ===
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/wakeup-$(date +%Y-%m-%d).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE" >&2
}

# === PREFLIGHT CHECKS ===
preflight_check() {
    local errors=0

    # Check project path exists
    if [[ ! -d "$PROJECT_PATH" ]]; then
        log_error "Project directory not found: $PROJECT_PATH"
        ((errors++))
    fi

    # Check Claude Code is installed
    if [[ ! -x "$CLAUDE_PATH" ]]; then
        log_error "Claude Code not found or not executable: $CLAUDE_PATH"
        ((errors++))
    fi

    # Check protocol file exists
    if [[ ! -f "$PROTOCOL_FILE" ]]; then
        log_error "Protocol file not found: $PROTOCOL_FILE"
        ((errors++))
    fi

    # Check for required directories
    for dir in "journal" "tasks/pending" "tasks/completed" "context"; do
        if [[ ! -d "$PROJECT_PATH/$dir" ]]; then
            log "Creating missing directory: $PROJECT_PATH/$dir"
            mkdir -p "$PROJECT_PATH/$dir"
        fi
    done

    return $errors
}

# === BATTERY CHECK (optional - skip heavy work on low battery) ===
check_battery() {
    local battery_level
    battery_level=$(pmset -g batt | grep -Eo "\d+%" | tr -d '%' || echo "100")

    if [[ "$battery_level" -lt 20 ]]; then
        log "Low battery ($battery_level%). Running in minimal mode."
        echo "minimal"
    elif [[ "$battery_level" -lt 50 ]]; then
        log "Battery at $battery_level%. Running in standard mode."
        echo "standard"
    else
        echo "full"
    fi
}

# === NOTIFICATION (optional) ===
send_notification() {
    local title="$1"
    local message="$2"

    # Use terminal-notifier if available, otherwise osascript
    if command -v terminal-notifier &> /dev/null; then
        terminal-notifier -title "$title" -message "$message" -sound default
    else
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
    fi
}

# === MAIN EXECUTION ===
main() {
    log "=== Autonomous Wake-Up Starting ==="

    # Preflight checks
    if ! preflight_check; then
        log_error "Preflight checks failed. Aborting."
        exit 1
    fi

    # Check battery status
    local mode
    mode=$(check_battery)

    # Change to project directory
    cd "$PROJECT_PATH"
    log "Working directory: $PROJECT_PATH"
    log "Mode: $mode"

    # Count pending tasks
    local task_count
    task_count=$(find "$PROJECT_PATH/tasks/pending" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
    log "Pending tasks: $task_count"

    # Build the prompt based on mode
    local prompt
    if [[ "$mode" == "minimal" ]]; then
        prompt="Read autonomous-wakeup.md and follow ONLY steps 1 and 5 (orient and journal). Skip reach-out and autonomous work - low battery mode."
    else
        prompt="Read autonomous-wakeup.md and follow the protocol. You have $task_count pending tasks. Keep it efficient."
    fi

    # Execute Claude Code
    log "Executing Claude Code..."
    local start_time
    start_time=$(date +%s)

    if "$CLAUDE_PATH" --dangerously-skip-permissions -p "$prompt" >> "$LOG_FILE" 2>&1; then
        local end_time duration
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        log "Session completed successfully in ${duration}s"

        # Optional: send success notification (uncomment if desired)
        # send_notification "AI Companion" "Wake-up session completed (${duration}s)"
    else
        local exit_code=$?
        log_error "Claude Code exited with code: $exit_code"
        # send_notification "AI Companion" "Wake-up session failed (exit code $exit_code)"
        exit $exit_code
    fi

    log "=== Autonomous Wake-Up Complete ==="
}

# Run main
main "$@"
