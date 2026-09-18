---
name: token-rich-token-poor
description: Installs or removes the Token Poverty output style for whichever coding agent is running — Claude Code, Codex, Cursor, Cline, Roo, Continue, Windsurf, Copilot, Gemini CLI, Goose, OpenCode, Amp, Crush, Pi, Aider or Hermes. Use when the user asks to install, set up, add, remove, uninstall or restore Token Poverty, or says "I am token poor" or "I am token rich".
---

# Token Poverty installer

You are installing (or removing) a prompt file that makes a coding agent silent by default.
The user's existing configuration is not yours to overwrite.

## Golden rules

These are not negotiable and they outrank finishing the task.

1. **Never clobber.** Every target file may already exist and may contain work the user
   cares about. Read it before you write it. If it exists and has content, you append
   inside markers — you never replace the file.
2. **Show, then ask.** Before the first write, list every path you intend to touch and what
   you will do to each one: create, append, or change a key. Wait for a clear yes. A user
   asking to "install it" has approved the idea, not the specific set of edits.
3. **Markers or nothing.** Every block you add to a shared file is wrapped in the exact
   markers below, so removal is surgical and never guesses at boundaries.
4. **Record what you did.** Write the manifest before you report success. Without it,
   removal cannot restore the previous state.
5. **Never touch unrelated keys.** When editing a JSON or TOML config, change only the key
   named in the procedure. Preserve formatting and every other setting.

## The markers

```
<!-- BEGIN token-poverty v1.0.0 - https://github.com/juanbermudez/token-rich-token-poor -->
...style text...
<!-- END token-poverty -->
```

For TOML and YAML files use `#` instead of `<!-- -->`:

```
# BEGIN token-poverty v1.0.0
...
# END token-poverty
```

If the markers are already present in a file, this is a reinstall: replace the text between
them in place. Do not add a second block.

## The manifest

`~/.token-poverty/manifest.json`. Write it after a successful install, update it on
reinstall, delete it on removal.

```json
{
  "version": "1.0.0",
  "installed_at": "2026-09-18T00:00:00Z",
  "targets": [
    { "path": "/Users/x/.claude/output-styles/token-poverty.md",
      "action": "created_file" },
    { "path": "/Users/x/.codex/AGENTS.md",
      "action": "appended_block" },
    { "path": "/Users/x/.claude/settings.json",
      "action": "changed_key", "key": "outputStyle",
      "previous": "Attention-kind", "previous_absent": false }
  ]
}
```

`action` is one of `created_file`, `appended_block`, or `changed_key`. For `changed_key`,
record the exact previous value, and set `previous_absent: true` when the key did not exist
at all — those two cases restore differently.

## Step 1 — identify the harness

Do not ask the user which agent they are running unless you genuinely cannot tell. Infer it
from your own environment: the tools you have, the config directories that exist on disk,
and the settings files present. Check for `~/.claude/`, `~/.codex/`, `~/.gemini/`,
`~/.config/goose/`, `~/.config/opencode/`, `~/.cursor/`, `~/.roo/`, `~/.pi/`, `~/.hermes/`.

If more than one is present, ask which to install for, and offer "all of them" as an option.

## Step 2 — install

Triggered by "/i-am-token-poor", or any request to install, set up, or add Token Poverty.


The style text is in this repository: `output-styles/token-poverty.md` (with frontmatter,
Claude Code only) and `prompts/agents.md` (plain markdown, everyone else). Use
`prompts/agents-compact.md` where a length cap applies.

| Harness | Target | Action |
| --- | --- | --- |
| Claude Code | `~/.claude/output-styles/token-poverty.md` | Create the file. Then set `outputStyle` to `"Token Poverty"` in `~/.claude/settings.json`, recording the previous value. |
| Codex | `~/.codex/AGENTS.md` | Append a marked block. Then in `~/.codex/config.toml` set `personality = "pragmatic"` and `model_verbosity = "low"`, recording previous values. |
| Cursor | `./AGENTS.md` in the project | Append a marked block. |
| Cline | `.clinerules/token-poverty.md` | Create the file — this directory holds one file per rule, so no append is needed. |
| Roo Code | `~/.roo/rules/token-poverty.md` | Create the file. |
| Continue | `.continue/rules/token-poverty.md` | Create the file. Add frontmatter `name: Token Poverty` and `alwaysApply: true`. |
| Copilot | `.github/copilot-instructions.md` | Append a marked block. |
| Windsurf | `~/.codeium/windsurf/memories/global_rules.md` | Append a marked block. **6,000 character cap** — use the compact variant, and check the resulting file size before writing. |
| Gemini CLI | `~/.gemini/GEMINI.md` | Append a marked block. |
| Goose | `~/.config/goose/.goosehints` | Append a marked block. |
| OpenCode | `~/.config/opencode/AGENTS.md` | Append a marked block. |
| Amp | `~/.config/amp/AGENTS.md` | Append a marked block. |
| Crush | `~/.config/crush/CRUSH.md` | Append a marked block. |
| Pi | `~/.pi/agent/AGENTS.md` | Append a marked block. |
| Aider | `~/.aider.conf.yml` | Write the style to `~/.token-poverty/CONVENTIONS.md`, then add that path to the `read:` list. Do not replace an existing `read:` value — append to the list. |
| Hermes | `~/.hermes/config.yaml` | Add a `personalities:` entry. **Verify the key shape against current Hermes docs first** — this schema is not confirmed. If you cannot confirm it, tell the user and skip this target rather than guessing. |

Create parent directories as needed. After writing, report each path and what you did to it.

## Step 3 — remove

Triggered by "/i-am-token-rich", or any request to remove, uninstall, or restore.

1. Read `~/.token-poverty/manifest.json`. If it is missing, say so and fall back to
   searching the table's paths for the markers — but tell the user you are working without a
   manifest and that `changed_key` values cannot be restored, only removed.
2. For `created_file`: delete the file.
3. For `appended_block`: delete everything between and including the markers. **Leave the
   rest of the file exactly as it is.** If the file is now empty and it did not exist before
   the install, delete it; otherwise leave the empty file.
4. For `changed_key`: restore `previous`. If `previous_absent` is true, remove the key
   entirely rather than writing an empty string.
5. Delete the manifest.
6. Report every path you touched and what it looks like now.

If any file has been edited by hand since the install — the block is missing, the markers are
mismatched, or the current key value is not the one you set — **stop and ask.** Show the user
what you found and let them decide. Do not delete content you did not put there.
