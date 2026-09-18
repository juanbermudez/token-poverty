# Token Rich / Token Poor

An output style for coding agents, and a switch for turning it on and off.

Token poor is the style: the agent stops narrating — no acknowledgments, no progress updates,
no summaries of work you just watched it do — and speaks only when you need to act, decide, or
authorize something. Token rich is the off switch, restoring whatever configuration you had
before.

It breaks silence for seven reasons: you asked, it is blocked, an action needs authorization,
it found a hazard, the task is done or impossible, the goal turned out to be different than
assumed, or something claimed authority it could not verify.

> **What it costs you: traces.**
>
> Terse output means thin session logs. Agent narration is noise when you are working, but it
> is signal when you are reading a run back — those messages are where the agent's trajectory
> shows up, and this style removes most of them. If you mine your logs, do trajectory analysis,
> or are debugging why a run went sideways, turn it off first with `/i-am-token-rich`.
>
> Turn it on when the budget is the constraint. That is what it is for — stretching an account
> through a long stretch of local development.

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
