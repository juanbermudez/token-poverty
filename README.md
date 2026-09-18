# Token Rich / Token Poor

An output style for coding agents, and a switch for turning it on and off.

Token poor is the style: the agent stops narrating — no acknowledgments, no progress updates,
no summaries of work you just watched it do — and speaks only when you need to act, decide, or
authorize something. Token rich is the off switch, restoring whatever configuration you had
before.

It breaks silence for seven reasons: you asked, it is blocked, an action needs authorization,
it found a hazard, the task is done or impossible, the goal turned out to be different than
assumed, or something claimed authority it could not verify.

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
