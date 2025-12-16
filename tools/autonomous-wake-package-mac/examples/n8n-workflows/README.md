# N8N Workflow Examples

These workflow templates demonstrate how to integrate N8N with the Autonomous Wake-Up System. Each workflow generates task files that your AI agent processes during wake-ups.

## Setup

1. Import the workflow JSON into your N8N instance
2. Configure credentials (GA4, WordPress, etc.)
3. Update file paths to match your `tasks/pending/` directory
4. Enable the workflow

## Workflows Included

### 1. `analytics-monitor.json`
Monitors Google Analytics 4 for traffic anomalies and generates investigation tasks.

**Triggers**: Daily at 8am
**Creates tasks when**:
- Traffic drops >30% vs previous week
- Unusual traffic spikes
- Pages with sudden ranking changes

### 2. `content-audit.json`
Reviews content performance and generates optimization tasks.

**Triggers**: Weekly on Monday
**Creates tasks for**:
- Old posts that need updates
- Underperforming content
- Missing internal links
- SEO opportunities

### 3. `task-generator-webhook.json`
Generic webhook that lets you create tasks from any source.

**Triggers**: Webhook call
**Use cases**:
- Manual task creation via API
- Integration with other tools
- Zapier/Make.com connections

### 4. `daily-context-update.json`
Aggregates daily data and updates context files for your AI.

**Triggers**: End of day (6pm)
**Updates**:
- `context/analytics.md` - Today's traffic summary
- `context/projects.md` - Recent git commits
- `context/calendar.md` - Tomorrow's events

## File Writing

All workflows use N8N's "Write Binary File" or "Write File" nodes to create task files. The key is writing properly formatted JSON to your `tasks/pending/` directory.

Example N8N function to generate a task file:

```javascript
// In a Function node
const task = {
  id: `${$node.name}-${Date.now()}`,
  type: "content_optimization",
  priority: "medium",
  created: new Date().toISOString(),
  source: $workflow.name,
  context: $input.all()[0].json,
  instructions: "Review this content and suggest improvements.",
  tools_allowed: ["WebSearch", "Read", "Write"],
  result: null,
  status: "pending",
  completed_at: null
};

return [{
  json: task,
  binary: {
    data: await this.helpers.prepareBinaryData(
      Buffer.from(JSON.stringify(task, null, 2)),
      `${task.id}.json`
    )
  }
}];
```

## Path Configuration

Update these paths in each workflow to match your setup:

```
/Users/YOUR_USERNAME/Documents/AI-Companion/tasks/pending/
/Users/YOUR_USERNAME/Documents/AI-Companion/context/
```

Or use environment variables in N8N for cleaner configuration.

## Webhook Security

For the webhook workflow, consider:
- Adding authentication (API key header)
- IP whitelisting
- Rate limiting

## Tips

- **Test manually first**: Run workflows manually before enabling schedules
- **Check file permissions**: N8N needs write access to your AI-Companion folder
- **Monitor task queue**: If pending tasks pile up, adjust workflow frequency
- **Use priority levels**: Mark truly urgent things as "urgent" so they're processed first
