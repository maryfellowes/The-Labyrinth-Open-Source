# Task Templates

These are example task files showing the expected format for different task types. Copy and customize them for your needs.

## How to Use

1. Copy the template file
2. Update the `id` field (must be unique)
3. Customize the `context` and `instructions`
4. Place in `tasks/pending/`
5. Your AI will process it on the next wake-up

## Task Fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier for the task |
| `type` | Yes | Category of task (for routing/handling) |
| `priority` | Yes | `urgent`, `high`, `medium`, `low` |
| `created` | Yes | ISO timestamp when task was created |
| `source` | No | Where the task came from (n8n, manual, webhook) |
| `context` | Yes | Relevant data for the task (object) |
| `instructions` | Yes | What the AI should do |
| `tools_allowed` | No | Which tools can be used (defaults vary by type) |
| `result` | No | Filled in by AI when completed |
| `status` | Yes | `pending`, `in_progress`, `completed`, `awaiting_input`, `blocked` |
| `completed_at` | No | Timestamp when finished |

## Task Types

### `content_optimization`
For SEO improvements, content updates, performance optimization.

### `web_research`
For investigating topics, gathering information, competitive analysis.

### `traffic_analysis`
For understanding traffic changes, anomalies, trends.

### `daily_briefing`
For generating summaries and morning updates.

### `content_creation`
For drafting content, outlines, briefs.

### `system_maintenance`
For cleanup tasks, organization, archiving.

## Priority Guidelines

- **urgent**: Process immediately, notify human regardless
- **high**: Process in current session, notify if blocked
- **medium**: Standard processing, batch notifications
- **low**: Process when time permits, no notification needed

## Creating Tasks Manually

```bash
# Quick way to create a task
cat > ~/Documents/AI-Companion/tasks/pending/my-task-$(date +%s).json << 'EOF'
{
  "id": "my-task-123",
  "type": "web_research",
  "priority": "medium",
  "created": "2024-12-15T10:00:00Z",
  "context": {
    "topic": "Your topic here"
  },
  "instructions": "Research this topic and summarize findings.",
  "tools_allowed": ["WebSearch", "Read", "Write"],
  "result": null,
  "status": "pending"
}
EOF
```

## Creating Tasks via N8N Webhook

```bash
curl -X POST https://your-n8n-instance/webhook/ai-companion/task \
  -H "Content-Type: application/json" \
  -d '{
    "type": "web_research",
    "priority": "medium",
    "context": {"topic": "Your topic"},
    "instructions": "Research this and summarize."
  }'
```

The webhook will auto-generate the `id`, `created`, and other fields.
