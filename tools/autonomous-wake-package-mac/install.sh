#!/bin/bash
# One-command installer for AI Companion Autonomous Wake-Up System (Mac)
#
# Usage: ./install.sh [--productivity|--companion]
#
# Options:
#   --productivity  Install with productivity-focused protocol (default)
#   --companion     Install with companion-focused protocol
#   --help          Show this help message

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║     AI Companion Autonomous Wake-Up System (Mac)          ║"
    echo "║                                                           ║"
    echo "║     From The Labyrinth Open Source Project                ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_help() {
    echo "AI Companion Autonomous Wake-Up System - Mac Installer"
    echo ""
    echo "Usage: ./install.sh [options]"
    echo ""
    echo "Options:"
    echo "  --productivity  Use productivity-focused protocol (tasks, N8N, efficiency)"
    echo "  --companion     Use companion-focused protocol (presence, emotional connection)"
    echo "  --help          Show this help message"
    echo ""
    echo "Default: --productivity"
    echo ""
    echo "What this installs:"
    echo "  - Wake-up script and protocol files"
    echo "  - launchd agent for scheduled execution"
    echo "  - Project folder structure at ~/Documents/AI-Companion"
    echo ""
    echo "Requirements:"
    echo "  - macOS 10.14 or later"
    echo "  - Claude Code CLI installed"
    echo ""
}

check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${RED}Error: This installer is for macOS only.${NC}"
        echo "For Windows, use the original autonomous-wake-package."
        exit 1
    fi
}

check_claude() {
    # Check common locations for Claude Code CLI
    local claude_locations=(
        "$(command -v claude 2>/dev/null)"
        "$HOME/.local/bin/claude"
        "$HOME/.claude/local/claude"
        "/usr/local/bin/claude"
        "$HOME/.npm-global/bin/claude"
        "$HOME/node_modules/.bin/claude"
    )

    for loc in "${claude_locations[@]}"; do
        if [[ -n "$loc" && -x "$loc" ]]; then
            echo -e "${GREEN}✓${NC} Claude Code CLI found: $loc"
            export CLAUDE_CODE_PATH="$loc"
            return 0
        fi
    done

    # Not found - provide helpful install instructions
    echo -e "${RED}✗${NC} Claude Code CLI not found"
    echo ""
    echo -e "${YELLOW}The Claude Code CLI is required for autonomous wake-ups.${NC}"
    echo ""
    echo "Note: The Claude desktop app and IDE extensions are different from the CLI."
    echo ""
    echo "To install Claude Code CLI, run:"
    echo ""
    echo -e "  ${CYAN}npm install -g @anthropic-ai/claude-code${NC}"
    echo ""
    echo "Or if you prefer npx (no global install):"
    echo ""
    echo -e "  ${CYAN}npx @anthropic-ai/claude-code${NC}"
    echo ""
    echo "After installing, run this installer again."
    echo ""
    echo "More info: https://docs.anthropic.com/en/docs/claude-code"
    echo ""

    # Offer to continue anyway with manual path
    read -p "Or enter the path to claude manually (leave empty to exit): " manual_path
    if [[ -n "$manual_path" && -x "$manual_path" ]]; then
        echo -e "${GREEN}✓${NC} Using manually specified path: $manual_path"
        export CLAUDE_CODE_PATH="$manual_path"
        return 0
    fi

    return 1
}

main() {
    local protocol="productivity"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --productivity)
                protocol="productivity"
                shift
                ;;
            --companion)
                protocol="companion"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done

    print_banner

    echo "Checking system requirements..."
    echo ""

    check_macos

    if ! check_claude; then
        exit 1
    fi

    echo ""
    echo -e "${BLUE}Protocol mode:${NC} $protocol"
    echo ""

    # Make setup script executable and run it
    chmod +x "$SCRIPT_DIR/scripts/setup-launchd.sh"
    chmod +x "$SCRIPT_DIR/scripts/wakeup.sh"

    # Copy the appropriate protocol
    if [[ "$protocol" == "productivity" ]]; then
        echo "Using productivity-agent protocol..."
        export DEFAULT_PROTOCOL="$SCRIPT_DIR/protocols/productivity-agent.md"
    else
        echo "Using companion protocol..."
        export DEFAULT_PROTOCOL="$SCRIPT_DIR/protocols/autonomous-wakeup.md"
    fi

    # Run the setup script
    "$SCRIPT_DIR/scripts/setup-launchd.sh"
}

main "$@"
