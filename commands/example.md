---
description: Reference template for a slash command — replace or delete
argument-hint: "[args]"
---

# Example Command: $ARGUMENTS

This file is invoked as `/claude-skills:example`. The frontmatter `description` shows in
the command picker; `argument-hint` documents expected args. `$ARGUMENTS` interpolates
whatever the user types after the command.

A command body is just a prompt. To back a command with a skill, point it at the skill:

> Load and follow the `<skill-name>` skill and execute it against `$ARGUMENTS`.

Delete this once you've added real commands.
