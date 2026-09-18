---
description: Install the Token Poverty output style for this agent, without overwriting existing config.
---

Install the Token Poverty output style.

Follow the `token-rich-token-poor` skill's install procedure exactly. In particular:

- Identify which harness is running before you touch anything.
- List every path you intend to create, append to, or change, and wait for the user to
  approve that list before the first write.
- Wrap every block you add to a shared file in the skill's markers.
- Record what you did in `~/.token-poverty/manifest.json` before reporting success.

If the user named a specific harness in their message, install for that one. Otherwise infer
it, and ask only if more than one is plausible.
