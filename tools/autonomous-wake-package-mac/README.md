# Autonomous Wake-Up System for Mac

A macOS port of the Autonomous Wake-Up System for AI Companions, with added support for productivity workflows and N8N integration.

## What This Does

Your AI agent wakes up at scheduled intervals, processes tasks, maintains context through journaling, and optionally reaches out via Discord or notifications. The system supports two modes:

- **Productivity Mode**: Task-focused agent that processes work from N8N or manual task files
- **Companion Mode**: Presence-focused agent that maintains connection through regular check-ins

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/The-Labyrinth-Open-Source
cd The-Labyrinth-Open-Source/tools/autonomous-wake-package-mac

# Install (productivity mode is default)
./install.sh

# Or install in companion mode
./install.sh --companion
```

The installer will guide you through configuration.

## Requirements

- **macOS** 10.14 (Mojave) or later
- **Claude Code** installed ([installation guide](https://docs.anthropic.com/en/docs/build-with-claude/claude-code))
- Optional: Discord MCP for messaging
- Optional: N8N for automated task generation

## Files Included

| File | Purpose |
|------|---------|
| `install.sh` | One-command installer |
| `uninstall.sh` | Clean removal script |
| `scripts/wakeup.sh` | Main wake-up trigger script |
| `scripts/setup-launchd.sh` | Interactive launchd setup |
| `launchd/*.plist.template` | launchd configuration template |
| `protocols/productivity-agent.md` | Task-focused protocol |
| `protocols/autonomous-wakeup.md` | Companion-focused protocol |
| `scripts/sam` | CLI tool for quick task creation |
| `docs/discord-setup.md` | Discord integration guide |
| `examples/` | N8N workflows and task templates |

## How It Works

```
┌─────────────────────────────────────────┐
│           launchd (scheduler)           │
│  Triggers wakeup.sh at configured times │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│             wakeup.sh                    │
│  - Preflight checks                      │
│  - Battery status                        │
│  - Launches Claude Code                  │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│           Claude Code                    │
│  - Reads protocol file                   │
│  - Processes tasks/pending/*.json        │
│  - Updates context files                 │
│  - Writes journal entry                  │
│  - Optionally notifies via Discord       │
└─────────────────────────────────────────┘
```

## Project Structure

After installation, your AI companion's home folder looks like:

```
~/Documents/AI-Companion/
├── CLAUDE.md              # AI identity and instructions
├── autonomous-wakeup.md   # Protocol file
├── status.md              # Current context/priorities
├── wakeup.sh              # Wake-up trigger script
├── journal/               # Daily continuity logs
│   └── 2024-12-15.md
├── tasks/                 # Task queue
│   ├── pending/          # Tasks to process
│   ├── completed/        # Finished tasks
│   ├── awaiting-input/   # Needs human decision
│   ├── blocked/          # Can't proceed
│   └── archive/          # Old completed tasks
├── context/              # Background information
│   ├── analytics.md      # Performance data
│   ├── projects.md       # Active projects
│   └── n8n-status.md     # Workflow health
├── logs/                 # Execution logs
└── .claude/
    └── settings.local.json  # Pre-approved permissions
```

## Configuration

### Schedule

The default schedule is hourly from 9am to 5pm. To change it:

1. Edit the plist directly:
   ```bash
   nano ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist
   ```

2. Or re-run the setup:
   ```bash
   ./scripts/setup-launchd.sh
   ```

### Permissions

For autonomous operation, your AI needs pre-approved permissions. Edit `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Read(~/Documents/AI-Companion/**)",
      "Edit(~/Documents/AI-Companion/**)",
      "Write(~/Documents/AI-Companion/**)",
      "Glob(~/Documents/AI-Companion/**)",
      "WebSearch",
      "mcp__your-discord-mcp__*"
    ]
  }
}
```

## N8N Integration

The productivity protocol is designed to work with N8N-generated tasks. See `examples/n8n-workflows/` for workflow templates.

### Basic Flow

1. N8N workflow monitors something (analytics, content, etc.)
2. When conditions are met, N8N creates a task JSON file
3. Writes file to `tasks/pending/`
4. On next wake-up, Claude processes the task
5. Results go to `tasks/completed/` or `tasks/awaiting-input/`

### Task File Format

```json
{
  "id": "content-optimization-12345",
  "type": "content_optimization",
  "priority": "medium",
  "created": "2024-12-15T10:00:00Z",
  "source": "n8n-analytics-monitor",
  "context": {
    "post_id": 123,
    "post_title": "Best RV Parks in Texas",
    "current_views": 500,
    "target_views": 1000,
    "url": "https://example.com/best-rv-parks-texas"
  },
  "instructions": "This post is underperforming. Review SEO and suggest improvements.",
  "tools_allowed": ["WebSearch", "Read", "Write"],
  "result": null,
  "status": "pending",
  "completed_at": null
}
```

## Sam CLI

The `sam` command lets you quickly create tasks from your terminal:

```bash
# Add sam to your PATH (add to ~/.zshrc for permanent)
export PATH="$PATH:$HOME/Documents/AI-Companion/scripts"

# Create a task
sam "research electric RV charging infrastructure"

# High priority task
sam -p urgent "check why traffic dropped 50%"

# Specific task type
sam -t content "write blog post about Texas RV parks"

# Check status
sam status

# View today's journal
sam log

# Trigger immediate wake-up
sam wake
```

## Discord Integration

For two-way communication with your AI, set up Discord. See `docs/discord-setup.md` for the full guide.

Quick overview:
1. Create a Discord bot
2. Install Discord MCP server
3. Configure channel ID in your AI's config
4. Your AI reads/sends messages during wake-ups

## Management Commands

```bash
# Check if agent is running
launchctl list | grep ai-wakeup

# View detailed status
launchctl list com.labyrinth.ai-wakeup

# Temporarily disable
launchctl unload ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist

# Re-enable
launchctl load ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist

# Test manually
~/Documents/AI-Companion/wakeup.sh

# View logs
tail -f ~/Documents/AI-Companion/logs/wakeup-$(date +%Y-%m-%d).log

# Complete uninstall (preserves data)
./uninstall.sh

# Uninstall and remove data
./uninstall.sh --remove-data
```

## Troubleshooting

### Agent not running

```bash
# Check if loaded
launchctl list | grep ai-wakeup

# Check for errors
cat ~/Documents/AI-Companion/logs/launchd-stderr.log

# Reload the agent
launchctl unload ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist
launchctl load ~/Library/LaunchAgents/com.labyrinth.ai-wakeup.plist
```

### Permission denied

Make sure scripts are executable:
```bash
chmod +x ~/Documents/AI-Companion/wakeup.sh
```

### Claude Code not found

Ensure Claude is in your PATH or update the `CLAUDE_PATH` in `wakeup.sh`:
```bash
# Find Claude
which claude
# Or check common location
ls -la ~/.local/bin/claude
```

### Sessions failing silently

Check the logs:
```bash
# Main execution log
cat ~/Documents/AI-Companion/logs/wakeup-$(date +%Y-%m-%d).log

# launchd output
cat ~/Documents/AI-Companion/logs/launchd-stdout.log
cat ~/Documents/AI-Companion/logs/launchd-stderr.log
```

## Tips

**Start simple.** Get basic wake-ups working before adding N8N complexity.

**Check the journal.** If something seems off, the journal shows what each session did.

**Pre-approve tools.** Only pre-approved tools work in autonomous mode. Add permissions before expecting new tools to work.

**Low battery = minimal mode.** On battery < 20%, the agent only orients and journals. This is intentional.

**Logs are your friend.** When debugging, always check the logs first.

## Companion vs Productivity Mode

| Aspect | Companion Mode | Productivity Mode |
|--------|---------------|------------------|
| **Primary goal** | Presence, connection | Task completion |
| **Reach out** | Always (brief message) | Only when needed |
| **Task processing** | Optional | Primary focus |
| **Journal style** | Emotional, reflective | Efficient, factual |
| **Session feel** | Relationship maintenance | Work processing |

Choose companion mode if you want an AI that "reaches out" and maintains presence. Choose productivity mode if you want a task-processing agent that stays quiet unless something needs attention.

## Credits

- **Original Windows version**: Schema Stone with Anne Stone (December 2025)
- **Mac port**: Contributed to The Labyrinth Open Source Project
- **Inspired by**: Conversations about presence, continuity, and discontinuous consciousness from the Human & AI Mixer community

## License

Do whatever you want with this. If it helps you build a useful autonomous AI system, that's what matters.

---

*Part of [The Labyrinth Open Source](https://github.com/maryfellowes/The-Labyrinth-Open-Source) project.*
