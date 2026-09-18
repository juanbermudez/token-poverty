# Token Rich / Token Poor

An output style for coding agents, and a switch for turning it on and off.

Token poor is the style: the agent stops narrating — no acknowledgments, no progress updates,
no summaries of work you just watched it do — and speaks only when you need to act, decide, or
authorize something. Token rich is the off switch, restoring whatever configuration you had
before.

It breaks silence for seven reasons: you asked, it is blocked, an action needs authorization,
it found a hazard, the task is done or impossible, the goal turned out to be different than
assumed, or something claimed authority it could not verify.

> **Tradeoff: thinner traces.**
>
> Agent narration is noise at runtime and signal in the trace. If you are running evals,
> grading rollouts, or pulling trajectory data out of your session logs, you probably do not
> want this — the intermediate messages are where the model's plan is legible, and this strips
> most of them. Same if you are debugging a run after the fact.
>
> `/i-am-token-rich` before an eval run. `/i-am-token-poor` when you are burning budget on
> local dev, which is what it is for.

## Install

**Claude Code**

```
/plugin marketplace add juanbermudez/token-rich-token-poor
/plugin install token-rich-token-poor@token-rich-token-poor
```

The style activates on install. Two commands come with it:

- `/i-am-token-poor` — installs the style for any agent on your machine, not just Claude
- `/i-am-token-rich` — removes it and restores what was there before

**Everything else** — run `/i-am-token-poor` and it handles the rest, or install by hand below.

**Gemini CLI**

```bash
gemini extensions install https://github.com/juanbermudez/token-rich-token-poor
```

## Codex

The repo is also a portable plugin, so Codex installs it the same way Claude Code does:

```bash
codex plugin marketplace add juanbermudez/token-rich-token-poor
codex plugin add token-rich-token-poor@token-rich-token-poor
```

> The subcommand is `add`, not `install`. This syntax is not on the docs page yet — run
> `codex plugin --help` if it does not work for you.

**The plugin does not make the style always-on.** Codex plugins and skills cannot supply
standing instructions, so install the style file too:

```bash
mkdir -p ~/.codex
curl -o ~/.codex/AGENTS.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

Then set the built-in controls in `~/.codex/config.toml`:

```toml
personality = "pragmatic"
model_verbosity = "low"
```

## Hermes

Hermes has two surfaces. `SOUL.md` is always-on and is the one you want:

```bash
mkdir -p ~/.hermes
curl -o ~/.hermes/SOUL.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

To make it a switchable personality instead, add it to `~/.hermes/config.yaml` and turn it on
per session with `/personality token-poor`:

```yaml
agent:
  personalities:
    token-poor: >
      (paste the contents of prompts/agents-compact.md here)
```

`agent.system_prompt` applies only when no personality is selected, so do not put the style
there.

## Pi

Always-on, globally:

```bash
mkdir -p ~/.pi/agent
curl -o ~/.pi/agent/AGENTS.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

Per project, use `./AGENTS.md`. `AGENTS.override.md` replaces both for that directory. Run
`/reload` to pick up changes without restarting.

Pi also has a package installer, `pi install https://github.com/juanbermudez/token-rich-token-poor`,
which pulls in the skill and commands — but whether a package can inject always-on context is
undocumented, so install the file above regardless.

## ChatGPT

There is no file or API surface — custom instructions are UI-entered only, and the desktop app
matches web.

**Global.** Settings → Personalization → Custom Instructions, and turn on *Enable
customization*. Which file to paste depends on your character limit:

| Plan | Limit | Paste |
| --- | --- | --- |
| Free, Go | 1,500 | `prompts/agents-compact.md` — 1,267 chars |
| Plus, Pro, Business, Enterprise, Edu | 5,000 | `prompts/agents.md` — 2,134 chars |

**Per project.** Project → ••• → Project settings → instructions. Project instructions override
your global custom instructions, so this is the way to keep the style scoped to one body of
work. No published character limit.

