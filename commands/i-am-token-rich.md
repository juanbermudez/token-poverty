---
description: Turn the Token Poverty output style off and restore the previous one.
---

Switch the style off:

```
${CLAUDE_PLUGIN_ROOT}/install.sh --off
```

That restores whatever `outputStyle` was set before, or removes the key if there wasn't one.
It leaves the installed files in place, so `/i-am-token-poor` can switch back instantly.

**If the user wants it gone entirely** — uninstalled, not just switched off — run this instead
and report every path it reports:

```
${CLAUDE_PLUGIN_ROOT}/install.sh --uninstall
```

That removes the marked blocks from every file it recorded, deletes the files it created, and
restores changed settings. If it reports SKIPPED for a file, that file was hand-edited since
install — show the user and let them decide, do not clean it up yourself.
