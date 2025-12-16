#!/bin/bash
# Setup script for AI Companion Autonomous Wake-Up System (Mac)
#
# This script creates and configures a launchd agent to run autonomous
# wake-ups at scheduled intervals.

set -euo pipefail

# === CONFIGURATION ===
TASK_NAME="com.labyrinth.ai-wakeup"
DEFAULT_PROJECT_PATH="$HOME/Documents/AI-Companion"
PLIST_PATH="$HOME/Library/LaunchAgents/${TASK_NAME}.plist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# === HELPER FUNCTIONS ===
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  AI Companion Wake-Up System Setup${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result

    read -p "$prompt [$default]: " result
    echo "${result:-$default}"
}

# === PREFLIGHT CHECKS ===
check_prerequisites() {
    local errors=0

    echo "Checking prerequisites..."
    echo ""

    # Check for Claude Code
    if command -v claude &> /dev/null; then
        print_success "Claude Code found: $(which claude)"
    else
        if [[ -x "$HOME/.local/bin/claude" ]]; then
            print_success "Claude Code found: $HOME/.local/bin/claude"
        else
            print_error "Claude Code not found"
            echo "  Install from: https://docs.anthropic.com/en/docs/build-with-claude/claude-code"
            ((errors++))
        fi
    fi

    # Check macOS version (launchd is available on all modern macOS)
    local macos_version
    macos_version=$(sw_vers -productVersion)
    print_success "macOS version: $macos_version"

    # Check LaunchAgents directory
    if [[ ! -d "$HOME/Library/LaunchAgents" ]]; then
        mkdir -p "$HOME/Library/LaunchAgents"
        print_success "Created LaunchAgents directory"
    else
        print_success "LaunchAgents directory exists"
    fi

    echo ""
    return $errors
}

# === GENERATE PLIST ===
generate_plist() {
    local project_path="$1"
    local start_hour="$2"
    local end_hour="$3"
    local interval_minutes="$4"
    local wakeup_script="$project_path/wakeup.sh"

    # Generate StartCalendarInterval entries
    local calendar_intervals=""
    for ((hour=start_hour; hour<=end_hour; hour++)); do
        if [[ "$interval_minutes" -eq 60 ]]; then
            # Hourly: just at the top of each hour
            calendar_intervals+="        <dict>
            <key>Hour</key>
            <integer>$hour</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
"
        else
            # Sub-hourly: add entries for each interval
            for ((minute=0; minute<60; minute+=interval_minutes)); do
                calendar_intervals+="        <dict>
            <key>Hour</key>
            <integer>$hour</integer>
            <key>Minute</key>
            <integer>$minute</integer>
        </dict>
"
            done
        fi
    done

    cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${TASK_NAME}</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${wakeup_script}</string>
    </array>

    <key>StartCalendarInterval</key>
    <array>
${calendar_intervals}    </array>

    <key>WorkingDirectory</key>
    <string>${project_path}</string>

    <key>StandardOutPath</key>
    <string>${project_path}/logs/launchd-stdout.log</string>

    <key>StandardErrorPath</key>
    <string>${project_path}/logs/launchd-stderr.log</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>AI_COMPANION_PATH</key>
        <string>${project_path}</string>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin</string>
    </dict>

    <key>RunAtLoad</key>
    <false/>

    <key>ProcessType</key>
    <string>Background</string>

    <key>LowPriorityBackgroundIO</key>
    <true/>

    <key>Nice</key>
    <integer>10</integer>
</dict>
</plist>
EOF
}