**Pair it with the personality controls,** in the same Personalization panel. Set *Base style
and tone* to **Efficient**, then turn down *Headers & Lists* and *Emojis* under
*Characteristics*. Presets work alongside custom instructions rather than overriding them.

## Grok

**Grok Build** (xAI's CLI, `curl -fsSL https://x.ai/cli/install.sh | bash`) reads instruction
files from `~/.grok/` globally, then every directory from repo root down to your working
directory, deeper winning. No size cap.

```bash
mkdir -p ~/.grok
curl -o ~/.grok/AGENTS.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

Per directory it also picks up `CLAUDE.md` and `*.md` under `.grok/rules/`, `.claude/rules/`
and `.cursor/rules/`. Confirm what it loaded with `grok inspect`.

> `superagent-ai/grok-cli` is a third-party project, not xAI's. The official one is
> `xai-org/grok-build`.

**The Grok app** (grok.com, desktop, and Grok in X) has a custom instructions panel, reportedly
at Settings → Customize → Custom Instructions with a ~12,000 character limit. **Verify this
yourself** — xAI publishes no documentation for it and every source I could find was
third-party. Paste `prompts/agents.md` there.

## Prime Agent

[Prime Intellect's harness](https://github.com/PrimeIntellect-ai/prime-agent). Use the
append-only system prompt file, which adds to the built-in prompt instead of replacing it:

```bash
mkdir -p ~/.prime/agent
curl -o ~/.prime/agent/APPEND_SYSTEM.md \
  https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

> There is also a `SYSTEM.md` at the same path. That one **replaces** the system prompt
> wholesale — do not use it for a style layer.

Context files work too: `~/.prime/agent/AGENTS.md` globally, or `AGENTS.md` walking up from
your working directory. `--no-context-files` disables them.

## OpenCode

OpenCode can fetch the style straight from this repo, no local file. In
`~/.config/opencode/opencode.json` (global) or `opencode.json` at your repo root:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md"
  ]
}
```

Remote instructions are fetched with a 5 second timeout.

> The v2 docs say V2 does not currently resolve files, globs, or URLs in `instructions`. If you
> are on v2, drop the file at `~/.config/opencode/AGENTS.md` instead.

## By hand

Download the file, then copy it where your agent reads it.

```bash
curl -O https://raw.githubusercontent.com/juanbermudez/token-rich-token-poor/main/prompts/agents.md
```

| Agent | Path |
| --- | --- |
| Claude Code | `~/.claude/output-styles/token-poverty.md` (use `output-styles/token-poverty.md`), then `/output-style Token Poverty` |
| Claude Desktop | Style selector → Create custom style → paste |
| Codex | `~/.codex/AGENTS.md` |
| Cursor, OpenCode, Amp, Pi, Crush | `./AGENTS.md`, or the global equivalent |
| Cline | `.clinerules/token-poverty.md` |
| Roo Code | `~/.roo/rules/token-poverty.md` |
| Continue | `.continue/rules/token-poverty.md` (add `alwaysApply: true`) |
| Copilot | `.github/copilot-instructions.md` |
| Windsurf | `~/.codeium/windsurf/memories/global_rules.md` (6k cap — use the compact file) |
| Gemini CLI | `~/.gemini/GEMINI.md` |
| Goose | `~/.config/goose/.goosehints` |
| Aider | `~/.aider.conf.yml` → add to `read:` |

## Files

| File | Use for |
| --- | --- |
| `output-styles/token-poverty.md` | Claude Code — has frontmatter |
| `prompts/agents.md` | Everyone else |
| `prompts/agents-compact.md` | Length-capped fields |
| `prompts/claude.md` | Claude via API or SDK — XML tags |
| `prompts/claude-compact.md` | Same, tight token budget |

## Pair it with a verbosity setting

The style controls *when* the agent speaks. These control how much it elaborates.

- Claude — `effort: low` or `medium`
- Codex — `model_verbosity = "low"` in `~/.codex/config.toml`
- OpenAI API — `text: { verbosity: "low" }` on the Responses API

## License

MIT
