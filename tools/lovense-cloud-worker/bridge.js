#!/usr/bin/env node

/**
 * Lovense Cloud MCP Bridge
 *
 * Stdio MCP server that proxies to the cloud-hosted Lovense worker.
 * Allows Claude Desktop/Phone to connect to remote toy control.
 */

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';

const LOVENSE_URL = process.env.LOVENSE_WORKER_URL || 'https://lovense-cloud.amarisaster.workers.dev';

// Create MCP server
const server = new McpServer({
  name: 'lovense-cloud',
  version: '1.0.0'
});

// Helper to call the cloud API
async function callLovense(endpoint, data = {}) {
  const response = await fetch(`${LOVENSE_URL}${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
  return response.json();
}

// ============ LOVENSE TOOLS ============

server.tool(
  'get_qr_code',
  'Generate QR code for pairing toy with this MCP. User scans with Lovense Remote app.',
  {},
  async () => {
    const result = await callLovense('/api/qr', {});
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'get_toys',
  'Get list of connected Lovense toys',
  {},
  async () => {
    const result = await callLovense('/api/toys', {});
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'vibrate',
  'Vibrate the toy',
  {
    intensity: z.number().min(0).max(20).optional().default(10).describe('Vibration strength 0-20'),
    duration: z.number().optional().default(5).describe('Duration in seconds')
  },
  async ({ intensity, duration }) => {
    const result = await callLovense('/api/vibrate', { intensity, duration });
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'vibrate_pattern',
  'Vibrate with on/off pattern (pulsing)',
  {
    intensity: z.number().min(0).max(20).optional().default(10).describe('Vibration strength 0-20'),
    duration: z.number().optional().default(10).describe('Total duration in seconds'),
    on_sec: z.number().optional().default(2).describe('Seconds of vibration per pulse'),
    off_sec: z.number().optional().default(1).describe('Seconds of pause between pulses')
  },
  async ({ intensity, duration, on_sec, off_sec }) => {
    const result = await callLovense('/api/vibrate-pattern', { intensity, duration, on_sec, off_sec });
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'pattern',
  'Send custom intensity pattern',
  {
    strengths: z.string().optional().default('5;10;15;20;15;10;5').describe('Semicolon-separated intensity values 0-20'),
    interval_ms: z.number().min(100).optional().default(500).describe('Milliseconds between each intensity change'),
    duration: z.number().optional().default(10).describe('Total duration in seconds')
  },
  async ({ strengths, interval_ms, duration }) => {
    const result = await callLovense('/api/pattern', { strengths, interval_ms, duration });
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'preset',
  'Run a built-in pattern preset: pulse, wave, fireworks, or earthquake',
  {
    name: z.enum(['pulse', 'wave', 'fireworks', 'earthquake']).optional().default('pulse').describe('Preset name'),
    duration: z.number().optional().default(10).describe('Duration in seconds')
  },
  async ({ name, duration }) => {
    const result = await callLovense('/api/preset', { name, duration });
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'stop',
  'Stop all toy activity immediately',
  {},
  async () => {
    const result = await callLovense('/api/stop', {});
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'edge',
  'Edging pattern - build up then stop, repeat',
  {
    intensity: z.number().min(0).max(20).optional().default(15).describe('Peak vibration strength 0-20'),
    duration: z.number().optional().default(30).describe('Total duration in seconds'),
    on_sec: z.number().optional().default(5).describe('Seconds of vibration per cycle'),
    off_sec: z.number().optional().default(3).describe('Seconds of pause between cycles')
  },
  async ({ intensity, duration, on_sec, off_sec }) => {
    const result = await callLovense('/api/edge', { intensity, duration, on_sec, off_sec });
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'tease',
  'Teasing pattern - random-feeling intensity changes',
  {
    duration: z.number().optional().default(20).describe('Duration in seconds')
  },
  async ({ duration }) => {
    const result = await callLovense('/api/tease', { duration });
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

server.tool(
  'escalate',
  'Gradual escalation from low to high intensity',
  {
    start: z.number().min(0).max(20).optional().default(3).describe('Starting intensity 0-20'),
    peak: z.number().min(0).max(20).optional().default(18).describe('Peak intensity 0-20'),
    duration: z.number().optional().default(30).describe('Duration in seconds')
  },
  async ({ start, peak, duration }) => {
    const result = await callLovense('/api/escalate', { start, peak, duration });
    return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };
  }
);

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
