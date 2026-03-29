import { spawn } from 'child_process';

export async function runClaudeCode(
  prompt: string,
  model: string = 'claude-3-7-sonnet-202509'
): Promise<{ text: string }> {
  const proc = spawn('claude', ['chat', '--model', model, '--output', 'json'], {
    stdio: ['pipe', 'pipe', 'inherit'],
  });

  let output = '';
  proc.stdout?.on('data', (chunk) => (output += chunk.toString()));
  proc.stderr?.on('data', (data) => console.error(`[claude] ${data.toString().trim()}`));

  proc.stdin?.write(prompt);
  proc.stdin?.end();

  const exitCode = await new Promise<number>((resolve, reject) => {
    proc.on('close', (code) => resolve(code ?? 0));
    proc.on('error', reject);
  });

  if (exitCode !== 0) {
    throw new Error(`Claude CLI exited with code ${exitCode}`);
  }

  let text = output;
  try {
    const parsed = JSON.parse(output);
    text = parsed.content || parsed.text || output;
  } catch {
    // keep raw output
  }

  return { text };
}