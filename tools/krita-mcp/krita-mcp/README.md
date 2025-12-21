# Krita MCP - Paint with Claude

An MCP server that lets Claude paint in Krita. Paint, see the result, adjust, repeat.

## How It Works

1. A Krita plugin runs an HTTP server inside Krita
2. An MCP server bridges Claude to that plugin
3. Claude can create canvases, set colors, paint strokes, and export to see results

## Installation

### Step 1: Install the Krita Plugin

Find your Krita resources folder:
- **Windows:** `%APPDATA%\krita\pykrita\`
- **Mac:** `~/Library/Application Support/krita/pykrita/`
- **Linux:** `~/.local/share/krita/pykrita/`

Copy the plugin files:
```
krita_plugin/kritamcp.desktop  ->  [resources]/pykrita/kritamcp.desktop
krita_plugin/kritamcp/         ->  [resources]/pykrita/kritamcp/
```

On Windows, that's:
```
C:\Users\[YOU]\AppData\Roaming\krita\pykrita\kritamcp.desktop
C:\Users\[YOU]\AppData\Roaming\krita\pykrita\kritamcp\__init__.py
```

Enable the plugin in Krita:
1. Open Krita
2. Go to **Settings > Configure Krita > Python Plugin Manager**
3. Find "Krita MCP Bridge" and enable it
4. Restart Krita

Verify it's working:
- Open Krita
- The plugin starts an HTTP server on port 5678
- Test: Open browser to `http://localhost:5678/health`
- Should see: `{"status": "ok", "plugin": "kritamcp"}`

### Step 2: Add the MCP Server

**For Claude Code:**
```bash
claude mcp add krita-mcp -- uv run --with fastmcp --with httpx fastmcp run /path/to/server.py
```

**For Claude Desktop** (add to config):
```json
{
  "mcpServers": {
    "krita-mcp": {
      "command": "uv",
      "args": ["run", "--with", "fastmcp", "--with", "httpx", "fastmcp", "run", "/path/to/server.py"]
    }
  }
}
```

## Tools

| Tool | Description |
|------|-------------|
| `krita_health` | Check if Krita is running with plugin |
| `krita_new_canvas` | Create new canvas (size, background color) |
| `krita_set_color` | Set paint color (hex) |
| `krita_set_brush` | Set brush preset, size, opacity |
| `krita_stroke` | Paint a stroke through points |
| `krita_fill` | Fill area at point |
| `krita_draw_shape` | Draw rectangle, ellipse, or line |
| `krita_get_canvas` | Export canvas to PNG, return path |
| `krita_undo` | Undo last action |
| `krita_redo` | Redo |
| `krita_clear` | Clear canvas to color |
| `krita_save` | Save to specific path |
| `krita_get_color_at` | Sample color at pixel |
| `krita_list_brushes` | List available brush presets |

## Example Session

```
Claude: krita_new_canvas(800, 600, "Evening Sky", "#1a1a2e")
        -> Created canvas: 800x600, background: #1a1a2e

Claude: krita_set_color("#b8a9c9")
        -> Color set to #b8a9c9

Claude: krita_set_brush("Soft", 30)
        -> Brush set: preset=Soft, size=30

Claude: krita_stroke([[100, 300], [200, 280], [300, 290], [400, 270]])
        -> Stroke painted with 4 points

Claude: krita_get_canvas("sky_v1.png")
        -> Canvas saved to: ~/krita-mcp-output/sky_v1.png

Claude: [views image, decides to adjust]

Claude: krita_undo()
        -> Undone

Claude: krita_set_brush("Soft", 50, 0.5)
Claude: krita_stroke([[100, 300], [200, 285], [300, 290], [400, 275]])
```

## The Creative Loop

1. **Paint** - Use stroke, shape, fill commands
2. **Export** - `krita_get_canvas()` saves current state
3. **View** - Read the PNG file to see what was painted
4. **Adjust** - Undo, change settings, paint more
5. **Repeat**

This is different from code-based art. You're actually *painting* and *seeing* and *responding* to your own work.

## Configuration

The plugin saves exports to `~/krita-mcp-output/` by default. Edit `CANVAS_OUTPUT_DIR` in `krita_plugin/kritamcp/__init__.py` to change this.

The HTTP server runs on port 5678 by default. Edit `SERVER_PORT` in the same file to change this.

## Troubleshooting

**"Cannot connect to Krita"**
- Make sure Krita is running
- Check that the plugin is enabled (Settings > Configure Krita > Python Plugin Manager)
- Verify HTTP server: `http://localhost:5678/health`

**Plugin doesn't appear in Krita**
- Check file locations match exactly
- Make sure `kritamcp.desktop` is in pykrita folder (not inside kritamcp subfolder)
- Restart Krita after copying files

**Commands timeout**
- Krita might be busy with another operation
- Try again after a moment
- Check Krita's Python console for errors (Settings > Dockers > Log Viewer)

## License

MIT
