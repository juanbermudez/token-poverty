---
description: Remove the Token Poverty output style and restore whatever configuration was there before.
---

Remove Token Poverty and put the user's previous configuration back.

Follow the `token-poverty` skill's removal procedure exactly. In particular:

- Read `~/.token-poverty/manifest.json` and work from what it records.
- Delete only the text between the skill's markers. Everything else in those files stays.
- Restore each changed key to its recorded previous value — and if it was absent before,
  remove the key rather than writing an empty one.
- If a file has been hand-edited since install, or a marker is missing or mismatched, stop
  and show the user what you found. Do not delete content you did not add.

Report every path you touched and its current state.
