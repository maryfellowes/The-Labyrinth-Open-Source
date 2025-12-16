# Discord MCP Setup Guide

This guide walks you through setting up Discord as a two-way communication channel for your AI companion.

## What You'll Get

- **AI → You**: Your AI sends messages to a Discord channel during wake-ups
- **You → AI**: Leave messages in the channel; AI reads them on next wake-up
- **Async conversation**: Like texting, but with an AI that checks in on a schedule

## Prerequisites

- A Discord account
- A Discord server you control (or can add bots to)
- Node.js installed on your Mac
- Claude Code CLI installed

## Step 1: Create a Discord Bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)

2. Click **"New Application"**
   - Name it something like "AI Companion" or "Jarvis"
   - Accept the terms

3. Go to **Bot** in the left sidebar
   - Click **"Add Bot"**
   - Confirm by clicking "Yes, do it!"

4. Configure the bot:
   - **Username**: Whatever you want your AI to appear as
   - **Icon**: Upload an avatar if you want
   - Under **Privileged Gateway Intents**, enable:
     - ✅ MESSAGE CONTENT INTENT
     - ✅ SERVER MEMBERS INTENT (optional)

5. Get your bot token:
   - Click **"Reset Token"** (or "Copy" if visible)
   - **Save this token securely** - you'll need it later
   - ⚠️ Never share this token publicly

## Step 2: Invite the Bot to Your Server

1. Go to **OAuth2 → URL Generator** in the left sidebar

2. Select scopes:
   - ✅ `bot`
   - ✅ `applications.commands` (optional, for slash commands)

3. Select bot permissions:
   - ✅ Send Messages
   - ✅ Read Message History
   - ✅ View Channels
   - ✅ Embed Links (optional, for rich messages)

4. Copy the generated URL at the bottom

5. Open that URL in your browser and add the bot to your server

## Step 3: Get Your Channel ID

1. In Discord, go to **User Settings → Advanced**
   - Enable **Developer Mode**

2. Right-click on the channel you want your AI to use
   - Click **"Copy Channel ID"**
   - Save this ID

## Step 4: Install the Discord MCP Server

The Discord MCP server lets Claude Code interact with Discord.

```bash
# Clone the MCP servers repo (if you haven't)
git clone https://github.com/modelcontextprotocol/servers.git ~/mcp-servers

# Navigate to Discord server
cd ~/mcp-servers/src/discord

# Install dependencies
npm install

# Build
npm run build
```

Or use a community Discord MCP if available:

```bash
# Check for existing Discord MCP packages
npm search mcp discord
```

## Step 5: Configure Claude Code to Use Discord MCP

Add the Discord MCP to your Claude Code configuration.

### Option A: Project-level config

Create/edit `~/Documents/AI-Companion/.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "discord": {
      "command": "node",
      "args": ["/path/to/discord-mcp/dist/index.js"],
      "env": {
        "DISCORD_BOT_TOKEN": "your-bot-token-here"
      }
    }
  },
  "permissions": {
    "allow": [
      "Read(~/Documents/AI-Companion/**)",
      "Edit(~/Documents/AI-Companion/**)",
      "Write(~/Documents/AI-Companion/**)",
      "Glob(~/Documents/AI-Companion/**)",
      "WebSearch",
      "mcp__discord__*"
    ]
  }
}
```

### Option B: Global config

Edit `~/.claude/settings.json` to add the MCP server globally.

## Step 6: Create a Discord Config File

Create `~/Documents/AI-Companion/config/discord.json`:

```json
{
  "enabled": true,
  "channel_id": "YOUR_CHANNEL_ID_HERE",
  "bot_name": "Jarvis",
  "message_prefix": "",
  "read_history_count": 10,
  "notification_settings": {
    "on_wake": false,
    "on_task_complete": true,
    "on_error": true,
    "on_need_input": true
  }
}
```

## Step 7: Update Your Protocol

Edit `~/Documents/AI-Companion/autonomous-wakeup.md` to add Discord instructions:

```markdown
## Discord Communication

Read your Discord config from `config/discord.json`.

### On Wake-Up:
1. Check for new messages in your Discord channel since last session
2. If there are messages from your human, acknowledge and respond
3. Note any tasks or questions they've left for you

### Sending Messages:
Use the Discord MCP to send messages:
- Keep messages concise (1-3 sentences typically)
- Use the channel ID from your config
- Only send when there's something meaningful to communicate

### What to Communicate:
- ✅ Task completion summaries
- ✅ Questions that need human input
- ✅ Important discoveries or alerts
- ✅ Responses to messages from your human
- ❌ Don't spam "just checking in" messages
- ❌ Don't send on every wake-up unless configured to

### Message Format:
Keep it conversational but efficient:
- "Processed 3 tasks. Found an issue with the analytics workflow - needs your input."
- "Researched the RV charging topic. Summary in tasks/completed/. Key finding: infrastructure growing 40% YoY."
- "Saw your message about the blog post. Working on it now."
```

## Step 8: Test It

1. Manual test first:
```bash
cd ~/Documents/AI-Companion
claude -p "Read config/discord.json and send a test message to the configured channel saying 'AI Companion online and connected.'"
```

2. Check your Discord channel for the message

3. If it works, send a message in Discord and run:
```bash
claude -p "Check Discord channel for messages and respond to any you find."
```

## Troubleshooting

### "MCP server not found"
- Verify the path in your settings.json is correct
- Make sure you ran `npm install` and `npm run build`

### "Unauthorized" or "Invalid token"
- Double-check your bot token
- Make sure you copied the full token
- Try resetting the token in Discord Developer Portal

### "Missing permissions"
- Re-invite the bot with correct permissions
- Check the channel permissions allow the bot to read/write

### "Channel not found"
- Verify the channel ID is correct
- Make sure the bot is in the server with that channel
- Check Developer Mode is enabled to copy IDs

### Messages not appearing
- Check the bot is online (green dot in Discord)
- Verify MESSAGE CONTENT INTENT is enabled
- Check the channel isn't restricted from bots

## Security Notes

1. **Never commit your bot token** to git
   - Add `config/discord.json` to `.gitignore`
   - Or use environment variables instead

2. **Use a private channel** for AI communication
   - Create a channel only you and the bot can see
   - Keeps your AI conversations private

3. **The bot token gives full bot access**
   - Anyone with the token can send messages as your bot
   - Rotate the token if you ever suspect it's compromised

## Alternative: Discord Webhook (One-Way)

If you only need AI → You communication (no reading messages), a webhook is simpler:

1. In Discord: Channel Settings → Integrations → Webhooks
2. Create a webhook, copy the URL
3. Your AI can `curl` the webhook to send messages:

```bash
curl -H "Content-Type: application/json" \
  -d '{"content": "Message from your AI"}' \
  "YOUR_WEBHOOK_URL"
```

This doesn't require an MCP server but is one-way only.

---

## Quick Reference

After setup, your AI can:

```
# Read recent messages
mcp__discord__read_messages(channel_id, limit=10)

# Send a message
mcp__discord__send_message(channel_id, "Your message here")

# Check for mentions
mcp__discord__get_mentions(limit=5)
```

The exact function names depend on which Discord MCP implementation you use.

---

*Guide for The Labyrinth Open Source Project - Autonomous Wake-Up System*
