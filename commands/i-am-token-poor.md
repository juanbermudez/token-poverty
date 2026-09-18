---
description: Turn the Token Poverty output style on, or install it for the agents on this machine.
---

The installer is `${CLAUDE_PLUGIN_ROOT}/install.sh`. It does all the work — you are only
running it and relaying what it says.

**If the style is already installed** (`~/.claude/output-styles/token-poverty.md` exists), just
switch it on and stop:

```
${CLAUDE_PLUGIN_ROOT}/install.sh --on
```

**Otherwise, install it.** Do not guess at what the user wants installed where:

1. Run `${CLAUDE_PLUGIN_ROOT}/install.sh --detect` to see what is on this machine. Output is
   tab-separated: `id`, `label`, `target path`.
2. Show the user that list, and ask two things: **global or project**, and **which harnesses**.
3. Run the installer with their answers:
   `${CLAUDE_PLUGIN_ROOT}/install.sh --global|--project --only <ids> --yes`
4. Report each path it touched.

The installer appends inside markers and never overwrites, so existing config survives. It
records everything in `~/.token-poverty/manifest.tsv` so `/i-am-token-rich` can reverse it.

If the user named specific harnesses or a scope in their message, use those and skip the
question.
