# Token Rich / Token Poor

An output style for coding agents. The agent stops narrating and speaks only when you need to
act, decide, or authorize. Seven conditions break the silence: you asked, it is blocked, an
action needs authorization, it found a hazard, the task is done or impossible, the goal
changed, or something claimed authority it could not verify.

> **Tradeoff: thinner traces.** Narration is noise at runtime and signal in the trace. Running
> evals, grading rollouts, or pulling trajectory data? You probably do not want this. Turn it
> off first.

## Install

Detects your harnesses, asks scope and selection, shows the plan, writes nothing until you
confirm. Appends inside markers, never overwrites, fully reversible.

```bash
git clone https://github.com/juanbermudez/token-rich-token-poor
cd token-rich-token-poor && ./install.sh
```

```
--detect      what is installed here, tab-separated
--only a,b    limit to specific harnesses
--uninstall   reverse everything
```

Manual install per vendor below.

---

## OpenAI

**Codex** — plugin, then the style file (plugins cannot carry standing instructions):

```bash
codex plugin marketplace add juanbermudez/token-rich-token-poor
codex plugin add token-rich-token-poor@token-rich-token-poor
mkdir -p ~/.codex
curl -o ~/.codex/AGENTS.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

`~/.codex/config.toml`: `personality = "pragmatic"`, `model_verbosity = "low"`.

> The subcommand is `add`, not `install`. Avoid `model_instructions_file` — it replaces Codex's
> built-in instructions instead of adding to them.

**ChatGPT** — UI only. Settings → Personalization → Custom Instructions.
Free/Go caps at 1,500 chars, use `prompts/agents-compact.md` (1,267). Paid caps at 5,000, use
`prompts/agents.md` (2,134). Project settings → instructions overrides global, no cap.
Set *Base style and tone* to **Efficient**.

## Nous Research

**Hermes** — `SOUL.md` is the always-on surface.

```bash
mkdir -p ~/.hermes
curl -o ~/.hermes/SOUL.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

Switchable instead: a `token-poor` entry under `agent.personalities` in `~/.hermes/config.yaml`,
then `/personality token-poor`.

> Not `agent.system_prompt` — it only applies when no personality is selected.

## Anthropic

**Claude Code**

```
/plugin marketplace add juanbermudez/token-rich-token-poor
/plugin install token-rich-token-poor@token-rich-token-poor
```

Activates on install. `/i-am-token-poor` switches on or runs the installer; `/i-am-token-rich`
switches off.

Manually instead:

```bash
mkdir -p ~/.claude/output-styles
curl -o ~/.claude/output-styles/token-poverty.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/output-styles/token-poverty.md
```

Then `/output-style Token Poverty`. Pair with `effort: low`.

**Claude Desktop** — Styles, not output styles. Style selector → Create custom style → describe
it in your own words → paste `prompts/agents.md`.

## xAI

**Grok Build**

```bash
mkdir -p ~/.grok
curl -o ~/.grok/AGENTS.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

Reads `~/.grok/` then repo root down to cwd, deeper wins. Also picks up `CLAUDE.md` and
`.cursor/rules/`, so it may already see a style you installed elsewhere. `grok inspect` shows
what loaded. xAI's CLI is `xai-org/grok-build`; `superagent-ai/grok-cli` is third-party.

**Grok app** — Settings → Customize → Custom Instructions. Around 12,000 characters.

## Pi

```bash
mkdir -p ~/.pi/agent
curl -o ~/.pi/agent/AGENTS.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

Per project `./AGENTS.md`; `AGENTS.override.md` replaces both. `/reload` to apply.

## Prime Intellect

**Prime Agent**

```bash
mkdir -p ~/.prime/agent
curl -o ~/.prime/agent/APPEND_SYSTEM.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

> Not `SYSTEM.md` at that path — it replaces the system prompt wholesale.

## Vercel

**fx** ([vercel-labs/fx](https://github.com/vercel-labs/fx)) — a tiny native coding agent.

```bash
curl -fsSL https://fx.sh/setup.sh | bash
mkdir -p ~/.fx
curl -o ~/.fx/AGENTS.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

Precedence is direct request → `~/.fx/AGENTS.md` → workspace `AGENTS.md` → nearest
`AGENTS.md` to whatever a tool touches; narrowest scope wins. No verbosity knob exists.
`context: false` in `.fx.json` disables instruction loading entirely.

**eve** ([vercel/eve](https://github.com/vercel/eve)) is a framework for building durable
agents, not a CLI you install a style into. An eve agent is a directory on disk where
instructions and tools are files, so the style goes in your agent's instructions and ships with
the project.

```bash
npx eve init my-agent
```

The layout is documented in `node_modules/eve/docs/`.

## DeepSeek

DeepSeek has no first-party coding agent. Point a third-party harness (Claude Code, OpenCode)
at the DeepSeek API, install the style for that harness, and set `reasoning_effort` — `low`,
`high` or `max`, default `high`. Anthropic-format adds `none` to disable thinking. There is no
verbosity parameter.

> `deepcode-cli` is a community CLI that reads `AGENTS.md`. DeepSeek links it as an integration
> but does not maintain it.

## OpenCode

No local file. In `~/.config/opencode/opencode.json` or `opencode.json`:

```json
{ "instructions": ["https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md"] }
```

> V2 does not resolve URLs yet — use `~/.config/opencode/AGENTS.md` there.

## Everything else

| Agent | Path |
| --- | --- |
| Cursor, Amp, Crush | `./AGENTS.md` or global equivalent |
| Cline | `.clinerules/token-poverty.md` |
| Roo Code | `~/.roo/rules/token-poverty.md` |
| Continue | `.continue/rules/token-poverty.md` + `alwaysApply: true` |
| Copilot | `.github/copilot-instructions.md` |
| Windsurf | `~/.codeium/windsurf/memories/global_rules.md` — 6k cap, use compact |
| Goose | `~/.config/goose/.goosehints` |
| Aider | `~/.aider.conf.yml` → `read:` |

## Google

**Gemini CLI**

```bash
gemini extensions install https://github.com/juanbermudez/token-rich-token-poor
```

Or by hand at `~/.gemini/GEMINI.md`.

---

## Files

| File | For |
| --- | --- |
| `output-styles/token-poverty.md` | Claude Code — has frontmatter |
| `prompts/agents.md` | Everyone else |
| `prompts/agents-compact.md` | Length-capped fields |
| `prompts/claude.md` / `claude-compact.md` | Claude API — XML tags |

## Verbosity settings

The style sets *when* the agent speaks; these set how much.

| Provider | Setting |
| --- | --- |
| Anthropic | `output_config: { effort: "low" }` |
| OpenAI | `text: { verbosity: "low" }` — Responses API |
| Codex CLI | `model_verbosity = "low"` |
| xAI | `reasoning_effort` only, no verbosity |

MIT