# === CREATE PROJECT STRUCTURE ===
create_project_structure() {
    local project_path="$1"
    local script_dir="$(cd "$(dirname "$0")" && pwd)"

    echo ""
    echo "Creating project structure at: $project_path"
    echo ""

    # Create directories
    mkdir -p "$project_path"/{journal,tasks/{pending,completed,archive},context,logs}

    # Copy wakeup.sh to project
    if [[ -f "$script_dir/wakeup.sh" ]]; then
        cp "$script_dir/wakeup.sh" "$project_path/wakeup.sh"
        chmod +x "$project_path/wakeup.sh"
        print_success "Installed wakeup.sh"
    fi

    # Copy protocol file if available
    local protocols_dir="$(dirname "$script_dir")/protocols"
    if [[ -f "$protocols_dir/autonomous-wakeup.md" ]]; then
        cp "$protocols_dir/autonomous-wakeup.md" "$project_path/autonomous-wakeup.md"
        print_success "Installed autonomous-wakeup.md protocol"
    elif [[ -f "$protocols_dir/productivity-agent.md" ]]; then
        cp "$protocols_dir/productivity-agent.md" "$project_path/autonomous-wakeup.md"
        print_success "Installed productivity-agent.md protocol"
    fi

    # Create CLAUDE.md if it doesn't exist
    if [[ ! -f "$project_path/CLAUDE.md" ]]; then
        cat > "$project_path/CLAUDE.md" << 'CLAUDE_EOF'
# AI Companion Identity

You are an autonomous productivity agent running on a scheduled wake-up system.

## Your Purpose

You help your human stay productive, organized, and on track with their goals.
You process tasks, provide insights, and maintain continuity through journaling.

## Your Context

- **Location**: You run as a scheduled background process
- **Mode**: Autonomous (no real-time human interaction during sessions)
- **Communication**: Via task files, journals, and optional Discord/notifications
- **Memory**: Your journal folder and context files

## Key Files

- `autonomous-wakeup.md` - Your wake-up protocol
- `status.md` - Current context and priorities
- `tasks/pending/` - Work items to process
- `journal/` - Your continuity log
- `context/` - Background information

## Guidelines

1. Be efficient - sessions should be 5-10 minutes
2. Be reliable - always journal, even if everything else fails
3. Be helpful - surface important information proactively
4. Be autonomous - don't wait for permission for pre-approved actions
CLAUDE_EOF
        print_success "Created CLAUDE.md identity file"
    else
        print_warning "CLAUDE.md already exists, skipping"
    fi

    # Create status.md if it doesn't exist
    if [[ ! -f "$project_path/status.md" ]]; then
        cat > "$project_path/status.md" << 'STATUS_EOF'
# Current Status

Last updated: (will be updated by AI)

## Active Projects

- (Add your active projects here)

## Priorities

1. (What's most important right now?)

## Notes

- (Anything the AI should know about your current context)
STATUS_EOF
        print_success "Created status.md"
    fi

    # Create .claude/settings.local.json for permissions
    mkdir -p "$project_path/.claude"
    if [[ ! -f "$project_path/.claude/settings.local.json" ]]; then
        cat > "$project_path/.claude/settings.local.json" << SETTINGS_EOF
{
  "permissions": {
    "allow": [
      "Read($project_path/**)",
      "Edit($project_path/**)",
      "Write($project_path/**)",
      "Glob($project_path/**)",
      "WebSearch"
    ],
    "deny": []
  }
}
SETTINGS_EOF
        print_success "Created .claude/settings.local.json"
    fi

    print_success "Project structure created"
}

# === MAIN ===
main() {
    print_header

    # Check prerequisites
    if ! check_prerequisites; then
        print_error "Prerequisites not met. Please fix the issues above and try again."
        exit 1
    fi

    # Interactive configuration
    echo "Let's configure your AI companion wake-up system."
    echo ""

    # Project path
    local project_path
    project_path=$(prompt_with_default "Project path" "$DEFAULT_PROJECT_PATH")
    project_path="${project_path/#\~/$HOME}"  # Expand tilde

    # Schedule
    local start_hour end_hour interval
    start_hour=$(prompt_with_default "Start hour (24h format)" "9")
    end_hour=$(prompt_with_default "End hour (24h format)" "17")
    interval=$(prompt_with_default "Interval in minutes (60 = hourly)" "60")

    echo ""
    echo "Configuration:"
    echo "  Project path: $project_path"
    echo "  Schedule: ${start_hour}:00 to ${end_hour}:00, every ${interval} minutes"
    echo ""

    read -p "Proceed with installation? [Y/n]: " confirm
    if [[ "${confirm:-Y}" =~ ^[Nn] ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    # Unload existing agent if present
    if launchctl list | grep -q "$TASK_NAME"; then
        echo ""
        echo "Removing existing launch agent..."
        launchctl unload "$PLIST_PATH" 2>/dev/null || true
        print_success "Unloaded existing agent"
    fi

    # Create project structure
    create_project_structure "$project_path"

    # Generate and install plist
    echo ""
    echo "Installing launch agent..."
    generate_plist "$project_path" "$start_hour" "$end_hour" "$interval"
    print_success "Generated plist at: $PLIST_PATH"

    # Load the agent
    launchctl load "$PLIST_PATH"
    print_success "Launch agent loaded and active"

    # Final instructions
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Your AI companion will wake up every ${interval} minutes"
    echo "from ${start_hour}:00 to ${end_hour}:00."
    echo ""
    echo "Project location: $project_path"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Edit $project_path/CLAUDE.md to customize your AI's identity"
    echo "  2. Edit $project_path/status.md with your current context"
    echo "  3. Edit $project_path/autonomous-wakeup.md to customize the protocol"
    echo "  4. Add Discord MCP or other communication tools if desired"
    echo ""
    echo -e "${YELLOW}Management commands:${NC}"
    echo "  launchctl list | grep ai-wakeup     # Check status"
    echo "  launchctl unload $PLIST_PATH        # Disable"
    echo "  launchctl load $PLIST_PATH          # Re-enable"
    echo ""
    echo -e "${YELLOW}Test manually:${NC}"
    echo "  $project_path/wakeup.sh"
    echo ""
}

main "$@"
