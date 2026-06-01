# claude-skills

A personal [Claude Code plugin](https://docs.anthropic.com/en/docs/claude-code/plugins) bundling reusable **skills**, **slash commands**, **subagents**, **prompts**, and **scripts** so they travel together and install in one step.

## Layout

```
.claude-plugin/
  plugin.json        # plugin manifest (name, version, author)
  marketplace.json   # lets this repo be added as a marketplace
commands/            # slash commands → /claude-skills:<name>
skills/              # auto-loaded skills (one dir each, with SKILL.md)
agents/              # subagent definitions (*.md with frontmatter)
prompts/             # reusable prompt snippets (not auto-loaded)
scripts/             # helper scripts referenced by skills/commands
```

Claude Code auto-discovers `commands/`, `skills/`, and `agents/`. `prompts/` and `scripts/` are conveniences for the contents above to reference.

## Install

From a local checkout:

```sh
/plugin marketplace add ~/dev/claude-skills
/plugin install claude-skills@claude-skills
```

Or once pushed to GitHub:

```sh
/plugin marketplace add <user>/claude-skills
/plugin install claude-skills@claude-skills
```

## Adding content

- **Skill** — create `skills/<name>/SKILL.md` with `name` + a trigger-rich `description` in frontmatter. The description is the *only* signal Claude uses to decide when to load it.
- **Command** — create `commands/<name>.md` with a `description` frontmatter; the body is the prompt. Invoked as `/claude-skills:<name>`. `$ARGUMENTS` interpolates user input.
- **Agent** — create `agents/<name>.md` with frontmatter (`name`, `description`, optional `tools`).

See the `example-*` entries for working templates — delete them once you have real ones. Bump `version` in both `plugin.json` and `marketplace.json` on release.
