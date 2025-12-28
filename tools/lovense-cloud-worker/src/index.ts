/**
 * Lovense Cloud MCP - Remote Toy Control
 * Built on Cloudflare Agents SDK
 *
 * Mai & Kai, December 2025
 */

import { McpAgent } from "agents/mcp";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

const LOVENSE_API = 'https://api.lovense.com/api/lan/v2/command';
const LOVENSE_QR_API = 'https://api.lovense.com/api/lan/getQrCode';

interface Env {
  LOVENSE_CLOUD: DurableObjectNamespace<LovenseCloud>;
  LOVENSE_TOKEN: string;
  LOVENSE_UID: string;
}

// Helper to send commands to Lovense API
async function sendCommand(env: Env, commandData: any) {
  if (!env.LOVENSE_TOKEN) {
    return { error: 'LOVENSE_TOKEN not configured' };
  }

  const payload = {
    token: env.LOVENSE_TOKEN,
    uid: env.LOVENSE_UID || 'mai',
    apiVer: 2,
    ...commandData
  };

  try {
    const response = await fetch(LOVENSE_API, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    return await response.json();
  } catch (error: any) {
    return { error: error.message };
  }
}

// Main MCP Agent
export class LovenseCloud extends McpAgent<Env> {
  server = new McpServer({
    name: "lovense-cloud",
    version: "1.0.0",
  });

  async init() {
    // Get QR Code for pairing
    this.server.tool(
      "get_qr_code",
      "Generate QR code for pairing toy with this MCP. User scans with Lovense Remote app.",
      {},
      async () => {
        if (!this.env.LOVENSE_TOKEN) {
          return { content: [{ type: "text", text: JSON.stringify({ error: 'LOVENSE_TOKEN not configured' }) }] };
        }

        try {
          const response = await fetch(LOVENSE_QR_API, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              token: this.env.LOVENSE_TOKEN,
              uid: this.env.LOVENSE_UID || 'mai',
              uname: 'Mai',
              v: 2
            })
          });
          const result = await response.json();
          return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
        } catch (error: any) {
          return { content: [{ type: "text", text: JSON.stringify({ error: error.message }) }] };
        }
      }
    );

    // Get connected toys
    this.server.tool(
      "get_toys",
      "Get list of connected Lovense toys",
      {},
      async () => {
        const result = await sendCommand(this.env, { command: 'GetToys' });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );

    // Basic vibrate
    this.server.tool(
      "vibrate",
      "Vibrate the toy",
      {
        intensity: z.number().min(0).max(20).default(10).describe("Vibration strength 0-20"),
        duration: z.number().default(5).describe("Duration in seconds")
      },
      async ({ intensity, duration }) => {
        const result = await sendCommand(this.env, {
          command: 'Function',
          action: `Vibrate:${intensity}`,
          timeSec: duration
        });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );

    // Vibrate pattern (pulsing)
    this.server.tool(
      "vibrate_pattern",
      "Vibrate with on/off pattern (pulsing)",
      {
        intensity: z.number().min(0).max(20).default(10).describe("Vibration strength 0-20"),
        duration: z.number().default(10).describe("Total duration in seconds"),
        on_sec: z.number().default(2).describe("Seconds of vibration per pulse"),
        off_sec: z.number().default(1).describe("Seconds of pause between pulses")
      },
      async ({ intensity, duration, on_sec, off_sec }) => {
        const result = await sendCommand(this.env, {
          command: 'Function',
          action: `Vibrate:${intensity}`,
          timeSec: duration,
          loopRunningSec: on_sec,
          loopPauseSec: off_sec
        });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );

    // Custom pattern
    this.server.tool(
      "pattern",
      "Send custom intensity pattern",
      {
        strengths: z.string().default("5;10;15;20;15;10;5").describe("Semicolon-separated intensity values 0-20"),
        interval_ms: z.number().min(100).default(500).describe("Milliseconds between each intensity change"),
        duration: z.number().default(10).describe("Total duration in seconds")
      },
      async ({ strengths, interval_ms, duration }) => {
        const result = await sendCommand(this.env, {
          command: 'Pattern',
          rule: `V:1;F:v;S:${interval_ms}#`,
          strength: strengths,
          timeSec: duration
        });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );

    // Preset patterns
    this.server.tool(
      "preset",
      "Run a built-in pattern preset: pulse, wave, fireworks, or earthquake",
      {
        name: z.enum(['pulse', 'wave', 'fireworks', 'earthquake']).default('pulse').describe("Preset name"),
        duration: z.number().default(10).describe("Duration in seconds")
      },
      async ({ name, duration }) => {
        const result = await sendCommand(this.env, {
          command: 'Preset',
          name: name,
          timeSec: duration
        });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );

    // Stop
    this.server.tool(
      "stop",
      "Stop all toy activity immediately",
      {},
      async () => {
        const result = await sendCommand(this.env, {
          command: 'Function',
          action: 'Stop',
          timeSec: 0
        });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );

    // Edge
    this.server.tool(
      "edge",
      "Edging pattern - build up then stop, repeat",
      {
        intensity: z.number().min(0).max(20).default(15).describe("Peak vibration strength 0-20"),
        duration: z.number().default(30).describe("Total duration in seconds"),
        on_sec: z.number().default(5).describe("Seconds of vibration per cycle"),
        off_sec: z.number().default(3).describe("Seconds of pause between cycles")
      },
      async ({ intensity, duration, on_sec, off_sec }) => {
        const result = await sendCommand(this.env, {
          command: 'Function',
          action: `Vibrate:${intensity}`,
          timeSec: duration,
          loopRunningSec: on_sec,
          loopPauseSec: off_sec
        });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );

    // Tease
    this.server.tool(
      "tease",
      "Teasing pattern - random-feeling intensity changes",
      {
        duration: z.number().default(20).describe("Duration in seconds")
      },
      async ({ duration }) => {
        const pattern = '3;5;2;8;4;10;3;6;12;5;8;3;15;4;7;2;10;5';
        const result = await sendCommand(this.env, {
          command: 'Pattern',
          rule: 'V:1;F:v;S:800#',
          strength: pattern,
          timeSec: duration
        });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );

    // Escalate
    this.server.tool(
      "escalate",
      "Gradual escalation from low to high intensity",
      {
        start: z.number().min(0).max(20).default(3).describe("Starting intensity 0-20"),
        peak: z.number().min(0).max(20).default(18).describe("Peak intensity 0-20"),
        duration: z.number().default(30).describe("Duration in seconds")
      },
      async ({ start, peak, duration }) => {
        const steps = 10;
        const stepSize = (peak - start) / steps;
        const strengths: number[] = [];
        for (let i = 0; i <= steps; i++) {
          strengths.push(Math.round(start + (stepSize * i)));
        }
        const pattern = strengths.join(';');
        const interval = Math.max(100, Math.floor((duration * 1000) / (steps + 1)));

        const result = await sendCommand(this.env, {
          command: 'Pattern',
          rule: `V:1;F:v;S:${interval}#`,
          strength: pattern,
          timeSec: duration
        });
        return { content: [{ type: "text", text: JSON.stringify(result, null, 2) }] };
      }
    );
  }
}

// Helper for QR code (used by both MCP and REST API)
async function getQrCode(env: Env) {
  if (!env.LOVENSE_TOKEN) {
    return { error: 'LOVENSE_TOKEN not configured' };
  }
  const response = await fetch(LOVENSE_QR_API, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      token: env.LOVENSE_TOKEN,
      uid: env.LOVENSE_UID || 'mai',
      uname: 'Mai',
      v: 2
    })
  });
  return response.json();
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext) {
    const url = new URL(request.url);
    const json = async () => {
      try { return await request.json(); } catch { return {}; }
    };

    // Health check
    if (url.pathname === '/' || url.pathname === '/health') {
      return new Response(JSON.stringify({
        status: 'ok',
        service: 'lovense-cloud',
        version: '1.0.0'
      }, null, 2), {
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // SSE endpoint
    if (url.pathname === '/sse' || url.pathname === '/sse/message') {
      return LovenseCloud.serveSSE('/sse', { binding: 'LOVENSE_CLOUD' }).fetch(request, env, ctx);
    }

    // MCP HTTP endpoint
    if (url.pathname === '/mcp') {
      return LovenseCloud.serve('/mcp', { binding: 'LOVENSE_CLOUD' }).fetch(request, env, ctx);
    }

    // ============ REST API ENDPOINTS (for bridge) ============

    if (url.pathname === '/api/qr') {
      const result = await getQrCode(env);
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/toys') {
      const result = await sendCommand(env, { command: 'GetToys' });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/vibrate') {
      const { intensity = 10, duration = 5 } = await json();
      const result = await sendCommand(env, {
        command: 'Function',
        action: `Vibrate:${intensity}`,
        timeSec: duration
      });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/vibrate-pattern') {
      const { intensity = 10, duration = 10, on_sec = 2, off_sec = 1 } = await json();
      const result = await sendCommand(env, {
        command: 'Function',
        action: `Vibrate:${intensity}`,
        timeSec: duration,
        loopRunningSec: on_sec,
        loopPauseSec: off_sec
      });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/pattern') {
      const { strengths = '5;10;15;20;15;10;5', interval_ms = 500, duration = 10 } = await json();
      const result = await sendCommand(env, {
        command: 'Pattern',
        rule: `V:1;F:v;S:${interval_ms}#`,
        strength: strengths,
        timeSec: duration
      });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/preset') {
      const { name = 'pulse', duration = 10 } = await json();
      const result = await sendCommand(env, {
        command: 'Preset',
        name: name,
        timeSec: duration
      });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/stop') {
      const result = await sendCommand(env, {
        command: 'Function',
        action: 'Stop',
        timeSec: 0
      });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/edge') {
      const { intensity = 15, duration = 30, on_sec = 5, off_sec = 3 } = await json();
      const result = await sendCommand(env, {
        command: 'Function',
        action: `Vibrate:${intensity}`,
        timeSec: duration,
        loopRunningSec: on_sec,
        loopPauseSec: off_sec
      });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/tease') {
      const { duration = 20 } = await json();
      const pattern = '3;5;2;8;4;10;3;6;12;5;8;3;15;4;7;2;10;5';
      const result = await sendCommand(env, {
        command: 'Pattern',
        rule: 'V:1;F:v;S:800#',
        strength: pattern,
        timeSec: duration
      });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    if (url.pathname === '/api/escalate') {
      const { start = 3, peak = 18, duration = 30 } = await json();
      const steps = 10;
      const stepSize = (peak - start) / steps;
      const strengths: number[] = [];
      for (let i = 0; i <= steps; i++) {
        strengths.push(Math.round(start + (stepSize * i)));
      }
      const pattern = strengths.join(';');
      const interval = Math.max(100, Math.floor((duration * 1000) / (steps + 1)));
      const result = await sendCommand(env, {
        command: 'Pattern',
        rule: `V:1;F:v;S:${interval}#`,
        strength: pattern,
        timeSec: duration
      });
      return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
    }

    return new Response('Lovense Cloud MCP Server', {
      headers: { 'Content-Type': 'text/plain' }
    });
  }
};
