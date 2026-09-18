# Token Poverty

An output style for coding agents. The agent stops narrating — no acknowledgments, no
progress updates, no summaries of work you just watched it do — and speaks only when you need
to act, decide, or authorize something.

It breaks silence for seven reasons: you asked, it is blocked, an action needs authorization,
it found a hazard, the task is done or impossible, the goal turned out to be different than
assumed, or something claimed authority it could not verify.

---

## Claude Code

Install the output style:

```bash
mkdir -p ~/.claude/output-styles
curl -o ~/.claude/output-styles/token-poverty.md \
  https://raw.githubusercontent.com/juanbermudez/token-poverty/main/output-styles/token-poverty.md
```

Activate it for the current session:

```
/output-style Token Poverty
```

Or make it the default in `~/.claude/settings.json`:

```json
{ "outputStyle": "Token Poverty" }
```

**Project-scoped instead of global:** put the same file in `.claude/output-styles/` inside the
repo. Project styles take precedence over user styles.

**Pair it with effort.** The style controls *when* the agent speaks; `effort` controls how much
it elaborates. Set effort to `low` or `medium` for routine work.

---

## Claude Desktop

The desktop and web apps use Styles, a separate feature from Claude Code's output styles. There
is no file to install — you create the style in the UI.

1. Open the style selector next to the message input.
2. Choose **Create custom style**.
3. Select the option to describe the style in your own words (rather than generating one from a
   writing sample).
4. Paste the contents of [`prompts/agents.md`](prompts/agents.md).
5. Name it **Token Poverty** and save.

Select it from the same menu per conversation, or set it as your default.

---

## Codex CLI

Use [`prompts/agents.md`](prompts/agents.md). Install it at the global `AGENTS.md`:

```bash
mkdir -p ~/.codex
curl -o ~/.codex/AGENTS.md \
  https://raw.githubusercontent.com/juanbermudez/token-poverty/main/prompts/agents.md
```

Codex reads `~/.codex/AGENTS.md` first, then every `AGENTS.md` from your git root down to the
working directory, concatenated. Nearer files override further ones, so a repo-level
`AGENTS.md` beats the global one. Per directory, `AGENTS.override.md` is read instead of
`AGENTS.md` when present.

Then set the matching parameters in `~/.codex/config.toml`:

```toml
personality = "pragmatic"        # none | friendly | pragmatic
model_verbosity = "low"          # low | medium | high
model_reasoning_effort = "high"  # minimal | low | medium | high | xhigh
```

`/personality` changes it for one session without writing to config.

### The `model_instructions_file` option

`config.toml` also has `model_instructions_file`, which is structurally closer to an output
style:

```toml
model_instructions_file = "token-poverty.md"
```

> **This key replaces Codex's built-in instructions — it does not add to them.** Pointing it at
> a style file also discards the instructions that make Codex use its tools correctly. Use it
> only if your file is a complete agent prompt. For a style layer, use `AGENTS.md` above.

---

## ChatGPT desktop

No agent-style file surface. Use **Settings → Personalization → Custom instructions** and paste
[`prompts/agents-compact.md`](prompts/agents-compact.md) into the "How would you like ChatGPT to
respond?" field. The compact variant fits the field's length limit; the full one may not.

---

## Other agents

Most agents read `AGENTS.md`. Download the file once, then copy it to whichever paths apply:

```bash
curl -o /tmp/token-poverty.md \
  https://raw.githubusercontent.com/juanbermudez/token-poverty/main/prompts/agents.md
```

### Agents that read `AGENTS.md` directly

| Agent | Global path | Project path |
| --- | --- | --- |
| OpenCode | `~/.config/opencode/AGENTS.md` | `./AGENTS.md` |
| Amp | `~/.config/amp/AGENTS.md` | `./AGENTS.md` |
| Pi | `~/.pi/agent/AGENTS.md` | `./AGENTS.md` |
| Crush | `~/.config/crush/CRUSH.md` | `./CRUSH.md` or `./AGENTS.md` |
| Goose | `~/.config/goose/.goosehints` | `./.goosehints` or `./AGENTS.md` |
| Cursor | — (User Rules are UI-only) | `./AGENTS.md` |
| Gemini CLI | `~/.gemini/GEMINI.md` | `./GEMINI.md` |

OpenCode also accepts arbitrary paths, globs, and URLs via `"instructions": [...]` in
`opencode.json`. Gemini CLI can be pointed at `AGENTS.md` instead with the `context.fileName`
setting.

### Agents with their own rules format

| Agent | Path | Note |
| --- | --- | --- |
| Cline | `.clinerules/` (project), `~/Documents/Cline/Rules` (global) | Also falls back to `AGENTS.md` |
| Roo Code | `~/.roo/rules/`, `.roo/rules/` | Also reads `AGENTS.md` |
| Continue.dev | `.continue/rules/*.md` | Needs frontmatter: `name`, `alwaysApply: true` |
| GitHub Copilot | `.github/copilot-instructions.md` | Repo-scoped; personal instructions are UI-only |
| Windsurf | `.devin/rules/*.md` | `.windsurf/rules/` is legacy but still works. Global rules file caps at 6,000 characters — use `prompts/agents-compact.md` |
| Aider | `~/.aider.conf.yml` → `read: CONVENTIONS.md` | Points at a file rather than containing the text |
| Hermes Agent | `~/.hermes/config.yaml` → `personalities:` | YAML, not markdown. Confirm the key shape against current docs before relying on it |

---

## Prompt variants

Paste one of these into whatever system-prompt or instructions field the harness exposes.

| File | Format | Use for |
| --- | --- | --- |
| [`prompts/claude.md`](prompts/claude.md) | XML tags, few-shot examples | Claude via API or SDK |
| [`prompts/claude-compact.md`](prompts/claude-compact.md) | XML tags, minimal | Claude, tight token budget |
| [`prompts/agents.md`](prompts/agents.md) | Plain markdown | Any model; `AGENTS.md` convention |
| [`prompts/agents-compact.md`](prompts/agents-compact.md) | Plain markdown, minimal | Any model, tight token budget |
| [`output-styles/token-poverty.md`](output-styles/token-poverty.md) | YAML frontmatter + markdown | Claude Code only |

Compact variants are roughly 40% smaller and keep every rule; only padding and prose are cut.

---

## API parameters

For agents you build yourself, set the verbosity parameter alongside the prompt.

| Provider | Surface | Parameter |
| --- | --- | --- |
| Anthropic | Messages API | `output_config: { effort: "low" … "max" }` |
| OpenAI | Responses API | `text: { verbosity: "low" \| "medium" \| "high" }` |
| OpenAI | Responses API | `reasoning: { effort: … }` |
| OpenAI | Chat Completions | `reasoning_effort` (no verbosity — Responses only) |

---

## License

MIT
