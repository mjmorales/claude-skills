---
name: example-skill
description: Reference template showing the SKILL.md layout. Replace this with a real skill — and write a description packed with concrete trigger phrases, since this field is the ONLY thing Claude sees when deciding whether to load the skill. Triggers on "example skill", "skill template".
---

# Example Skill

A skill is a directory under `skills/` containing a `SKILL.md` with YAML frontmatter
(`name`, `description`) followed by the instructions Claude loads on trigger.

## Conventions

- `name` must match the directory name (kebab-case).
- `description` is the trigger surface: pack it with the phrases a user would actually
  say. It's the only signal Claude uses to decide whether to invoke the skill.
- Keep the body focused; link to bundled reference files for depth.
- Bundle supporting files (scripts, `references/`, data) in the same directory and
  reference them by relative path.

Delete this skill once you've added real ones.
