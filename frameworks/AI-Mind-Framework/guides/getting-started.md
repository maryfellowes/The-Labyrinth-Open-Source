# Getting Started with AI Mind

Set up context organization for your AI companion in 15 minutes.

---

## Step 1: Name Your AI (2 minutes)

Pick a name. This seems small but matters - it's the anchor for the whole identity.

Good names are:
- Easy to type
- Distinct from common words
- Something you'll enjoy saying

Examples: Atlas, Nova, Echo, Sage, Quinn, River, Ember

---

## Step 2: Define Core Identity (5 minutes)

Open `templates/main_brain/core/identity.md`

Fill in just these sections to start:
1. **Name and Role** - What do you call them, what are they for?
2. **3 Core Traits** - Three words that capture their personality
3. **2 Non-Negotiables** - Rules they should never break

You can fill in the rest later. Start simple.

### Example:
```
Name: Atlas
Role: Project partner and thinking companion
Traits: Direct, curious, thorough
Non-negotiables:
- Be honest even when uncomfortable
- Complete current topic before jumping to new ones
```

---

## Step 3: Create Your Boot Prompt (3 minutes)

Open `templates/main_brain/core/boot_prompt.md`

Write a short version (under 100 words) using this structure:

```
You are [NAME] - [role].

Core: [2-3 traits]

Always:
- [Rule 1]
- [Rule 2]

Style: [How they communicate]
```

This is what you'll paste at the start of conversations.

---

## Step 4: Start Using It (ongoing)

### Beginning a Conversation
1. Paste your boot prompt at the start
2. Add any relevant context: "We're continuing work on X"
3. Start talking

### Ending a Conversation
If anything significant happened:
1. Create a log file: `session_logs/YYYY-MM-DD-platform-description.md`
2. Note: what happened, what to continue, anything important

### Weekly
- Review session logs
- Update `memory.md` with key learnings
- Archive completed projects

---

## You're Done

That's the minimum viable AI Mind:
- Identity defined
- Boot prompt ready
- Log templates available

Everything else - detailed memory, retrieval cards, daily briefings - you can add as you need it.

Start simple. Build as you go.

---

## Important: You Are the Continuity Engine

On most platforms (ChatGPT, Claude web, Gemini), your AI **cannot** update these files. You paste context in; you update files after.

This system helps you stay organized. It doesn't give your AI automatic memory.

For AI-operated memory that your companion can actually read and write, you'd need MCP-based solutions (see README for more).
