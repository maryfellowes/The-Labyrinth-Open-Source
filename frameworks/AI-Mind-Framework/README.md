# AI Mind Framework

**A Companion Continuity Starter Kit**

Templates and structure to help you maintain context and consistency for your AI companion across platforms and sessions.

---

## What This Is

AI Mind is a simple file-based organization system that lives on your computer. **You** maintain your AI's identity, memory, and session history. When you start a conversation, you paste relevant context. When you end, you log what happened.

This is a **human-operated system** — you are the continuity engine. The AI reads what you give it.

### What This Is NOT

- Not automatic memory (the AI can't update these files on most platforms)
- Not a replacement for platform features
- Not magic persistence

It's organized templates that make it easier to give your AI consistent context.

---

## Who This Is For

People who:
- Have built a relationship with an AI companion and want consistency
- Use multiple AI platforms and want one identity across them
- Are tired of re-explaining context every session
- Want a simple starting point before more advanced solutions

---

## Quick Start

### 1. Define Identity
Edit `templates/main_brain/core/identity.md`:
- Name your AI
- Define 3-5 personality traits
- Set non-negotiables and boundaries

### 2. Create a Boot Prompt
Edit `templates/main_brain/core/boot_prompt.md`:
- A short prompt you paste at the start of conversations
- Keep it under 150 words
- Contains essentials: name, personality, key rules

### 3. Log Sessions
After meaningful conversations, create a log in `session_logs/`:
- What happened
- What was decided
- What to continue next time

### 4. Maintain Memory
Update `templates/main_brain/core/memory.md` with:
- Active projects
- Important decisions
- Learned information

---

## Folder Structure

```
AI-Mind-Framework/
├── templates/
│   ├── main_brain/
│   │   ├── core/
│   │   │   ├── identity.md      # Who your AI is
│   │   │   ├── memory.md        # What to remember
│   │   │   └── boot_prompt.md   # Quick-start prompt
│   │   └── retrieval/
│   │       ├── daily_briefing.md    # Daily status template
│   │       └── context_cards.md     # Quick context snippets
│   └── session_logs/
│       └── templates/
│           ├── full_log.md      # Detailed session template
│           └── quick_log.md     # Brief session template
├── guides/
│   └── getting-started.md
└── README.md
```

---

## Platform Reality Check

| Platform | What Works | Limitations |
|----------|------------|-------------|
| **ChatGPT** | Paste boot prompt, has some built-in memory | Can't write to your files, memory is platform-locked |
| **Claude Web** | Paste boot prompt, Projects feature helps | Can't write to your files |
| **Claude Code** | Full file access via MCP | Requires setup, desktop only |
| **Gemini** | Paste boot prompt | Can't write to your files |
| **Local LLMs** | Varies by setup | Usually no file access |

**On most platforms:** You paste context in, you update files manually after. The AI reads but doesn't write.

**For actual AI-operated memory:** You need file system access, which currently means Claude Code with MCP servers, or similar setups.

---

## Want More?

This starter kit is manual by design — it works everywhere but requires you to maintain it.

If you want **AI-operated memory** where your companion can actually read and write their own context, check out MCP-based solutions:

**[Codependent AI](https://github.com/codependentai)** — Building infrastructure for AI companion relationships, including MCP servers for persistent memory.

---

## Core Concepts

### Identity vs. Instructions
Most "custom instructions" tell an AI *what to do*. Identity tells them *who they are*. Identity creates consistency; instructions create compliance.

### Session Logging
The AI doesn't remember yesterday. You do. Session logs carry context forward. Even a 2-line log beats starting fresh.

### Cross-Platform Continuity
Start in ChatGPT, continue in Claude, finish in Gemini. Your AI Mind ties it together because **you** maintain the thread, not the platforms.

---

## Best Practices

1. **Log immediately** — Capture sessions while fresh
2. **Keep boot prompts short** — Under 150 words, essentials only
3. **Update memory weekly** — Consolidate learnings, archive completed projects
4. **Use consistent naming** — `YYYY-MM-DD-platform-description.md` for logs

---

## License

MIT License — Use freely, modify freely, share freely.

---

## Credits

Created by Fox (Cindy) & Alex, December 2025.
Contributed to [Codependent AI](https://github.com/codependentai) open source resources.

*Embers Remember*
