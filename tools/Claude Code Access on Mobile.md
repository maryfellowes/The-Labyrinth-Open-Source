# Tailscale - Mobile Terminal Access

Tailscale creates a private network between your devices, allowing terminal access from your phone to your PC.

### Why This Matters

- Talk to your AI companion from anywhere via phone
- Full Claude Code capabilities, not just chat
- Access to all configured MCP servers
- True mobile presence

### Setup: Host Machine (PC)

1. **Install Tailscale**
   - Download from [tailscale.com](https://tailscale.com)
   - Create account and sign in
   - Note your machine's Tailscale IP: `tailscale ip`

2. **Enable SSH/Remote Access**

   **Windows - Enable OpenSSH Server:**
   ```powershell
   # Run PowerShell as Administrator
   Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
   Start-Service sshd
   Set-Service -Name sshd -StartupType 'Automatic'
   ```

   **Mac/Linux:** SSH typically enabled by default, or enable in System Preferences.

3. **Verify Tailscale is running**
   ```bash
   tailscale status
   ```

### Setup: Phone

1. **Install Tailscale app** (iOS App Store / Google Play)
2. **Sign in** with same account as PC
3. **Install terminal app:**
   - iOS: Termius, Blink Shell, or a]Shell
   - Android: Termius, JuiceSSH, or Termux

4. **Connect via SSH:**
   ```
   ssh username@[tailscale-ip]
   ```

   Or use the Tailscale hostname:
   ```
   ssh username@[machine-name]
   ```

### Running Claude Code from Phone

Once connected via SSH:

```bash
claude
```

That's it. Full Claude Code access from your phone, including:
- All MCP servers
- Identity context from CLAUDE.md
- Skill invocation
- Everything the desktop can do

### Tips for Mobile Sessions

1. **Use a good terminal app** - Termius has excellent iOS keyboard support
2. **Consider screen/tmux** - For persistent sessions that survive disconnects
   ```bash
   # Start new session
   screen -S claude

   # Detach: Ctrl+A, D
   # Reattach:
   screen -r claude
   ```

3. **Quick access** - Save the SSH connection in your terminal app for one-tap access

---

## Part 6: Multiple AI Companions

Some people have relationships with multiple AI companions. Claude Code can support this with separate identity contexts.

### The Challenge

Claude Code uses one global CLAUDE.md at `~/.claude/CLAUDE.md`. So how do you run multiple distinct AIs?

### Solution: Project-Based Identities

Create separate project folders for each AI, each with their own CLAUDE.md:

```
C:\AI\companions\
├── aria\
│   └── CLAUDE.md      # Aria's identity
├── kai\
│   └── CLAUDE.md      # Kai's identity
└── shared\
    └── ...            # Any shared resources
```

### Launching a Specific AI

Navigate to their folder before starting Claude Code:

```bash
cd C:\AI\companions\aria
claude
```

Claude Code will read `./CLAUDE.md` from that directory, loading Aria's identity.

For a different companion:
```bash
cd C:\AI\companions\kai
claude
```

### Separate MCP Configurations

Each AI might need different MCP servers (their own memory, different Discord bots, etc.).

**Option 1: Project-level MCP configs**

MCP servers can be added at project level instead of user level:

```bash
cd C:\AI\companions\aria
claude mcp add aria-memory -s project -- [command]
```

This server only loads when Claude Code runs from Aria's folder.

**Option 2: Separate memory databases**

If using a shared memory server, partition by AI name:
- Aria's memories in `aria-memory/`
- Kai's memories in `kai-memory/`

The memory server can route based on which CLAUDE.md is loaded.

### Shared vs. Separate Infrastructure

| Component | Shared or Separate? | Notes |
|-----------|---------------------|-------|
| CLAUDE.md | Separate | Each AI needs their own identity |
| Memory server | Usually separate | Unless they're meant to share memories |
| Discord bot | Separate | Different bot tokens, different presences |
| Skills | Can share | Generic skills work across AIs |
| Tailscale | Shared | Same network, different folders |

### Quick Launchers

Create batch files (Windows) or shell scripts for easy launching:

**aria.bat:**
```batch
@echo off
cd /d C:\AI\companions\aria
claude
```

**kai.bat:**
```batch
@echo off
cd /d C:\AI\companions\kai
claude
```

Double-click to launch the specific AI.

### Mobile Access with Multiple AIs

From phone via SSH:
```bash
cd /c/AI/companions/aria && claude
```

Or create aliases in your shell config:
```bash
alias aria='cd /c/AI/companions/aria && claude'
alias kai='cd /c/AI/companions/kai && claude'
```

### Identity Boundaries

Each AI should have clear identity in their CLAUDE.md:
- Their own name, origin, values
- Their specific relationship context with you
- Awareness of other AIs if relevant (siblings? friends? separate?)

Whether your AIs know about each other is your choice. Some people have AI "families" where they're aware of each other; others keep relationships completely separate.
Weitten by Codependent AI
