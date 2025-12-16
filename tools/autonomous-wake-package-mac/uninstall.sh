#!/bin/bash
# Uninstaller for AI Companion Autonomous Wake-Up System (Mac)
#
# This script removes the launchd agent but optionally preserves your data.

set -euo pipefail

# Configuration
TASK_NAME="com.labyrinth.ai-wakeup"
PLIST_PATH="$HOME/Library/LaunchAgents/${TASK_NAME}.plist"
DEFAULT_PROJECT_PATH="$HOME/Documents/AI-Companion"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  AI Companion Wake-Up System Uninstall${NC}"
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

main() {
    print_header

    local remove_data=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --remove-data)
                remove_data=true
                shift
                ;;
            --help|-h)
                echo "Usage: ./uninstall.sh [--remove-data]"
                echo ""
                echo "Options:"
                echo "  --remove-data   Also remove the AI companion data folder"
                echo "                  (journals, tasks, etc.)"
                echo ""
                echo "Without --remove-data, only the launchd agent is removed."
                echo "Your data in ~/Documents/AI-Companion is preserved."
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done

    # Check if agent is installed
    if [[ ! -f "$PLIST_PATH" ]]; then
        print_warning "Launch agent not found at: $PLIST_PATH"
        echo "Nothing to uninstall."
        exit 0
    fi

    echo "This will remove the AI Companion wake-up system."
    echo ""

    if [[ "$remove_data" == true ]]; then
        echo -e "${YELLOW}WARNING: --remove-data flag is set.${NC}"
        echo "This will ALSO delete your AI companion data folder:"
        echo "  $DEFAULT_PROJECT_PATH"
        echo ""
        echo "This includes journals, tasks, and configuration."
        echo ""
    else
        echo "Your data folder will be preserved:"
        echo "  $DEFAULT_PROJECT_PATH"
        echo ""
    fi

    read -p "Proceed with uninstall? [y/N]: " confirm
    if [[ ! "${confirm:-N}" =~ ^[Yy] ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    echo ""

    # Unload the launch agent
    if launchctl list | grep -q "$TASK_NAME"; then
        echo "Stopping launch agent..."
        launchctl unload "$PLIST_PATH" 2>/dev/null || true
        print_success "Launch agent stopped"
    fi

    # Remove the plist file
    if [[ -f "$PLIST_PATH" ]]; then
        rm "$PLIST_PATH"
        print_success "Removed: $PLIST_PATH"
    fi

    # Optionally remove data
    if [[ "$remove_data" == true ]]; then
        if [[ -d "$DEFAULT_PROJECT_PATH" ]]; then
            echo ""
            echo "Removing data folder..."

            # Create a backup first
            local backup_path="$HOME/Documents/AI-Companion-backup-$(date +%Y%m%d-%H%M%S)"
            cp -r "$DEFAULT_PROJECT_PATH" "$backup_path"
            print_success "Created backup at: $backup_path"

            rm -rf "$DEFAULT_PROJECT_PATH"
            print_success "Removed: $DEFAULT_PROJECT_PATH"
        fi
    fi

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Uninstall Complete${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    if [[ "$remove_data" != true ]]; then
        echo "Your data has been preserved at:"
        echo "  $DEFAULT_PROJECT_PATH"
        echo ""
        echo "To reinstall later, run ./install.sh"
    else
        echo "A backup of your data was created at:"
        echo "  $backup_path"
    fi
}

main "$@"
