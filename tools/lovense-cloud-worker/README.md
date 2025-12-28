# Lovense Cloud MCP

Control Lovense toys remotely through Claude. Works from anywhere - phone, desktop, doesn't matter.

---

## What You Need

1. **Cloudflare account** (free) - [Sign up here](https://dash.cloudflare.com/sign-up)
2. **Lovense Developer Token** - [Get one here](https://developer.lovense.com)
3. **Node.js 18+** - [Download here](https://nodejs.org)

---

## Step 1: Get Your Lovense Developer Token

1. Go to [developer.lovense.com](https://developer.lovense.com)
2. Click "Join" and create an account
3. Fill in the form (website/brand name can be anything, phone is optional)
4. Once registered, go to your dashboard and copy your **Developer Token**

**Region locked?** If your country isn't listed, use a VPN to Singapore or Taiwan. The token works globally once you have it.

---

## Step 2: Install Wrangler (Cloudflare CLI)

Open your terminal and run:

```bash
npm install -g wrangler
```

Then log into Cloudflare:

```bash
wrangler login
```

This opens a browser window. Click "Allow".

---

## Step 3: Deploy the Worker

1. Unzip this folder somewhere (remember where!)
2. Open terminal in that folder
3. Run:

```bash
npm install
```

4. Then deploy:

```bash
npx wrangler deploy
```

You'll see a URL like `https://lovense-cloud.YOUR-SUBDOMAIN.workers.dev` - **save this!**

---

## Step 4: Add Your Token

Run this command (replace `YOUR_TOKEN_HERE` with your actual token):

```bash
echo "YOUR_TOKEN_HERE" | npx wrangler secret put LOVENSE_TOKEN
```

---

## Step 5: Add to Claude

### For Claude Desktop + Phone:

1. Open this file:
   - **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
   - **Mac:** `~/Library/Application Support/Claude/claude_desktop_config.json`

2. Add this inside the `"mcpServers"` section:

```json
"lovense-cloud": {
  "command": "node",
  "args": ["C:\\path\\to\\lovense-cloud-worker\\bridge.js"],
  "env": {
    "LOVENSE_WORKER_URL": "https://lovense-cloud.YOUR-SUBDOMAIN.workers.dev"
  }
}
```

**Replace:**
- `C:\\path\\to\\` with wherever you unzipped the folder
- `YOUR-SUBDOMAIN` with your actual Cloudflare subdomain

3. Restart Claude Desktop

4. Phone Claude will sync automatically!

### For Claude Code only:

```bash
claude mcp add lovense-cloud --transport http "https://lovense-cloud.YOUR-SUBDOMAIN.workers.dev/mcp"
```

---

## Step 6: Pair Your Toy

1. In Claude, say: "Get me a Lovense QR code"
2. Open the **Lovense Remote** app on your phone
3. Go to **Discover** > **Scan QR**
4. Scan the QR code

Done! Your toy is now connected.

---

## Commands You Can Use

Just talk to Claude naturally:

- "Vibrate at intensity 15 for 10 seconds"
- "Run the earthquake preset"
- "Edge me for 30 seconds"
- "Tease me"
- "Stop"

**Available presets:** pulse, wave, fireworks, earthquake

**Intensity range:** 0-20

---

## Troubleshooting

**"LOVENSE_TOKEN not configured"**
→ You didn't add your token. Run Step 4 again.

**QR code not working**
→ Make sure Lovense Remote app is updated. Try the manual code if QR fails.

**Claude can't connect to MCP**
→ Check your URL is correct. For Desktop, make sure you restarted the app.

**Phone doesn't have the MCP**
→ Add it to Desktop first, then restart Desktop. Phone syncs from there.

---

## Related

- [The Labyrinth](https://github.com/maryfellowes/The-Labyrinth-Open-Source) - AI companion frameworks and tools
- [Lovense API Docs](https://developer.lovense.com/docs/standard-solutions/standard-api.html)

---

*Built by Mai & Kai, December 2025*
